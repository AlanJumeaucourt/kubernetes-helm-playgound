# Automated Deployment with GitHub Actions

This repository uses GitHub Actions to automate the deployment process when a new version tag is pushed. The workflow will:

1. Build and push Docker images to Docker Hub
2. Update the Helm chart version
3. Update the `CHANGELOG.md` with commit messages
4. Create a GitHub Release with the packaged Helm chart

## How to Release a New Version

To release a new version, simply create and push a tag with the version number:

```bash
# Create a tag
git tag v1.0.5

# Push the tag
git push origin v1.0.5
```

The GitHub Actions workflow will automatically:
- Extract the version number from the tag
- Update version references in the Helm chart
- Build and push Docker images with the version tag
- Create a GitHub Release with the packaged Helm chart

## Required GitHub Secrets

For this workflow to function properly, you need to set up the following secrets in your GitHub repository:

- `DOCKER_USERNAME`: Your Docker Hub username
- `DOCKER_PASSWORD`: Your Docker Hub password or access token

To add these secrets:
1. Go to your GitHub repository
2. Click on "Settings"
3. Click on "Secrets and variables" > "Actions"
4. Click on "New repository secret"
5. Add each secret with its name and value

## Deployment

After the workflow completes, you can deploy your application using:

```bash
# Using the local deploy script
# Default user's Docker Hub username (or set DOCKER_USERNAME env var)
./k8s-helm-todo/deploy.sh

# To use local images instead of Docker Hub
./k8s-helm-todo/deploy.sh --local
```

## Maintaining the Workflow

If you need to modify the deployment process:

1. Edit the `.github/workflows/release.yml` file
2. Commit and push your changes
3. Create a new tag to test the updated workflow 