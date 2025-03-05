#!/bin/bash

# Fleet Setup Script
echo "===== Fleet Applications Setup ====="

# Create the weapps namespace if it doesn't exist
echo "Creating weapps namespace..."
kubectl create namespace weapps --dry-run=client -o yaml | kubectl apply -f -

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
echo "You need to create actual secrets before deploying applications"
echo "To create the github container registry secret, run:"
echo 'kubectl create secret docker-registry github-container-registry --namespace=weapps --docker-server=ghcr.io --docker-username=YOUR_USERNAME --docker-password=YOUR_PAT --docker-email=YOUR_EMAIL'
echo ""
./new_git_pull.sh
# Database secrets note
echo "NOTE: Database secrets are included in the YAML files. If you need to modify them, edit the files in services/databases/"
echo ""

# Create Cloudflare token secret for cert-manager
echo "To create the Cloudflare token secret for cert-manager, run:"
echo 'kubectl create secret generic cloudflare-token-secret --namespace=cert-manager --from-literal=cloudflare-token="your-cloudflare-api-token"'
echo ""

# Deploy static workloads (not managed by Fleet)
echo "Deploying static workloads..."
echo "- Deploying PiHole..."
kubectl apply -f static/pihole/deployment.yaml

# Apply the Fleet GitRepo configuration
echo "You can now apply this configuration to your Fleet using:"
echo "  kubectl apply -f fleet-repo.yaml"

echo "===== Setup Complete ====="
