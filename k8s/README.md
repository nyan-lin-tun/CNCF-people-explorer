# Kubernetes Deployment Guide

Deploy CNCF People Explorer to your Kubernetes cluster with a single command.

## Quick Deploy Options

### Option 1: Complete Stack (Frontend + Backend) - Recommended

Deploy both frontend and backend in one command:

```bash
kubectl apply -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/complete-deployment.yaml
```

**What this deploys:**
- ✅ Backend API (2 replicas)
- ✅ Frontend (3 replicas)
- ✅ Internal services
- ✅ LoadBalancer for external access
- ✅ HorizontalPodAutoscalers for both

### Option 2: Standalone (No Backend Required)

Deploy frontend only (uses CNCF API directly):

```bash
kubectl apply -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/standalone-deployment.yaml
```

**What this deploys:**
- ✅ Standalone frontend (3 replicas)
- ✅ LoadBalancer service
- ✅ HorizontalPodAutoscaler

## Access Your Deployment

### Get the External IP

```bash
# For complete stack
kubectl get svc -n cncf-explorer cncf-frontend

# For standalone
kubectl get svc -n cncf-explorer cncf-explorer
```

Wait for `EXTERNAL-IP` to be assigned (may take 1-2 minutes), then visit:
```
http://<EXTERNAL-IP>
```

### Port-forward (Alternative)

If LoadBalancer is pending or you want to test locally:

```bash
# For complete stack
kubectl port-forward -n cncf-explorer svc/cncf-frontend 8080:80

# For standalone
kubectl port-forward -n cncf-explorer svc/cncf-explorer 8080:80
```

Visit: http://localhost:8080

## Deployment Details

### Complete Stack Architecture

```
┌─────────────┐
│   Internet  │
└──────┬──────┘
       │
┌──────▼──────────────┐
│   LoadBalancer      │
│   (cncf-frontend)   │
└──────┬──────────────┘
       │
┌──────▼──────────────┐
│  Frontend Pods (3x) │
│  Port: 80           │
└──────┬──────────────┘
       │
┌──────▼──────────────┐
│  Backend Service    │
│  (ClusterIP)        │
└──────┬──────────────┘
       │
┌──────▼──────────────┐
│  Backend Pods (2x)  │
│  Port: 3000         │
└─────────────────────┘
```

### Resource Requirements

#### Per Frontend Pod:
- **Requests**: 50m CPU, 64Mi Memory
- **Limits**: 200m CPU, 128Mi Memory

#### Per Backend Pod:
- **Requests**: 100m CPU, 128Mi Memory
- **Limits**: 500m CPU, 256Mi Memory

#### Total Cluster Requirements (Complete Stack):
- **Minimum**: 350m CPU, 448Mi Memory
- **Recommended**: 1 CPU, 1Gi Memory (for headroom + autoscaling)

## Configuration

### Environment Variables

The complete stack automatically configures:
```yaml
VITE_API_URL: "http://cncf-backend:3000/api/people"
```

### Customize Replicas

Edit the deployment:
```bash
kubectl edit deployment -n cncf-explorer cncf-frontend
# Change spec.replicas to your desired count
```

Or scale directly:
```bash
kubectl scale deployment -n cncf-explorer cncf-frontend --replicas=5
```

### Enable Ingress (Optional)

1. Edit `complete-deployment.yaml`
2. Uncomment the Ingress section
3. Update `host` field with your domain
4. Apply:
```bash
kubectl apply -f k8s/complete-deployment.yaml
```

## Monitoring

### Check Pod Status

```bash
kubectl get pods -n cncf-explorer
```

### View Logs

```bash
# Frontend logs
kubectl logs -n cncf-explorer -l app=cncf-frontend --tail=50 -f

# Backend logs
kubectl logs -n cncf-explorer -l app=cncf-backend --tail=50 -f
```

### Check HPA Status

```bash
kubectl get hpa -n cncf-explorer
```

### Describe Deployments

```bash
kubectl describe deployment -n cncf-explorer cncf-frontend
kubectl describe deployment -n cncf-explorer cncf-backend
```

## Updating

### Update to Latest Version

```bash
# Update frontend
kubectl set image deployment/cncf-frontend -n cncf-explorer \
  frontend=nyanlintun/cncf-people-explorer:frontend

# Update backend
kubectl set image deployment/cncf-backend -n cncf-explorer \
  backend=nyanlintun/cncf-people-api:latest
```

### Update to Specific Version

```bash
kubectl set image deployment/cncf-frontend -n cncf-explorer \
  frontend=nyanlintun/cncf-people-explorer:frontend-v0.1.0
```

### Rollback

```bash
kubectl rollout undo deployment/cncf-frontend -n cncf-explorer
```

## Cleanup

### Delete Complete Stack

```bash
kubectl delete namespace cncf-explorer
```

Or delete specific resources:
```bash
kubectl delete -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/complete-deployment.yaml
```

## Troubleshooting

### Pods Not Starting

```bash
kubectl describe pod -n cncf-explorer <pod-name>
kubectl logs -n cncf-explorer <pod-name>
```

### Service Not Accessible

1. Check service:
```bash
kubectl get svc -n cncf-explorer
```

2. Check endpoints:
```bash
kubectl get endpoints -n cncf-explorer
```

3. Test internal connectivity:
```bash
kubectl run -it --rm debug --image=busybox --restart=Never -n cncf-explorer -- wget -O- http://cncf-frontend
```

### Image Pull Errors

Check image availability:
```bash
docker pull nyanlintun/cncf-people-explorer:frontend
docker pull nyanlintun/cncf-people-api:latest
```

## Production Recommendations

### 1. Use Specific Versions

Replace `:latest` and `:frontend` with version tags:
```yaml
image: nyanlintun/cncf-people-explorer:frontend-v0.1.0
image: nyanlintun/cncf-people-api:v1.0.0
```

### 2. Enable Ingress with TLS

Use cert-manager for automatic SSL certificates:
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
```

### 3. Add Resource Quotas

Create a ResourceQuota for the namespace:
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: cncf-explorer-quota
  namespace: cncf-explorer
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 4Gi
    limits.cpu: "8"
    limits.memory: 8Gi
```

### 4. Set Up Monitoring

Deploy Prometheus and Grafana to monitor your cluster.

### 5. Configure Network Policies

Restrict traffic between pods:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-network-policy
  namespace: cncf-explorer
spec:
  podSelector:
    matchLabels:
      app: cncf-backend
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: cncf-frontend
```

## Cloud Provider Specific Notes

### Google Kubernetes Engine (GKE)

```bash
gcloud container clusters create cncf-explorer \
  --num-nodes=3 \
  --machine-type=e2-medium \
  --zone=us-central1-a

kubectl apply -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/complete-deployment.yaml
```

### Amazon EKS

```bash
eksctl create cluster \
  --name cncf-explorer \
  --region us-east-1 \
  --nodes 3 \
  --node-type t3.medium

kubectl apply -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/complete-deployment.yaml
```

### Azure AKS

```bash
az aks create \
  --resource-group myResourceGroup \
  --name cncf-explorer \
  --node-count 3 \
  --node-vm-size Standard_B2s

kubectl apply -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/complete-deployment.yaml
```

### DigitalOcean Kubernetes

```bash
doctl kubernetes cluster create cncf-explorer \
  --count 3 \
  --size s-2vcpu-2gb \
  --region nyc1

kubectl apply -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/complete-deployment.yaml
```

## Support

- **GitHub Issues**: https://github.com/nyan-lin-tun/CNCF-people-explorer/issues
- **Documentation**: https://github.com/nyan-lin-tun/CNCF-people-explorer
- **Docker Hub**: https://hub.docker.com/r/nyanlintun/cncf-people-explorer

## License

MIT License - See [LICENSE](https://github.com/nyan-lin-tun/CNCF-people-explorer/blob/main/LICENSE) for details.
