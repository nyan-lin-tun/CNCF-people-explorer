# CNCF People Explorer

A Vue.js frontend that fetches the official CNCF `people.json` dataset and provides a fast, searchable directory of community members.

## 🌟 Live Demo

Visit the live application at: **https://nyan-lin-tun.github.io/CNCF-people-explorer/**

## ✨ Features
- 🔍 **Real-time Search** - Search across name, company, location, bio, and categories
- 🏢 **Smart Filters** - Filter by company and location
- 🌙 **Dark Mode** - Toggle with localStorage persistence and system preference detection
- 👤 **Profile Modal** - Click any card to view detailed information
- ⚡ **Lazy Loading** - Pagination for better performance (24 items per batch)
- 📱 **Mobile Responsive** - Optimized for all screen sizes
- 🏷️ **Category Badges** - Kubestronaut, Ambassador, and more
- 🔗 **Social Links** - LinkedIn, Twitter, GitHub, WeChat
- 🎨 **Modern UI** - Card-based grid layout with smooth animations

## 📦 Data Source
This project uses the public CNCF People API:

```
https://raw.githubusercontent.com/cncf/people/refs/heads/main/people.json
```

## 🚀 Getting Started

### Prerequisites
- Node.js 18+
- npm or yarn

### Install & Run

```bash
npm install
npm run dev
```

Open your browser at:
```
http://localhost:5173
```

## 🏗️ Build for Production

```bash
npm run build
```

The production files will be generated in the `dist/` folder.

## 🌐 Deploy to GitHub Pages
This project can be hosted on **GitHub Pages** using a static build and GitHub Actions.

Make sure your Vite config includes the correct base path:

```js
base: "/CNCF-people-explorer/",
```

Then enable **GitHub Pages → Source: GitHub Actions** in your repository settings.

## 🐳 Docker Deployment

### Quick Start

```bash
# Run standalone (uses CNCF API)
docker run -d -p 8080:80 nyanlintun/cncf-people-explorer:standalone

# Visit: http://localhost:8080
```

### Available Variants

- **`standalone`** - Uses CNCF API directly (no backend required)
- **`frontend`** - Connects to custom backend API
- **`example`** - Includes sample data for quick demos

See [DOCKER.md](./DOCKER.md) for complete documentation.

### Docker Compose

```bash
# Standalone deployment
docker-compose -f docker-compose.standalone.yml up

# Frontend with backend
docker-compose -f docker-compose.frontend.yml up
```

## ☸️ Kubernetes Deployment

### One-Command Deploy

Deploy complete stack (frontend + backend) to your cluster:

```bash
kubectl apply -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/complete-deployment.yaml
```

Or deploy standalone (no backend):

```bash
kubectl apply -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/standalone-deployment.yaml
```

### Get External IP

```bash
kubectl get svc -n cncf-explorer
```

See [k8s/README.md](./k8s/README.md) for complete Kubernetes documentation.

### Istio Ambient Mode (with Waypoint Proxies)

Deploy with Istio ambient mode for advanced traffic management:

```bash
# Install Istio ambient mode
./k8s/istio/install-istio-ambient.sh

# Deploy with ambient mode
kubectl apply -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/istio/ambient-deployment.yaml

# Deploy waypoint proxies (L7 features)
kubectl apply -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/istio/waypoint-gateway.yaml

# Apply traffic management
kubectl apply -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/istio/traffic-management.yaml
```

**Benefits:**
- ⚡ No sidecar containers (lower resource usage)
- 🔒 Automatic mTLS encryption
- 🎯 Advanced traffic routing (canary, A/B testing)
- 📊 Built-in observability with Kiali, Prometheus, Grafana

See [k8s/istio/README.md](./k8s/istio/README.md) for Istio documentation.

## 🛠️ Tech Stack
- Vue 3
- Vite
- JavaScript
- CNCF People API

## 📄 License
This project is open-source and available under the MIT License.