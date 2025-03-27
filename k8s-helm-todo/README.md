# Kubernetes + Helm + FastAPI + PostgreSQL Todo App

## Overview

This project is a simple **3-tier Todo app** deployed on **Kubernetes** using **Helm**. The stack consists of:

- **Backend**: FastAPI (Python) with SQLAlchemy
- **Database**: PostgreSQL
- **Kubernetes Deployment**: Helm for version control and upgrades
- **Migration Support**: Helm hooks for database schema updates
- **Rollback Support**: Helm rollback ensures smooth version downgrades

---

## Features

- Create and retrieve todos via REST API
- Store todos in a PostgreSQL database
- Deployable on Kubernetes using Helm
- Schema migration with Helm upgrades
- Rollback capability if an upgrade fails

---

## Setup & Deployment

### 1. Prerequisites

Ensure you have the following installed:
- [Docker](https://www.docker.com/)
- [Kubernetes (Minikube or Kind for local)](https://kubernetes.io/)
- [Helm](https://helm.sh/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

### 2. Clone the Repository

```bash
git clone https://github.com/your-repo/k8s-helm-todo.git
cd k8s-helm-todo
```

### 3. Build and Push Docker Image

```bash
docker build -t alanjumeaucourtHUB/todo-app:latest ./backend
```

(Optional: Push to DockerHub)

```bash
docker push alanjumeaucourtHUB/todo-app:latest
```

### 4. Deploy the App Using Helm

```bash
helm install todo-app charts/todo-app
```

### 5. Verify Deployment

```bash
kubectl get pods
kubectl get services
```

### 6. Upgrade with Database Migration

Modify `migrations/V2__add_due_date.sql` and apply an upgrade:

```bash
helm upgrade todo-app charts/todo-app
```

### 7. Rollback if Needed

```bash
helm rollback todo-app 1  # Replace '1' with the previous release version
```

---

## API Endpoints

| Method | Endpoint    | Description          |
|--------|------------|----------------------|
| GET    | `/todos`   | Get all todos       |
| POST   | `/todos`   | Create a new todo   |

---

## Cleanup

To uninstall the app:

```bash
helm uninstall todo-app
```

---

## Contributing

Feel free to open issues or submit PRs to improve the project!

---

## License

MIT License
