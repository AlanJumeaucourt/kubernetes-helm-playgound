# Kubernetes + Helm + FastAPI + PostgreSQL Todo App

## Technical Overview

This project demonstrates advanced Kubernetes and Helm practices, with a focus on database management and zero-downtime deployments.

### Key Technical Features

#### Database Management
- Uses Cloud Native PostgreSQL operator for production-grade database management
- Implements a sophisticated migration system using Helm hooks
- Supports zero-downtime schema updates
- Migration job with retry capability (up to 5 attempts)
- Helm rollback support for version downgrades
- Version-controlled database changes

#### Kubernetes Implementation
- Proper resource management with limits and requests
- Health checks and readiness probes
- RBAC configuration for secure access
- ConfigMap and Secret management
- Helm hooks for ordered operations
- Service separation and ingress configuration

#### Production Readiness
- Health monitoring endpoints
- Database connection management
- Proper error handling
- Logging and monitoring support

## Architecture

The application is structured as a 3-tier system:

- **Frontend**: Nginx serving static files
- **Backend**: FastAPI with SQLAlchemy
- **Database**: Cloud Native PostgreSQL
- **Infrastructure**: Kubernetes + Helm

## Setup & Deployment

### Prerequisites

- [Docker](https://www.docker.com/)
- [Kubernetes (Minikube or Kind or K3d for local)](https://kubernetes.io/)
- [Helm](https://helm.sh/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

### Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/AlanJumeaucourt/kubernetes-helm-playgound.git
   cd kubernetes-helm-playgound
   ```

2. Deploy using the provided script:
   ```bash
   ./k8s-helm-todo/deploy.sh
   ```

### Manual Deployment

1. Build Docker images:
   ```bash
   docker build -t alanjumeaucourtHUB/todo-app:latest ./backend
   docker build -t alanjumeaucourtHUB/todo-frontend:latest ./frontend
   ```

2. Deploy with Helm:
   ```bash
   helm install todo-app charts/todo-app
   ```

## Database Migration System

The project includes a sophisticated database migration system that:

1. Uses Helm hooks to manage migration order
2. Tracks applied migrations in a `schema_migrations` table
3. Supports zero-downtime upgrades
4. Provides migration job retry capability
5. Supports Helm rollback to previous versions

### Migration Process

1. Migrations are stored in ConfigMaps
2. A Kubernetes Job runs migrations using Helm hooks
3. Migrations are tracked in the database
4. Failed migrations trigger job retries (up to 5 attempts)
5. Helm rollback can be used to revert to previous versions

Example migration:
```sql
-- V2__add_completion_date.sql
ALTER TABLE todos 
ADD COLUMN IF NOT EXISTS completion_date TIMESTAMP;
```

## API Endpoints

| Method | Endpoint    | Description          |
|--------|------------|----------------------|
| GET    | `/todos`   | Get all todos       |
| POST   | `/todos`   | Create a new todo   |
| PUT    | `/todos/{id}` | Update a todo    |
| DELETE | `/todos/{id}` | Delete a todo    |

## Monitoring

The application includes:
- Health check endpoint at `/health`
- Database connection monitoring
- Pod readiness and liveness probes
- Resource usage monitoring

## Cleanup

To uninstall the application:

```bash
helm uninstall todo-app
```

## Contributing

Feel free to open issues or submit PRs to improve the project!

## License

MIT License
