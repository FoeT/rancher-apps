#!/bin/bash

# Certificate Renewal Script
echo "===== TLS Certificate Renewal Tool ====="

# Check if arguments are provided
if [ $# -eq 0 ]; then
  # No arguments, show all certificates
  echo "Checking all TLS certificates..."
  kubectl get certificates -n weapps
  echo ""
  echo "Usage:"
  echo "  $0 list                 - List all certificates and their status"
  echo "  $0 renew <cert-name>    - Renew a specific certificate"
  echo "  $0 renew-all            - Renew all certificates"
  echo "  $0 check <cert-name>    - Check details of a specific certificate"
  echo "  $0 verify-token         - Verify Cloudflare API token permissions"
  echo "  $0 update-token         - Update the Cloudflare API token"
  echo ""
  exit 0
fi

case "$1" in
  list)
    echo "Listing all TLS certificates:"
    echo "----------------------------"
    kubectl get certificates -n weapps
    echo ""
    kubectl get secrets -n weapps | grep tls
    ;;
    
  renew)
    if [ -z "$2" ]; then
      echo "Error: Certificate name required"
      echo "Usage: $0 renew <certificate-name>"
      exit 1
    fi
    
    echo "Renewing certificate: $2"
    echo "------------------------"
    echo "1. Deleting existing certificate..."
    kubectl delete certificate "$2" -n weapps
    
    echo "2. Reapplying certificate definition..."
    kubectl apply -f fleet/services/cert-manager/certificates.yaml
    
    echo "3. Checking certificate status..."
    sleep 5
    kubectl get certificate "$2" -n weapps
    ;;
    
  renew-all)
    echo "Renewing ALL certificates"
    echo "-----------------------"
    echo "1. Backing up current certificates..."
    kubectl get certificates -n weapps -o yaml > cert-backup-$(date +%Y%m%d%H%M%S).yaml
    
    echo "2. Deleting all certificates..."
    kubectl delete certificates --all -n weapps
    
    echo "3. Reapplying certificate definitions..."
    kubectl apply -f fleet/services/cert-manager/certificates.yaml
    
    echo "4. Checking certificate status..."
    sleep 5
    kubectl get certificates -n weapps
    ;;
    
  check)
    if [ -z "$2" ]; then
      echo "Error: Certificate name required"
      echo "Usage: $0 check <certificate-name>"
      exit 1
    fi
    
    echo "Checking certificate: $2"
    echo "----------------------"
    kubectl describe certificate "$2" -n weapps
    
    # Get CertificateRequest name
    CR_NAME=$(kubectl get certificaterequest -n weapps | grep "$2" | awk '{print $1}' | head -1)
    
    if [ -n "$CR_NAME" ]; then
      echo ""
      echo "Certificate Request details:"
      echo "--------------------------"
      kubectl describe certificaterequest "$CR_NAME" -n weapps
      
      # Check for challenges
      CHALLENGE=$(kubectl get challenges.acme.cert-manager.io -n weapps | grep "$CR_NAME" | awk '{print $1}' | head -1)
      
      if [ -n "$CHALLENGE" ]; then
        echo ""
        echo "Challenge details:"
        echo "----------------"
        kubectl describe challenges.acme.cert-manager.io "$CHALLENGE" -n weapps
      fi
    fi
    ;;
    
  verify-token)
    echo "Verifying Cloudflare API token"
    echo "----------------------------"
    echo "1. Checking if token secret exists..."
    if kubectl get secret cloudflare-token-secret -n cert-manager &>/dev/null; then
      echo "✅ Token secret exists in cert-manager namespace"
      
      echo "2. Checking issuers configuration..."
      PROD_ISSUER=$(kubectl get clusterissuer letsencrypt-production -o jsonpath='{.status.conditions[0].status}')
      STAGING_ISSUER=$(kubectl get clusterissuer letsencrypt-staging -o jsonpath='{.status.conditions[0].status}')
      
      if [ "$PROD_ISSUER" == "True" ]; then
        echo "✅ Production issuer is ready"
      else
        echo "❌ Production issuer is not ready"
        kubectl describe clusterissuer letsencrypt-production
      fi
      
      if [ "$STAGING_ISSUER" == "True" ]; then
        echo "✅ Staging issuer is ready"
      else
        echo "❌ Staging issuer is not ready"
        kubectl describe clusterissuer letsencrypt-staging
      fi
      
      echo ""
      echo "NOTE: If issuers are not ready, the Cloudflare token may not have correct permissions."
      echo "You should create a new token with Zone.Zone:Read and Zone.DNS:Edit permissions"
      echo "for ALL required domains (mynetapp.site, coparentcare.com, etc.)"
    else
      echo "❌ Cloudflare token secret not found!"
      echo "Create it with:"
      echo 'kubectl create secret generic cloudflare-token-secret --namespace=cert-manager --from-literal=cloudflare-token="YOUR-ACTUAL-TOKEN"'
    fi
    ;;
    
  update-token)
    echo "Updating Cloudflare API token"
    echo "--------------------------"
    echo "Enter your new Cloudflare API token:"
    read -s CF_TOKEN
    
    if [ -z "$CF_TOKEN" ]; then
      echo "Error: Token cannot be empty"
      exit 1
    fi
    
    echo "1. Deleting existing token secret..."
    kubectl delete secret cloudflare-token-secret -n cert-manager
    
    echo "2. Creating new token secret..."
    kubectl create secret generic cloudflare-token-secret --namespace=cert-manager --from-literal=cloudflare-token="$CF_TOKEN"
    
    echo "3. Reloading cert-manager..."
    kubectl rollout restart deployment -n cert-manager
    
    echo "4. Waiting for cert-manager to restart..."
    kubectl rollout status deployment cert-manager -n cert-manager
    
    echo "5. Verifying token configuration..."
    sleep 5
    "$0" verify-token
    ;;
    
  *)
    echo "Unknown command: $1"
    echo "Usage:"
    echo "  $0 list                 - List all certificates and their status"
    echo "  $0 renew <cert-name>    - Renew a specific certificate"
    echo "  $0 renew-all            - Renew all certificates"
    echo "  $0 check <cert-name>    - Check details of a specific certificate"
    echo "  $0 verify-token         - Verify Cloudflare API token permissions"
    echo "  $0 update-token         - Update the Cloudflare API token"
    ;;
esac