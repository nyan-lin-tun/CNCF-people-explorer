#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Installing Istio Ambient Mode${NC}"
echo -e "${GREEN}========================================${NC}"

# Check prerequisites
echo -e "\n${YELLOW}Checking prerequisites...${NC}"

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}kubectl not found. Please install kubectl first.${NC}"
    exit 1
fi

if ! command -v helm &> /dev/null; then
    echo -e "${RED}helm not found. Please install Helm 3.x first.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Prerequisites met${NC}"

# Add Istio Helm repository
echo -e "\n${YELLOW}Adding Istio Helm repository...${NC}"
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
echo -e "${GREEN}✓ Istio repository added${NC}"

# Install Istio base components
echo -e "\n${YELLOW}Installing Istio base components...${NC}"
helm install istio-base istio/base -n istio-system --create-namespace --wait
echo -e "${GREEN}✓ Istio base installed${NC}"

# Install Istio control plane (istiod)
echo -e "\n${YELLOW}Installing Istio control plane (istiod)...${NC}"
helm install istiod istio/istiod -n istio-system --wait
echo -e "${GREEN}✓ istiod installed${NC}"

# Install CNI plugin (required for ambient mode)
echo -e "\n${YELLOW}Installing Istio CNI plugin...${NC}"
helm install istio-cni istio/cni -n istio-system --wait
echo -e "${GREEN}✓ CNI plugin installed${NC}"

# Install ztunnel (ambient data plane)
echo -e "\n${YELLOW}Installing ztunnel (ambient data plane)...${NC}"
helm install ztunnel istio/ztunnel -n istio-system --wait
echo -e "${GREEN}✓ ztunnel installed${NC}"

# Verify installation
echo -e "\n${YELLOW}Verifying Istio installation...${NC}"
kubectl get pods -n istio-system

# Wait for all pods to be ready
echo -e "\n${YELLOW}Waiting for all Istio components to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app=istiod -n istio-system --timeout=300s
kubectl wait --for=condition=ready pod -l app=ztunnel -n istio-system --timeout=300s

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Istio Ambient Mode installed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"

echo -e "\n${YELLOW}Next steps:${NC}"
echo -e "1. Deploy your application:"
echo -e "   ${GREEN}kubectl apply -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/istio/ambient-deployment.yaml${NC}"
echo -e "\n2. Deploy waypoint proxies:"
echo -e "   ${GREEN}kubectl apply -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/istio/waypoint-gateway.yaml${NC}"
echo -e "\n3. Apply traffic management:"
echo -e "   ${GREEN}kubectl apply -f https://raw.githubusercontent.com/nyan-lin-tun/CNCF-people-explorer/main/k8s/istio/traffic-management.yaml${NC}"
echo -e "\n4. Check the deployment:"
echo -e "   ${GREEN}kubectl get pods -n cncf-explorer${NC}"
echo -e "   ${GREEN}kubectl get gateway -n cncf-explorer${NC}"
echo -e "\n${YELLOW}For observability, install Kiali, Prometheus, and Grafana:${NC}"
echo -e "   ${GREEN}kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/kiali.yaml${NC}"
echo -e "   ${GREEN}kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/prometheus.yaml${NC}"
echo -e "   ${GREEN}kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/grafana.yaml${NC}"
