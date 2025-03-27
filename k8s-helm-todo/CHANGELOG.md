# Changelog

All notable changes to this project will be documented in this file.

## [1.0.6] - 2025-03-26

### Changed
- Updated Docker image repository references to use new username 'alanjumeaucourtHUB'
- Updated backend service name to 'todo-backend'
- Updated frontend service name to 'todo-frontend'
- Removed GitHub Actions deployment workflow
- Updated deployment script to support local Docker image builds

### Removed
- Removed GitHub Actions deployment workflow

## [1.0.5] - 2025-03-26

### Added
- Database: Added completion_date field to todos table
- Backend: Added completion_date support in API
- Frontend: Display completion date for completed todos
- Database migration system for seamless schema updates
- Automatic recording of completion timestamp when a todo is marked as complete

### Changed
- Updated backend version to 1.0.5
- Updated frontend version to 1.0.5
- Improved completed todo styling

## [1.0.4] - 2025-03-25

### Changed
- Backend: Replaced SQLAlchemy ORM with direct SQL queries using psycopg2
- Backend: Replaced Pydantic validation with Marshmallow schemas
- Backend: Improved error handling for database operations
- Backend: Enhanced database connection management

### Added
- Backend: New SQL-based database initialization
- Backend: Proper database health check implementation in /health endpoint
- Backend: Dynamic SQL query generation for update operations

### Removed
- Removed SQLAlchemy dependency
- Removed Pydantic dependency
- Removed Alembic dependency

## [1.0.3] - 2025-03-25

### Changed
- Migrated from standalone PostgreSQL to Cloud Native PostgreSQL (cnpg)
- Updated database connection string to use cnpg cluster
- Removed old database deployment and configuration

### Added
- Cloud Native PostgreSQL cluster configuration
- New database credentials secret for cnpg

## [1.0.2] - 2025-03-25

### Added
- Backend: Implemented PUT endpoint for updating todo items
- Backend: Implemented DELETE endpoint for removing todo items
- Frontend: Added functionality to toggle todo completion state
- Frontend: Added functionality to delete todo items

### Fixed
- Fixed naming conflict between SQLAlchemy and Pydantic models (renamed SQLAlchemy model to TodoModel)
- Updated frontend to correctly interact with the backend API endpoints

## [1.0.1] - 2025-03-25

### Added
- Frontend application with Nginx serving static files
- API routing through Nginx proxy with /api path prefix
- Proper separation between frontend and backend services

### Changed
- Updated Helm chart to include frontend deployment and service
- Changed ingress to point to the frontend instead of directly to the backend

### Fixed
- Fixed configuration issues with ingress routing

## [1.0.0] - 2025-03-25

### Added
- Initial release of Todo application
- Basic backend API with FastAPI
- PostgreSQL database for todo storage
- Kubernetes manifests for backend and database
- Helm chart for deployment management
