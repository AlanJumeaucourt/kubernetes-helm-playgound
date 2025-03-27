# Kubernetes + Helm + FastAPI + PostgreSQL Todo App

A showcase of Kubernetes and Helm expertise, featuring a sophisticated database migration system and modern cloud-native practices.

## Key Technical Features

- **Cloud Native PostgreSQL**: Using `cloudnative-pg` operator for production-grade PostgreSQL management
- **Database Migration System**: 
  - Automated schema migrations using Helm hooks
  - Version-controlled database changes
  - Zero-downtime migration support
  - Migration job with retry capability
  - Helm rollback support for version downgrades
- **Kubernetes Best Practices**:
  - Proper resource limits and requests
  - Health checks and readiness probes
  - RBAC configuration
  - ConfigMap and Secret management
  - Helm hooks for ordered operations
- **Production-Ready Setup**:
  - Proper service separation
  - Ingress configuration
  - Health monitoring
  - Database connection management

## Components

- **Frontend**: Simple HTML/CSS/JS UI served by Nginx
- **Backend**: FastAPI RESTful API with SQLAlchemy
- **Database**: Cloud Native PostgreSQL for data persistence
- **Infrastructure**: Kubernetes + Helm for orchestration

## Versioning

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR** version for incompatible API changes
- **MINOR** version for new functionality in a backward compatible manner
- **PATCH** version for backward compatible bug fixes

## Version History

See the [CHANGELOG.md](k8s-helm-todo/CHANGELOG.md) for a detailed list of changes for each version.

### Current Version: 1.0.7

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
   ```bash
   git clone https://github.com/AlanJumeaucourt/kubernetes-helm-playgound.git
   cd kubernetes-helm-playgound
   ```

2. Install Cloud Native PostgreSQL operator:
   ```bash
   helm repo add cnpg https://cloudnative-pg.github.io/charts
   helm upgrade --install cnpg \
   --namespace cnpg-system \
   --create-namespace \
   cnpg/cloudnative-pg
   ```

3. Deploy the application:
   ```bash
   # Using the deployment script (recommended)
   ./k8s-helm-todo/deploy.sh

   # Or manually with Helm
   helm install todo-app ./k8s-helm-todo/charts/todo-app
   ```

## Database Migration System

This project features a sophisticated database migration system that:

1. Uses Helm hooks to manage migration order
2. Automatically tracks applied migrations in a `schema_migrations` table
3. Supports zero-downtime upgrades
4. Provides migration job retry capability (up to 5 attempts)
5. Supports Helm rollback to previous versions
6. Handles database connection management

Example migration:
```sql
-- V2__add_completion_date.sql
ALTER TABLE todos 
ADD COLUMN IF NOT EXISTS completion_date TIMESTAMP;
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
