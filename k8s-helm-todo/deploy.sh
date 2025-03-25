#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLUSTER_NAME=${1:-mycluster}

# Get current version from Chart.yaml
VERSION=$(grep -E '^version:' "$SCRIPT_DIR/charts/todo-app/Chart.yaml" | awk '{print $2}')

echo "Deploying Todo App version $VERSION to cluster $CLUSTER_NAME"

# Build Docker images
echo "Building Docker images..."
docker build -t todo-app:$VERSION "$SCRIPT_DIR/backend"
docker build -t todo-frontend:$VERSION "$SCRIPT_DIR/frontend"

# Import images to cluster
echo "Importing images to k3d cluster..."
k3d image import todo-app:$VERSION todo-frontend:$VERSION -c $CLUSTER_NAME

# Check if the Helm release exists
if helm status todo-app &> /dev/null; then
    echo "Upgrading existing Helm release..."
    helm upgrade todo-app "$SCRIPT_DIR/charts/todo-app"
else
    echo "Installing new Helm release..."
    helm install todo-app "$SCRIPT_DIR/charts/todo-app"
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

# Make script executable
chmod +x "$SCRIPT_DIR/deploy.sh"
