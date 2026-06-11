# Python Web App — GitHub Actions CI/CD + Kubernetes

A Flask-based web application shipped through a fully automated **GitHub Actions CI/CD pipeline** that runs tests, enforces code quality via flake8, builds and pushes a Docker image to Docker Hub, then automatically updates the image tag in a **Helm chart** for GitOps-style Kubernetes deployment.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Python 3.12 / Flask 3.0 |
| Testing & Linting | pytest + flake8 |
| Containerisation | Docker + Docker Hub |
| CI/CD | GitHub Actions |
| Deployment | Helm + Kubernetes |
| Ingress | Nginx Ingress Controller |

## CI/CD Pipeline

The pipeline has 4 jobs with strict dependencies — downstream jobs only run if all upstream jobs pass:
build → code-quality → push → update-newtag-in-helm-chart

| Job | Depends On | Steps |
|-----|-----------|-------|
| build | — | Checkout → setup Python 3.12 → install deps → run pytest |
| code-quality | build | Checkout → setup Python 3.12 → run flake8 linting |
| push | build, code-quality | Docker Buildx → login to Docker Hub → build & push with run_id tag |
| update-helm-tag | push | sed replaces image tag in values.yaml → git commit & push |

## Project Structure
python-web-app/

├── app.py                        # Flask application

├── static/                       # HTML pages (home, about, courses, contact)

├── test_app.py                   # pytest test suite

├── Dockerfile                    # Container image definition

├── requirements.txt              # Flask, gunicorn, pytest

├── .github/

│   └── workflows/

│       └── ci.yaml               # Full CI/CD pipeline definition

├── k8s/

│   └── manifests/

│       ├── deployment.yaml

│       ├── service.yaml

│       └── ingress.yaml

└── helm/

└── python-web-app-chart/

## Kubernetes Deployment

- **Deployment** — 1 replica of the app on container port 8080
- **Service** — exposes the deployment internally on port 80
- **Ingress** — Nginx Ingress routes `python-web-app.local` traffic to the service

## Quick Start

```bash
# Local Docker run
docker build -t python-web-app .
docker run -p 8080:8080 python-web-app

# Kubernetes via Helm
helm install python-web-app ./helm/python-web-app-chart

# Kubernetes via raw manifests
kubectl apply -f k8s/manifests/
```

## Required GitHub Secrets

| Secret | Description |
|--------|-------------|
| DOCKERHUB_USERNAME | Your Docker Hub username |
| DOCKERHUB_TOKEN | Docker Hub access token (not your password) |
| TOKEN | GitHub PAT with repo write access (for Helm chart update commit) |

## How GitOps Works Here

Every push to `main` triggers the pipeline. Once tests and linting pass, the Docker image is built and pushed to Docker Hub with the GitHub `run_id` as the tag. The final pipeline job then automatically commits an updated image tag back into `helm/python-web-app-chart/values.yaml` — so the Kubernetes cluster always knows which image version to pull.
