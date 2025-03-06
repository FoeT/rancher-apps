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
#echo "Creating IngressClass resources..."
#kubectl apply -f fleet/services/traefik-config/ingressclass.yaml

# Create middleware resources
#echo "Creating middleware resources..."
#kubectl apply -f fleet/services/traefik-config/middlewares.yaml

# Create persistent volume claim
echo "Creating persistent volume claim..."
kubectl patch pv pinas -p '{"spec":{"claimRef": null}}'
sleep 3
kubectl apply -f fleet/base/persistent-volumes.yaml

# Create placeholder for secrets (replace with actual secrets)
echo ""
echo "Secrets management:"
echo "- GitHub container registry: Automatically created from github-readonly-token"
echo "- Database secrets: Included in the YAML files in fleet/services/databases/"
echo ""

# Create Cloudflare token secret for cert-manager
echo "===== Cloudflare API Token Setup ====="
echo "Cert-Manager requires a Cloudflare API token for DNS validation when issuing TLS certificates."
echo "This is CRITICAL for wildcard certificates and proper HTTPS functionality."
echo ""
echo "To create a proper Cloudflare API token:"
echo "1. Log in to the Cloudflare dashboard (https://dash.cloudflare.com)"
echo "2. Navigate to My Profile > API Tokens"
echo "3. Click 'Create Token'"
echo "4. Either use the 'Edit zone DNS' template or create a custom token with these permissions:"
echo "   - Zone.Zone: Read"
echo "   - Zone.DNS: Edit"
echo "5. Set the token scope to allow access to ALL your domains:"
echo "   - Include ALL zones (domains) that need certificates:"
echo "     - mynetapp.site"
echo "     - coparentcare.com"
echo "     - [any other domains you host]"
echo "6. Set a reasonable TTL for the token (e.g., 6 months or 1 year)"
echo "7. Generate the token and SAVE IT SECURELY - it will only be shown once"
echo ""
echo "Then create the Kubernetes secret with your token:"
echo 'kubectl create secret generic cloudflare-token-secret --namespace=cert-manager --from-literal=cloudflare-token="YOUR-ACTUAL-TOKEN"'
echo ""
echo "To verify your certificates are working:"
echo "1. Check certificate status:"
echo "   kubectl get certificates -n weapps"
echo "2. If any show 'False' under READY, check the issues:"
echo "   kubectl describe certificate [certificate-name] -n weapps"
echo "3. To force renewal of an expired certificate:"
echo "   kubectl delete certificate [certificate-name] -n weapps"
echo "   kubectl apply -f fleet/services/cert-manager/certificates.yaml"
echo ""
echo "TROUBLESHOOTING CERTIFICATE ISSUES:"
echo "- If DNS01 challenges fail, verify your Cloudflare token has proper permissions"
echo "- For specific domains, use HTTP01 validation instead of DNS01 (see certificates.yaml)"
echo "- Check challenges status: kubectl get challenges.acme.cert-manager.io -n weapps"
echo "- For details: kubectl describe challenges.acme.cert-manager.io [challenge-name] -n weapps"
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
