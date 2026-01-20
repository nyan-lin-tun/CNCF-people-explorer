# CI/CD Pipeline Documentation

## Overview

This project uses GitHub Actions for continuous integration and deployment with two separate workflows:

1. **GitHub Pages Deployment** - Deploys on every push to `main`
2. **Docker Multi-Variant Build** - Builds 4 Docker images on git tags/releases

---

## 1. GitHub Pages Deployment

### Trigger
- **Event:** Push to `main` branch
- **Workflow:** `.github/workflows/deploy.yml`

### Process
```
Push to main
    ↓
GitHub Actions triggers
    ↓
Install dependencies (npm ci)
    ↓
Build static files (npm run build)
    ↓
Deploy to GitHub Pages
    ↓
Live at: https://nyan-lin-tun.github.io/CNCF-people-explorer/
```

### Build Time
- ~12-15 seconds (lightweight static build)
- Free tier: 2000 minutes/month

### Configuration
- **Base Path:** `/CNCF-people-explorer/` (configured in `vite.config.js`)
- **Output:** `dist/` folder with static HTML, CSS, JS
- **Source:** GitHub Actions (not branch-based deployment)

---

## 2. Docker Multi-Variant Build

### Trigger
- **Event:** Git tags matching `v*` (e.g., `v1.0.0`, `v1.2.3-beta`)
- **Workflow:** `.github/workflows/docker-build.yml`

### Docker Hub Images

All images published to: `nyanlintun/cncf-people-explorer:<variant>`

#### Variant 1: `standalone`
```
nyanlintun/cncf-people-explorer:standalone
nyanlintun/cncf-people-explorer:standalone-v1.0.0
```

**Purpose:** Production-ready, fetches data from CNCF API directly

**Data Source:** `https://raw.githubusercontent.com/cncf/people/refs/heads/main/people.json`

**Usage:**
```bash
docker pull nyanlintun/cncf-people-explorer:standalone
docker run -p 8080:80 nyanlintun/cncf-people-explorer:standalone
```

**Use Cases:**
- Quick demos without backend
- Testing with real CNCF data
- Standalone deployments


#### Variant 2: `local`
```
nyanlintun/cncf-people-explorer:local
nyanlintun/cncf-people-explorer:local-v1.0.0
```

**Purpose:** Local development/testing with cached data

**Data Source:** Data file included in container at `/usr/share/nginx/html/data/people.json`

**Usage:**
```bash
# Run with built-in data
docker run -p 8080:80 nyanlintun/cncf-people-explorer:local

# Or mount your own data
docker run -p 8080:80 \
  -v $(pwd)/custom-data.json:/usr/share/nginx/html/data/people.json:ro \
  nyanlintun/cncf-people-explorer:local
```

**Use Cases:**
- Offline development
- Testing with custom datasets
- Air-gapped environments


#### Variant 3: `frontend`
```
nyanlintun/cncf-people-explorer:frontend
nyanlintun/cncf-people-explorer:frontend-v1.0.0
```

**Purpose:** Frontend that connects to custom backend API

**Data Source:** Configurable backend API URL via environment variable

**Usage:**
```bash
docker run -p 8080:80 \
  -e VITE_API_URL=https://your-backend.com/api/people \
  nyanlintun/cncf-people-explorer:frontend
```

**Docker Compose Example:**
```yaml
version: '3.8'
services:
  frontend:
    image: nyanlintun/cncf-people-explorer:frontend
    ports:
      - "8080:80"
    environment:
      - VITE_API_URL=http://backend:3000/api/people

  backend:
    image: your-backend-image
    ports:
      - "3000:3000"
```

**Use Cases:**
- Full-stack deployment
- Custom backend integration
- Production with your own API


#### Variant 4: `example`
```
nyanlintun/cncf-people-explorer:example
nyanlintun/cncf-people-explorer:example-v1.0.0
```

**Purpose:** Lightweight demo with sample data (5-10 people)

**Data Source:** Hardcoded sample data in `public/data/example-data.json`

**Usage:**
```bash
docker pull nyanlintun/cncf-people-explorer:example
docker run -p 8080:80 nyanlintun/cncf-people-explorer:example
```

**Use Cases:**
- Quick demos (starts in <1 second)
- CI/CD testing
- Documentation examples
- Trade show demos

---

## Build Process

### On Git Tag Push

```bash
# Example: Create and push a new release tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

### GitHub Actions Workflow

```
Tag pushed (v1.0.0)
    ↓
GitHub Actions triggers
    ↓
Build 4 variants in parallel:
    ├── standalone (build-arg: MODE=standalone)
    ├── local (build-arg: MODE=local)
    ├── frontend (build-arg: MODE=frontend)
    └── example (build-arg: MODE=example)
    ↓
Tag images with:
    ├── latest tag (e.g., standalone)
    └── version tag (e.g., standalone-v1.0.0)
    ↓
Push to Docker Hub: nyanlintun/cncf-people-explorer
    ↓
✅ All 4 variants available
```

### Build Time Estimate
- Total: ~3-4 minutes for all 4 variants (parallel)
- Per variant: ~45-60 seconds
- Runs only on tags (not every push)

---

## Docker Image Details

### Base Image
- **Base:** `nginx:alpine` (~7MB)
- **Final Size:** ~25-30MB per variant
- **Architecture:** Multi-stage build for optimization

### Multi-Stage Build
```dockerfile
Stage 1: Build (node:20-alpine)
  ├── Install dependencies
  ├── Build Vue app based on MODE
  └── Output: dist/

Stage 2: Production (nginx:alpine)
  ├── Copy built files from Stage 1
  ├── Copy nginx config
  └── Final image: ~25MB
```

### Exposed Port
- **Port:** 80 (nginx)
- **Protocol:** HTTP

---

## CI/CD Resource Usage

### GitHub Actions Minutes (Free Tier: 2000/month)

**Per deployment:**
- GitHub Pages: ~0.3 minutes (every push to main)
- Docker builds: ~4 minutes (only on tags)

**Monthly estimate:**
- 50 pushes to main: ~15 minutes
- 4 releases/month: ~16 minutes
- **Total:** ~31 minutes/month (~1.5% of free tier)

---

## Secrets & Environment Variables

### Required GitHub Secrets

Configure in: `Settings → Secrets and variables → Actions`

1. **`DOCKER_HUB_USERNAME`**
   - Value: `nyanlintun`
   - Used for: Docker Hub login

2. **`DOCKER_HUB_TOKEN`**
   - Value: Your Docker Hub access token
   - Create at: https://hub.docker.com/settings/security
   - Permissions: Read, Write, Delete

### Environment Variables (Runtime)

#### For `frontend` variant:
- `VITE_API_URL` - Your backend API endpoint (required)

#### For `local` variant:
- No environment variables needed (data included)

#### For `standalone` variant:
- No environment variables needed (uses CNCF API)

#### For `example` variant:
- No environment variables needed (hardcoded data)

---

## Release Process

### 1. Prepare Release
```bash
# Ensure you're on main with latest changes
git checkout main
git pull origin main

# Update version in package.json (optional)
npm version patch  # or minor, major

# Test locally
npm run build
npm run preview
```

### 2. Create Tag
```bash
# Create annotated tag
git tag -a v1.0.0 -m "Release v1.0.0: Add new features"

# Push tag to trigger Docker build
git push origin v1.0.0
```

### 3. Monitor Build
```bash
# Watch GitHub Actions
gh run watch

# Or visit: https://github.com/nyan-lin-tun/CNCF-people-explorer/actions
```

### 4. Verify Images
```bash
# Check Docker Hub
# Visit: https://hub.docker.com/r/nyanlintun/cncf-people-explorer/tags

# Or pull and test locally
docker pull nyanlintun/cncf-people-explorer:standalone-v1.0.0
docker run -p 8080:80 nyanlintun/cncf-people-explorer:standalone-v1.0.0
```

---

## Local Testing

### Test Docker Builds Locally

```bash
# Build standalone variant
docker build --build-arg MODE=standalone -t cncf-explorer:standalone .

# Build local variant
docker build --build-arg MODE=local -t cncf-explorer:local .

# Build frontend variant
docker build --build-arg MODE=frontend -t cncf-explorer:frontend .

# Build example variant
docker build --build-arg MODE=example -t cncf-explorer:example .

# Run any variant
docker run -p 8080:80 cncf-explorer:standalone
```

### Test with Docker Compose

```bash
# Standalone
docker-compose -f docker-compose.standalone.yml up

# Local
docker-compose -f docker-compose.local.yml up

# Frontend (with mock backend)
docker-compose -f docker-compose.frontend.yml up

# Example
docker-compose -f docker-compose.example.yml up
```

---

## Deployment Options

### Option 1: GitHub Pages (Current)
- ✅ Free
- ✅ Automatic on push
- ✅ CDN included
- ❌ Static only
- **URL:** https://nyan-lin-tun.github.io/CNCF-people-explorer/

### Option 2: Docker on Cloud Run (Google)
```bash
# Deploy standalone variant
gcloud run deploy cncf-explorer \
  --image nyanlintun/cncf-people-explorer:standalone \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

### Option 3: Docker on Fly.io
```bash
# fly.toml already configured
fly deploy --image nyanlintun/cncf-people-explorer:standalone
```

### Option 4: Docker on AWS ECS/Fargate
- Use `frontend` variant with ALB
- Connect to RDS/DynamoDB backend
- Auto-scaling enabled

### Option 5: Kubernetes
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cncf-explorer
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: frontend
        image: nyanlintun/cncf-people-explorer:frontend
        env:
        - name: VITE_API_URL
          value: "http://backend-service/api/people"
```

---

## Monitoring & Analytics

### GitHub Pages Analytics

**Google Analytics 4** integrated via `gtag.js`

**Tracking ID:** `G-XXXXXXXXXX` (configured in `index.html`)

**Metrics tracked:**
- Page views
- User sessions
- Search queries (custom event)
- Filter usage (custom event)
- Social link clicks (custom event)

**Dashboard:** https://analytics.google.com

### Docker Container Logs

```bash
# View logs
docker logs <container-id>

# Follow logs
docker logs -f <container-id>

# With timestamps
docker logs -t <container-id>
```

---

## Troubleshooting

### GitHub Pages not updating
```bash
# Check workflow status
gh run list --limit 5

# View specific run
gh run view <run-id>

# Clear cache and rebuild
git commit --allow-empty -m "Trigger rebuild"
git push
```

### Docker build fails
```bash
# Check workflow logs
gh run view --log-failed

# Test build locally
docker build --no-cache -t test .
```

### Docker image too large
```bash
# Check image size
docker images nyanlintun/cncf-people-explorer

# Analyze layers
docker history nyanlintun/cncf-people-explorer:standalone

# Expected size: ~25-30MB
```

---

## Security

### Docker Hub Access Token
- ✅ Use access tokens (not password)
- ✅ Scoped to read/write only
- ✅ Rotate every 90 days
- ✅ Never commit tokens to repo

### Container Security
- ✅ Non-root user in container
- ✅ Read-only filesystem where possible
- ✅ No secrets in image
- ✅ Regular base image updates (alpine)

### GitHub Actions Security
- ✅ Secrets encrypted at rest
- ✅ Only accessible during workflow
- ✅ Audit logs available
- ✅ Branch protection rules enabled

---

## Future Enhancements

- [ ] Add health check endpoints
- [ ] Implement container scanning (Trivy)
- [ ] Add performance monitoring
- [ ] Set up automated security updates
- [ ] Add Helm charts for Kubernetes
- [ ] Implement blue-green deployments
- [ ] Add smoke tests after deployment
- [ ] Create staging environment

---

## Support

**Repository:** https://github.com/nyan-lin-tun/CNCF-people-explorer

**Issues:** https://github.com/nyan-lin-tun/CNCF-people-explorer/issues

**Docker Hub:** https://hub.docker.com/r/nyanlintun/cncf-people-explorer

**Live Demo:** https://nyan-lin-tun.github.io/CNCF-people-explorer/
