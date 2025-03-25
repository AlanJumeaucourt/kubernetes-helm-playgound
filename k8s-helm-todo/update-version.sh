#!/bin/bash
set -e

# Check if version is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <new-version> [\"changelog message\"]"
    echo "Example: $0 1.0.3 \"Fixed bug in todo deletion\""
    exit 1
fi

NEW_VERSION=$1
CHANGELOG_MSG=$2
DATE=$(date +%Y-%m-%d)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Updating version to $NEW_VERSION"

# Update Chart.yaml
echo "Updating Chart.yaml..."
sed -i "s/^version:.*/version: $NEW_VERSION/" "$SCRIPT_DIR/charts/todo-app/Chart.yaml"
sed -i "s/^appVersion:.*/appVersion: \"$NEW_VERSION\"/" "$SCRIPT_DIR/charts/todo-app/Chart.yaml"

# Update values.yaml
echo "Updating values.yaml..."
sed -i "s/tag:.*/tag: $NEW_VERSION/" "$SCRIPT_DIR/charts/todo-app/values.yaml"

# Update Docker labels
echo "Updating Dockerfiles..."
sed -i "s/version=\".*\"/version=\"$NEW_VERSION\"/" "$SCRIPT_DIR/backend/Dockerfile"
sed -i "s/version=\".*\"/version=\"$NEW_VERSION\"/" "$SCRIPT_DIR/frontend/Dockerfile"

# Update README.md
echo "Updating README.md..."
sed -i "s/### Current Version: .*/### Current Version: $NEW_VERSION/" "$SCRIPT_DIR/../README.md"
sed -i "s/todo-app:.*\s/todo-app:$NEW_VERSION /" "$SCRIPT_DIR/../README.md"
sed -i "s/todo-frontend:.*\s/todo-frontend:$NEW_VERSION /" "$SCRIPT_DIR/../README.md"

# Add new version to CHANGELOG.md if a message is provided
if [ ! -z "$CHANGELOG_MSG" ]; then
    echo "Updating CHANGELOG.md..."
    # Create a temp file
    TEMP_FILE=$(mktemp)

    # Read up to the line after the format description
    grep -A 3 "# Changelog" "$SCRIPT_DIR/CHANGELOG.md" > "$TEMP_FILE"

    # Add the new version section
    cat >> "$TEMP_FILE" << EOF

## [$NEW_VERSION] - $DATE

### Added
- $CHANGELOG_MSG

EOF

    # Append the rest of the original file (skipping the header we already added)
    grep -A 1000 "## \[" "$SCRIPT_DIR/CHANGELOG.md" | tail -n +1 >> "$TEMP_FILE"

    # Replace the original file
    mv "$TEMP_FILE" "$SCRIPT_DIR/CHANGELOG.md"
fi

echo "Version updated to $NEW_VERSION"
echo "Now run these commands to build and deploy the new version:"
echo ""
echo "# Build Docker images"
echo "docker build -t todo-app:$NEW_VERSION ./k8s-helm-todo/backend"
echo "docker build -t todo-frontend:$NEW_VERSION ./k8s-helm-todo/frontend"
echo ""
echo "# Import images to k3d (if using k3d)"
echo "k3d image import todo-app:$NEW_VERSION todo-frontend:$NEW_VERSION -c mycluster"
echo ""
echo "# Upgrade Helm release"
echo "helm upgrade todo-app k8s-helm-todo/charts/todo-app"

# Make script executable
chmod +x "$SCRIPT_DIR/update-version.sh"
