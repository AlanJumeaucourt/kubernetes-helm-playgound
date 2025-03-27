# Todo Application with Kubernetes and Helm

A full-stack Todo application deployed with Kubernetes and Helm.

## Components

- **Frontend**: Simple HTML/CSS/JS UI served by Nginx
- **Backend**: FastAPI RESTful API
- **Database**: PostgreSQL for data persistence

## Versioning

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR** version for incompatible API changes
- **MINOR** version for new functionality in a backward compatible manner
- **PATCH** version for backward compatible bug fixes

## Version History

See the [CHANGELOG.md](k8s-helm-todo/CHANGELOG.md) for a detailed list of changes for each version.

### Current Version: 1.0.6

The current version includes:
- Full CRUD functionality for Todo items
- Frontend UI with add, complete, and delete capabilities
- Backend REST API with proper database integration
- Helm chart for Kubernetes deployment
- Completion date tracking for todos
- Database migration system for schema updates
- Updated deployment process with local Docker image builds
- Simplified deployment without GitHub Actions

## Installation

### Prerequisites

- Kubernetes cluster (k3d, minikube, or any other)
- Helm v3+
- Docker

### Getting Started

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/full-helm-app.git
   cd full-helm-app
   ```

2. Install cloudnativePG

   ```bash
   helm repo add cnpg https://cloudnative-pg.github.io/charts
   helm upgrade --install cnpg \
   --namespace cnpg-system \
   --create-namespace \
   cnpg/cloudnative-pg
   ```

3. Deploy the application

   ```bash
   ./k8s-helm-todo/deploy.sh
   ```



## Development

When making changes to the application, please follow these guidelines:

1. Update the version number in:
   - `k8s-helm-todo/charts/todo-app/Chart.yaml`
   - `k8s-helm-todo/charts/todo-app/values.yaml`
   - Docker image tags

2. Document your changes in `k8s-helm-todo/CHANGELOG.md`

3. Rebuild and redeploy following the steps in the Installation section

### Automation Scripts

This project includes several scripts to automate common tasks:

#### Version Management

To update the version across all project files and add a changelog entry:

```bash
# Update to version 1.0.3 with changelog message
./k8s-helm-todo/update-version.sh 1.0.3 "Added user authentication feature"
```

This will:
- Update version numbers in Chart.yaml, values.yaml, and Dockerfiles
- Update version references in README.md
- Add a new entry to CHANGELOG.md

#### Deployment

To build, import to k3d, and deploy the application:

```bash
# Deploy to default cluster (mycluster)
./k8s-helm-todo/deploy.sh

# Or specify a different cluster
./k8s-helm-todo/deploy.sh my-other-cluster
```

#### Open Application

To set up port forwarding and open the application in your browser:

```bash
# Use default port 8081
./k8s-helm-todo/open-app.sh

# Or specify a different port
./k8s-helm-todo/open-app.sh 8082
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
