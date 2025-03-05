#!/bin/bash

# Fleet Setup Script
echo "===== Fleet Applications Setup ====="

# Create the weapps namespace if it doesn't exist
echo "Creating weapps namespace..."
kubectl create namespace weapps --dry-run=client -o yaml | kubectl apply -f -

# Try to get GitHub token from kubernetes secret
if kubectl get secret -n fleet-local github-readonly-token &>/dev/null; then
  echo "Getting GitHub token from Kubernetes secret..."
  READ_ONLY_TOKEN=$(kubectl get secret -n fleet-local github-readonly-token -o jsonpath='{.data.token}' | base64 -d)
  
  # Create/update the github-container-registry secret
  echo "Updating GitHub container registry secret..."
  kubectl create secret docker-registry github-container-registry \
    --namespace weapps \
    --docker-server=ghcr.io \
    --docker-username=FoeT \
    --docker-password=${READ_ONLY_TOKEN} \
    --docker-email=forrest.thurgood@gmail.com \
    --dry-run=client -o yaml | kubectl apply -f -
else
  echo "WARNING: GitHub token not found in Kubernetes secret."
  echo "Some container images may not be accessible without a valid token."
  echo "To create the token secret, run:"
  echo "kubectl create secret generic github-readonly-token -n fleet-local --from-literal=token=YOUR_TOKEN"
fi

# Create IngressClass resources for K3s Traefik
echo "Creating IngressClass resources..."
kubectl apply -f fleet/services/traefik-config/ingressclass.yaml

# Create middleware resources
echo "Creating middleware resources..."
kubectl apply -f fleet/services/traefik-config/middlewares.yaml

# Create persistent volume claim
echo "Creating persistent volume claim..."
kubectl patch pv pinas -p '{"spec":{"claimRef": null}}'
kubectl apply -f fleet/base/persistent-volumes.yaml

# Create placeholder for secrets (replace with actual secrets)
echo ""
echo "Secrets management:"
echo "- GitHub container registry: Automatically created from github-readonly-token"
echo "- Database secrets: Included in the YAML files in fleet/services/databases/"
echo ""

# Create Cloudflare token secret for cert-manager
echo "To create the Cloudflare token secret for cert-manager, run:"
echo 'kubectl create secret generic cloudflare-token-secret --namespace=cert-manager --from-literal=cloudflare-token="your-cloudflare-api-token"'
echo ""

# Deploy static workloads (not managed by Fleet)
echo "Deploying static workloads..."
echo "- Deploying PiHole..."
#kubectl apply -f static/pihole/deployment.yaml

# Apply the Fleet GitRepo configuration
echo "You can now apply this configuration to your Fleet using:"
echo "  ./fleet-repo.sh"
echo "Note: Bundle names will be created with the prefix 'rancher-apps-fleet-',"
echo "  so any dependsOn references in fleet.yaml files should use the full name"
echo "  (e.g. rancher-apps-fleet-services-cert-manager, not rancher-apps-services-cert-manager)"

echo "===== Setup Complete ====="
