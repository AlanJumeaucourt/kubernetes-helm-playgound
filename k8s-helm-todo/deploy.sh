#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] INFO:${NC} $1"
}

log_success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS:${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARN:${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLUSTER_NAME=${1:-k3s-default}
DOCKER_USERNAME=${DOCKER_USERNAME:-alanjumeaucourthub}

# Get current version from Chart.yaml
VERSION=$(grep -E '^version:' "$SCRIPT_DIR/charts/todo-app/Chart.yaml" | awk '{print $2}')

# Check if --local flag is provided
USE_LOCAL_IMAGES=false
for arg in "$@"; do
  if [ "$arg" = "--local" ]; then
    USE_LOCAL_IMAGES=true
    break
  fi
done

# Display summary of what will be done
echo -e "\n${BLUE}=== Deployment Summary ===${NC}"
echo -e "Target Cluster: ${GREEN}$CLUSTER_NAME${NC}"
echo -e "App Version: ${GREEN}$VERSION${NC}"
echo -e "Image Mode: ${GREEN}$([ "$USE_LOCAL_IMAGES" = true ] && echo "Local Build" || echo "Docker Hub")${NC}"
echo -e "\n${BLUE}Actions to be performed:${NC}"
if [ "$USE_LOCAL_IMAGES" = true ]; then
    echo "1. Build Docker images locally"
    echo "2. Import images to k3d cluster"
fi
echo "$([ "$USE_LOCAL_IMAGES" = true ] && echo "3" || echo "1"). Deploy Todo App using Helm"
echo "$([ "$USE_LOCAL_IMAGES" = true ] && echo "4" || echo "2"). Wait for pods to be ready"
echo "$([ "$USE_LOCAL_IMAGES" = true ] && echo "5" || echo "3"). Configure local DNS (todo.local)"
echo -e "\n${YELLOW}Note: This script will modify your /etc/hosts file${NC}"
echo -e "\n${BLUE}Do you want to proceed? (y/N)${NC} "
read -r response

if [[ ! "$response" =~ ^[Yy]$ ]]; then
    log_warn "Deployment cancelled by user"
    exit 1
fi

echo # Add a blank line for better readability

log_info "Deploying Todo App version $VERSION to cluster $CLUSTER_NAME"

if [ "$USE_LOCAL_IMAGES" = true ]; then
  log_info "Building local Docker images..."
  docker build -t $DOCKER_USERNAME/todo-app:$VERSION "$SCRIPT_DIR/backend"
  docker build -t $DOCKER_USERNAME/todo-frontend:$VERSION "$SCRIPT_DIR/frontend"

  # Import images to cluster
  log_info "Importing local images to k3d cluster..."
  k3d image import $DOCKER_USERNAME/todo-app:$VERSION $DOCKER_USERNAME/todo-frontend:$VERSION -c $CLUSTER_NAME
  
  # Set local image repositories
  HELM_EXTRA_ARGS="--set backend.image.repository=$DOCKER_USERNAME/todo-app --set frontend.image.repository=$DOCKER_USERNAME/todo-frontend"
else
  log_info "Using default images from Docker Hub"
  HELM_EXTRA_ARGS=""
fi

# Check if the Helm release exists
if helm status todo-app &> /dev/null; then
    log_info "Upgrading existing Helm release..."
    helm upgrade todo-app "$SCRIPT_DIR/charts/todo-app" $HELM_EXTRA_ARGS
else
    log_info "Installing new Helm release..."
    helm install todo-app "$SCRIPT_DIR/charts/todo-app" $HELM_EXTRA_ARGS
fi

# Wait for pods to be ready
log_info "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=todo-backend --timeout=60s || true
kubectl wait --for=condition=ready pod -l app=todo-frontend --timeout=60s || true

log_success "Deployment complete!"
log_info "Configuring local DNS..."

# Get cluster IP
CLUSTER_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')
if [ -z "$CLUSTER_IP" ]; then
    log_error "Could not determine cluster IP"
    exit 1
fi

# Check if entry already exists
if grep -q "todo.local" /etc/hosts; then
    log_info "Updating existing todo.local entry in /etc/hosts..."
    sudo sed -i "s/.*todo.local/$CLUSTER_IP todo.local/" /etc/hosts
else
    log_info "Adding todo.local entry to /etc/hosts..."
    echo "$CLUSTER_IP todo.local" | sudo tee -a /etc/hosts > /dev/null
fi

log_success "Configuration complete! You can now access the app at http://todo.local"
