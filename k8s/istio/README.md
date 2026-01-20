# Istio Ambient Mode Deployment with Waypoint

Deploy CNCF People Explorer using Istio Ambient Mode with waypoint proxies for L7 traffic management.

## What is Istio Ambient Mode?

Istio Ambient Mode is a sidecar-less architecture that separates the data plane into:
- **ztunnel** (L4): Secure overlay layer handling mTLS and basic routing
- **waypoint proxy** (L7): Optional per-namespace proxy for advanced features like traffic routing, retries, timeouts

## Prerequisites

- Kubernetes cluster (1.27+)
- kubectl configured
- Helm 3.x

## Quick Start

### 1. Install Istio in Ambient Mode

```bash
# Add Istio Helm repository
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

# Install Istio base components
helm install istio-base istio/base -n istio-system --create-namespace

# Install Istio control plane (istiod)
helm install istiod istio/istiod -n istio-system --wait

# Install CNI plugin (for ambient mode)
helm install istio-cni istio/cni -n istio-system --wait

# Install ztunnel (ambient data plane)
helm install ztunnel istio/ztunnel -n istio-system --wait
```

### 2. Deploy CNCF People Explorer with Ambient Mode

```bash
# Deploy the application
kubectl apply -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/istio/ambient-deployment.yaml

# Enable ambient mode for the namespace
kubectl label namespace cncf-explorer istio.io/dataplane-mode=ambient

# Deploy waypoint proxy for L7 features
kubectl apply -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/istio/waypoint-gateway.yaml
```

### 3. Apply Traffic Management

```bash
# Apply virtual services and destination rules
kubectl apply -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/istio/traffic-management.yaml
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Istio Ambient Mode                        │
│                                                              │
│  ┌──────────────┐     ┌──────────────┐                      │
│  │   Internet   │────▶│ Istio Ingress│                      │
│  └──────────────┘     │   Gateway    │                      │
│                       └──────┬───────┘                       │
│                              │                               │
│                       ┌──────▼──────────┐                    │
│                       │ Waypoint Proxy  │ (L7 - Frontend)    │
│                       │  (Frontend)     │                    │
│                       └──────┬──────────┘                    │
│                              │                               │
│                       ┌──────▼──────────┐                    │
│                       │  Frontend Pods  │                    │
│                       │   (No Sidecar)  │                    │
│                       └──────┬──────────┘                    │
│                              │                               │
│                       ┌──────▼──────────┐                    │
│                       │ Waypoint Proxy  │ (L7 - Backend)     │
│                       │   (Backend)     │                    │
│                       └──────┬──────────┘                    │
│                              │                               │
│                       ┌──────▼──────────┐                    │
│                       │  Backend Pods   │                    │
│                       │   (No Sidecar)  │                    │
│                       └─────────────────┘                    │
│                                                              │
│  ztunnel handles L4 traffic (mTLS) for all pods             │
└─────────────────────────────────────────────────────────────┘
```

## Verify Deployment

### Check ztunnel is running

```bash
kubectl get pods -n istio-system -l app=ztunnel
```

### Check waypoint proxies

```bash
kubectl get gateway -n cncf-explorer
```

### Check if ambient mode is enabled

```bash
kubectl get namespace cncf-explorer -o jsonpath='{.metadata.labels.istio\.io/dataplane-mode}'
# Should output: ambient
```

### View pod annotations

```bash
kubectl get pod -n cncf-explorer -o yaml | grep -A5 "ambient.istio.io"
```

## Traffic Management Features

### 1. Canary Deployment (90/10 split)

Traffic routing with 90% to stable, 10% to canary:

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: frontend-canary
  namespace: cncf-explorer
spec:
  hosts:
  - cncf-frontend
  http:
  - match:
    - headers:
        user-agent:
          regex: ".*Chrome.*"
    route:
    - destination:
        host: cncf-frontend
        subset: v2
      weight: 10
    - destination:
        host: cncf-frontend
        subset: v1
      weight: 90
```

### 2. Circuit Breaking

Protect backend from overload:

```yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: backend-circuit-breaker
  namespace: cncf-explorer
spec:
  host: cncf-backend
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
      http:
        http1MaxPendingRequests: 50
        http2MaxRequests: 100
        maxRequestsPerConnection: 2
    outlierDetection:
      consecutiveErrors: 5
      interval: 30s
      baseEjectionTime: 30s
      maxEjectionPercent: 50
      minHealthPercent: 50
```

### 3. Retry and Timeout

Add resilience to backend calls:

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: backend-resilience
  namespace: cncf-explorer
spec:
  hosts:
  - cncf-backend
  http:
  - timeout: 10s
    retries:
      attempts: 3
      perTryTimeout: 3s
      retryOn: 5xx,reset,connect-failure,refused-stream
    route:
    - destination:
        host: cncf-backend
```

## Observability

### Access Kiali Dashboard

```bash
# Install Kiali
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/kiali.yaml

# Port forward
kubectl port-forward svc/kiali -n istio-system 20001:20001

# Visit: http://localhost:20001
```

### Access Prometheus

```bash
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/prometheus.yaml
kubectl port-forward svc/prometheus -n istio-system 9090:9090
```

### Access Grafana

```bash
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/grafana.yaml
kubectl port-forward svc/grafana -n istio-system 3000:3000
```

### View Metrics

```bash
# Get metrics from ztunnel
kubectl exec -n istio-system ds/ztunnel -c istio-proxy -- curl localhost:15020/stats/prometheus

# Get metrics from waypoint
kubectl exec -n cncf-explorer deploy/waypoint-frontend -c istio-proxy -- curl localhost:15020/stats/prometheus
```

## Security

### Enable mTLS (Automatic with Ambient)

Ambient mode automatically enables mTLS between pods via ztunnel. No configuration needed!

Verify mTLS:

```bash
# Install Istio's debugging tool
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/sleep/sleep.yaml -n cncf-explorer

# Check mTLS status
istioctl x describe pod -n cncf-explorer <frontend-pod-name>
```

### Authorization Policies

Restrict which services can communicate:

```yaml
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: frontend-only
  namespace: cncf-explorer
spec:
  selector:
    matchLabels:
      app: cncf-backend
  action: ALLOW
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/cncf-explorer/sa/cncf-frontend"]
```

## Migration from Sidecar to Ambient

If you have existing deployments with sidecars:

```bash
# 1. Label namespace for ambient
kubectl label namespace cncf-explorer istio.io/dataplane-mode=ambient

# 2. Remove sidecar injection label
kubectl label namespace cncf-explorer istio-injection-

# 3. Restart pods (sidecars will be removed, ztunnel takes over)
kubectl rollout restart deployment -n cncf-explorer
```

## Performance Comparison

### Ambient Mode Benefits:
- ✅ **Lower Resource Usage**: No sidecar containers per pod
- ✅ **Faster Startup**: Pods start immediately without waiting for sidecar
- ✅ **Simplified Operations**: No sidecar version management
- ✅ **Selective L7**: Only deploy waypoint where needed

### Resource Usage:
| Component | CPU (per pod) | Memory (per pod) |
|-----------|---------------|------------------|
| Sidecar (old) | ~100m | ~128Mi |
| ztunnel (shared) | ~50m | ~100Mi |
| Waypoint (per namespace) | ~100m | ~128Mi |

**Savings**: If you have 10 pods, ambient saves ~900m CPU and ~1.1Gi memory!

## Troubleshooting

### Check ztunnel logs

```bash
kubectl logs -n istio-system ds/ztunnel -c istio-proxy --tail=100 -f
```

### Check waypoint logs

```bash
kubectl logs -n cncf-explorer deploy/waypoint-frontend -c istio-proxy --tail=100 -f
```

### Verify traffic routing

```bash
# From within cluster
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- \
  curl -v http://cncf-frontend.cncf-explorer.svc.cluster.local
```

### Common Issues

**Issue**: Pods can't communicate
```bash
# Solution: Check if namespace is labeled
kubectl get namespace cncf-explorer --show-labels

# Should have: istio.io/dataplane-mode=ambient
```

**Issue**: Waypoint not routing traffic
```bash
# Check waypoint status
kubectl get gateway -n cncf-explorer

# Check if pods are using waypoint
kubectl get pods -n cncf-explorer -o yaml | grep waypoint
```

## Cleanup

```bash
# Remove application
kubectl delete namespace cncf-explorer

# Remove Istio
helm uninstall ztunnel -n istio-system
helm uninstall istio-cni -n istio-system
helm uninstall istiod -n istio-system
helm uninstall istio-base -n istio-system

# Remove namespace
kubectl delete namespace istio-system
```

## Additional Resources

- **Istio Ambient Docs**: https://istio.io/latest/docs/ambient/
- **Waypoint Guide**: https://istio.io/latest/docs/ambient/usage/waypoint/
- **Istio GitHub**: https://github.com/istio/istio
- **Our Repository**: https://github.com/nyan-lin-tun/CNCF-people-explorer

## Support

- GitHub Issues: https://github.com/nyan-lin-tun/CNCF-people-explorer/issues
- Istio Slack: https://slack.istio.io/
