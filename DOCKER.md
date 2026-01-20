# Docker Deployment Guide

This guide covers how to use the Docker images for CNCF People Explorer.

## Available Variants

We provide 3 Docker image variants for different use cases:

### 1. Standalone (Recommended for Simple Deployments)

Uses the CNCF API directly - no backend required.

```bash
docker run -d -p 8080:80 nyanlintun/cncf-people-explorer:standalone
```

Visit: http://localhost:8080

### 2. Frontend (For Production with Custom Backend)

Connects to your custom backend API.

```bash
docker run -d -p 8080:80 \
  -e VITE_API_URL=https://your-backend.com/api/people \
  nyanlintun/cncf-people-explorer:frontend
```

Backend repository: https://github.com/nyan-lin-tun/CNCF-people-api

### 3. Example (For Quick Demos)

Uses bundled sample data (5 people).

```bash
docker run -d -p 8080:80 nyanlintun/cncf-people-explorer:example
```

## Using Docker Compose

### Standalone Deployment

```bash
docker-compose -f docker-compose.standalone.yml up -d
```

### Frontend with Backend

1. Edit `docker-compose.frontend.yml`
2. Update `VITE_API_URL` to point to your backend
3. Run:

```bash
docker-compose -f docker-compose.frontend.yml up -d
```

### Example Demo

```bash
docker-compose -f docker-compose.example.yml up -d
```

## Building Locally

```bash
# Build standalone
docker build --build-arg MODE=standalone -t cncf-explorer:standalone .

# Build frontend
docker build --build-arg MODE=frontend -t cncf-explorer:frontend .

# Build example
docker build --build-arg MODE=example -t cncf-explorer:example .
```

## Environment Variables

### Frontend Variant

- `VITE_API_URL` - Backend API endpoint (required)

Example:
```bash
docker run -p 8080:80 \
  -e VITE_API_URL=http://host.docker.internal:3000/api/people \
  nyanlintun/cncf-people-explorer:frontend
```

### Standalone & Example Variants

No environment variables required.

## Health Check

All images include health checks:

```bash
docker ps
# Look for "healthy" status
```

## Production Deployment

### Docker Swarm

```bash
docker service create \
  --name cncf-explorer \
  --replicas 3 \
  --publish 8080:80 \
  nyanlintun/cncf-people-explorer:standalone
```

### Kubernetes

See `CICD.md` for Kubernetes deployment examples.

## Troubleshooting

### Check logs

```bash
docker logs <container-id>
```

### Check if container is running

```bash
docker ps
```

### Verify image

```bash
docker images | grep cncf-people-explorer
```

## More Information

- Full CI/CD documentation: See `CICD.md`
- Source code: https://github.com/nyan-lin-tun/CNCF-people-explorer
- Docker Hub: https://hub.docker.com/r/nyanlintun/cncf-people-explorer
