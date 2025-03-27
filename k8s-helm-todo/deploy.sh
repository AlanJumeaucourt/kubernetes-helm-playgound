#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLUSTER_NAME=${1:-mycluster}
DOCKER_USERNAME=${DOCKER_USERNAME:-alanjumeaucourtHUB}

# Get current version from Chart.yaml
VERSION=$(grep -E '^version:' "$SCRIPT_DIR/charts/todo-app/Chart.yaml" | awk '{print $2}')

echo "Deploying Todo App version $VERSION to cluster $CLUSTER_NAME"

# Check if --local flag is provided
USE_LOCAL_IMAGES=false
for arg in "$@"; do
  if [ "$arg" = "--local" ]; then
    USE_LOCAL_IMAGES=true
    break
  fi
done

if [ "$USE_LOCAL_IMAGES" = true ]; then
  echo "Building local Docker images..."
  docker build -t $DOCKER_USERNAME/todo-app:$VERSION "$SCRIPT_DIR/backend"
  docker build -t $DOCKER_USERNAME/todo-frontend:$VERSION "$SCRIPT_DIR/frontend"

  # Import images to cluster
  echo "Importing local images to k3d cluster..."
  k3d image import $DOCKER_USERNAME/todo-app:$VERSION $DOCKER_USERNAME/todo-frontend:$VERSION -c $CLUSTER_NAME
else
  echo "Using images from Docker Hub (username: $DOCKER_USERNAME)"
  # No need to build or import, Kubernetes will pull them from Docker Hub
fi

# Check if the Helm release exists
if helm status todo-app &> /dev/null; then
    echo "Upgrading existing Helm release..."
    helm upgrade todo-app "$SCRIPT_DIR/charts/todo-app" --set backend.image.repository=$DOCKER_USERNAME/todo-app --set frontend.image.repository=$DOCKER_USERNAME/todo-frontend
else
    echo "Installing new Helm release..."
    helm install todo-app "$SCRIPT_DIR/charts/todo-app" --set backend.image.repository=$DOCKER_USERNAME/todo-app --set frontend.image.repository=$DOCKER_USERNAME/todo-frontend
fi

# Wait for pods to be ready
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=todo-backend --timeout=60s || true
kubectl wait --for=condition=ready pod -l app=todo-frontend --timeout=60s || true

echo "Deployment complete!"
echo ""
echo "To access the app, run:"
echo "kubectl port-forward service/todo-frontend 8081:80"
echo ""
echo "Then open http://localhost:8081 in your browser"

