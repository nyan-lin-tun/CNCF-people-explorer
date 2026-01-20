# Istio Ambient Mode: ztunnel vs ztunnel + Waypoint

This document explains the difference between deploying with **ztunnel only** (L4) and **ztunnel + waypoint** (L4 + L7).

## Quick Comparison

| Feature | ztunnel Only (Simple) | ztunnel + Waypoint (Advanced) |
|---------|----------------------|-------------------------------|
| **mTLS Encryption** | ✅ Automatic | ✅ Automatic |
| **Basic Routing** | ✅ Yes | ✅ Yes |
| **Service Discovery** | ✅ Yes | ✅ Yes |
| **Load Balancing** | ✅ Round-robin | ✅ Advanced (LEAST_REQUEST, etc.) |
| **Retries** | ❌ No | ✅ Yes |
| **Timeouts** | ❌ No | ✅ Yes |
| **Circuit Breaking** | ❌ No | ✅ Yes |
| **Traffic Splitting** | ❌ No | ✅ Yes (Canary, A/B) |
| **Header-based Routing** | ❌ No | ✅ Yes |
| **Fault Injection** | ❌ No | ✅ Yes |
| **Resource Usage** | 🟢 Lower | 🟡 Moderate |
| **Complexity** | 🟢 Simple | 🟡 More config |

## Architecture

### ztunnel Only (Simple)

```
┌─────────────────────────────────────┐
│      Istio Ambient Mode (L4)        │
│                                      │
│  Frontend Pod                        │
│       │                              │
│       ▼                              │
│   ztunnel (L4)                       │
│   • mTLS encryption                  │
│   • Basic routing                    │
│   • Load balancing                   │
│       │                              │
│       ▼                              │
│   ztunnel (L4)                       │
│       │                              │
│       ▼                              │
│  Backend Pod                         │
│                                      │
└─────────────────────────────────────┘
```

**Deploy with:**
```bash
kubectl apply -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/istio/ambient-deployment-simple.yaml
```

### ztunnel + Waypoint (Advanced)

```
┌─────────────────────────────────────┐
│   Istio Ambient Mode (L4 + L7)      │
│                                      │
│  Frontend Pod                        │
│       │                              │
│       ▼                              │
│   ztunnel (L4)                       │
│   • mTLS encryption                  │
│       │                              │
│       ▼                              │
│  Waypoint Backend (L7)               │
│   • Retries (3 attempts)             │
│   • Timeout (10s)                    │
│   • Circuit breaking                 │
│   • Traffic splitting                │
│   • Advanced routing                 │
│       │                              │
│       ▼                              │
│   ztunnel (L4)                       │
│       │                              │
│       ▼                              │
│  Backend Pod                         │
│                                      │
└─────────────────────────────────────┘
```

**Deploy with:**
```bash
kubectl apply -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/istio/ambient-deployment.yaml
kubectl apply -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/istio/waypoint-gateway.yaml
kubectl apply -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/istio/traffic-management.yaml
```

## What You Get with Each

### ztunnel Only - Features ✅

1. **Automatic mTLS** (STRICT mode)
   ```yaml
   # All pod-to-pod traffic is encrypted automatically
   spec:
     mtls:
       mode: STRICT
   ```

2. **Service Discovery** - Pods can find each other by service name

3. **Basic Load Balancing** - Round-robin by default

4. **Authorization Policies** - Control who can talk to who
   ```yaml
   # Frontend can access backend
   apiVersion: security.istio.io/v1beta1
   kind: AuthorizationPolicy
   ```

### ztunnel + Waypoint - Additional Features ✅

Everything from ztunnel, PLUS:

1. **Automatic Retries**
   ```yaml
   retries:
     attempts: 3
     perTryTimeout: 3s
     retryOn: 5xx,reset,connect-failure
   ```

2. **Timeouts**
   ```yaml
   timeout: 10s  # Prevent hanging requests
   ```

3. **Circuit Breaking**
   ```yaml
   outlierDetection:
     consecutiveErrors: 5
     baseEjectionTime: 30s  # Block unhealthy pods
   ```

4. **Traffic Splitting (Canary Deployments)**
   ```yaml
   route:
   - destination:
       host: backend
       subset: v2
     weight: 10  # 10% to new version
   - destination:
       host: backend
       subset: v1
     weight: 90  # 90% to stable version
   ```

5. **Advanced Load Balancing**
   ```yaml
   loadBalancer:
     simple: LEAST_REQUEST  # Send to least busy pod
   ```

6. **Header-based Routing**
   ```yaml
   match:
   - headers:
       user-agent:
         regex: ".*Chrome.*"
   ```

## Resource Usage

### Cluster with 10 Pods

**ztunnel Only:**
- ztunnel DaemonSet: ~50m CPU, ~100Mi Memory per node
- **Total for 3 nodes**: ~150m CPU, ~300Mi Memory

**ztunnel + Waypoint:**
- ztunnel DaemonSet: ~50m CPU, ~100Mi Memory per node
- waypoint-frontend: ~100m CPU, ~128Mi Memory
- waypoint-backend: ~100m CPU, ~128Mi Memory
- **Total for 3 nodes**: ~350m CPU, ~556Mi Memory

**Savings with ztunnel only**: ~200m CPU, ~256Mi Memory

## When to Use Each

### Use ztunnel Only (Simple) ✅

Choose this if:
- ✅ You want minimal overhead
- ✅ mTLS encryption is enough
- ✅ Your application handles retries internally
- ✅ You don't need traffic splitting
- ✅ You want simplicity over advanced features
- ✅ You're just getting started with Istio

**Example use cases:**
- Simple microservices
- Development/staging environments
- Applications with built-in resilience
- When you primarily need mTLS

### Use ztunnel + Waypoint (Advanced) ✅

Choose this if:
- ✅ You need automatic retries and timeouts
- ✅ You want circuit breaking for resilience
- ✅ You need canary deployments or A/B testing
- ✅ You want advanced traffic management
- ✅ You need header-based routing
- ✅ Production workloads requiring high resilience

**Example use cases:**
- Production environments
- External API calls that can fail
- Microservices with complex routing
- Applications requiring canary deployments
- Services needing circuit breakers

## Migration Path

### Start Simple, Add Waypoint Later

1. **Deploy with ztunnel only**
   ```bash
   kubectl apply -f k8s/istio/ambient-deployment-simple.yaml
   ```

2. **Test and verify mTLS works**
   ```bash
   istioctl x describe pod -n cncf-explorer <pod-name>
   ```

3. **Add waypoint when needed**
   ```bash
   # Deploy waypoint
   kubectl apply -f k8s/istio/waypoint-gateway.yaml

   # Add annotation to pods
   kubectl patch deployment cncf-backend -n cncf-explorer -p '
   {"spec":{"template":{"metadata":{"annotations":{"istio.io/use-waypoint":"waypoint-backend"}}}}}'

   # Apply traffic management
   kubectl apply -f k8s/istio/traffic-management.yaml
   ```

## Performance Impact

### Request Latency

**ztunnel Only:**
- Adds ~1-2ms latency per hop (mTLS encryption/decryption)

**ztunnel + Waypoint:**
- Adds ~2-4ms latency per hop (additional L7 processing)

For most applications, this overhead is negligible compared to application processing time.

## Our Recommendation for CNCF People Explorer

### Development/Testing: ztunnel Only ✨
```bash
kubectl apply -f k8s/istio/ambient-deployment-simple.yaml
```
- Lower resource usage
- Simpler to debug
- mTLS is enough

### Production: ztunnel + Waypoint ✨
```bash
kubectl apply -f k8s/istio/ambient-deployment.yaml
kubectl apply -f k8s/istio/waypoint-gateway.yaml
kubectl apply -f k8s/istio/traffic-management.yaml
```
- Retries for flaky networks
- Circuit breaker protects backend
- Canary deployments for zero-downtime updates
- Better observability

## Verification

### Check What's Running

**ztunnel Only:**
```bash
kubectl get pods -n istio-system
# Should see: ztunnel pods only

kubectl get pods -n cncf-explorer
# Should see: frontend and backend pods (no waypoint)
```

**ztunnel + Waypoint:**
```bash
kubectl get pods -n istio-system
# Should see: ztunnel pods + istiod

kubectl get gateway -n cncf-explorer
# Should see: waypoint-frontend, waypoint-backend

kubectl get pods -n cncf-explorer
# Should see: frontend, backend, waypoint pods
```

### Check mTLS Status (Both)

```bash
# Install test pod
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/sleep/sleep.yaml -n cncf-explorer

# Check mTLS
istioctl x describe pod -n cncf-explorer <frontend-pod-name>
# Should show: "mTLS: STRICT"
```

## Summary

| Scenario | Recommendation |
|----------|----------------|
| **Getting Started** | ztunnel only |
| **Dev/Test** | ztunnel only |
| **Production** | ztunnel + waypoint |
| **Low-stakes apps** | ztunnel only |
| **Critical services** | ztunnel + waypoint |
| **Need canary** | ztunnel + waypoint |
| **Simple architecture** | ztunnel only |
| **Minimize cost** | ztunnel only |

## Next Steps

Choose your deployment:

**Simple (ztunnel only):**
```bash
kubectl apply -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/istio/ambient-deployment-simple.yaml
```

**Advanced (ztunnel + waypoint):**
```bash
kubectl apply -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/istio/ambient-deployment.yaml
kubectl apply -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/istio/waypoint-gateway.yaml
kubectl apply -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/istio/traffic-management.yaml
```

Both are production-ready! Choose based on your needs. 🚀
