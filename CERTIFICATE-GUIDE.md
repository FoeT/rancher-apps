# TLS Certificate Management Guide

This document provides detailed instructions for managing TLS certificates in the Rancher Apps deployment.

## Quick Fix for Expired Certificates

If you have expired certificates (like for exchat.mynetapp.site):

```bash
# 1. First, update the Cloudflare API token (most common issue)
./renew-certificates.sh update-token

# 2. Then renew all certificates at once
./renew-certificates.sh renew-all

# 3. Or renew a specific certificate
./renew-certificates.sh renew mynetapp-site
```

## Setting Up Cloudflare API Token (Step-by-Step)

1. Log in to the Cloudflare dashboard at https://dash.cloudflare.com

2. Navigate to **My Profile > API Tokens**

3. Click **Create Token**

4. Select one of these options:
   - Use the template **"Edit zone DNS"**
   - Or create a custom token with these specific permissions:
     - **Zone > Zone > Read**
     - **Zone > DNS > Edit**

5. Set token scope to include ALL your domains:
   - Under "Zone Resources", select **"Include > Specific zone"**
   - Add each domain separately:
     - mynetapp.site
     - coparentcare.com
     - (any other domains you need certificates for)

6. Set a reasonable token TTL (e.g., 6 months or 1 year)

7. Click **Continue to summary** then **Create Token**

8. Copy your token immediately (it will only be shown once)

9. Create the Kubernetes secret:
   ```bash
   kubectl create secret generic cloudflare-token-secret --namespace=cert-manager --from-literal=cloudflare-token="YOUR-ACTUAL-TOKEN"
   ```

10. Verify the token setup:
    ```bash
    ./renew-certificates.sh verify-token
    ```

## Troubleshooting Certificate Issues

### 1. Certificate Won't Issue

If a certificate is stuck in "not ready" state:

```bash
# Check certificate status
kubectl get certificates -n weapps

# Check specific certificate details
kubectl describe certificate mynetapp-site -n weapps

# Check challenges
kubectl get challenges.acme.cert-manager.io -n weapps

# Check challenge details
kubectl describe challenges.acme.cert-manager.io [challenge-name] -n weapps
```

### 2. Common Certificate Problems and Solutions

#### Invalid API Token
```bash
# Update the token
./renew-certificates.sh update-token
```

#### DNS Validation Failures
If DNS01 challenges consistently fail, you can edit the certificates.yaml file to use HTTP01 validation instead:

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: specific-domain-cert
  namespace: weapps
spec:
  secretName: specific-domain-tls
  issuerRef:
    name: letsencrypt-production
    kind: ClusterIssuer
  commonName: "www.example.com"
  dnsNames:
  - "www.example.com"  # Note: HTTP-01 doesn't support wildcards
```

#### Rate Limiting
If you encounter Let's Encrypt rate limits, temporarily switch to staging issuer:

```bash
# Edit certificates.yaml to use staging issuer
# Change:
# issuerRef:
#   name: letsencrypt-production
# To:
# issuerRef:
#   name: letsencrypt-staging
```

### 3. Renewals

Certificates should auto-renew, but you can force renewal:

```bash
# Renew all certificates
./renew-certificates.sh renew-all
```

## Specific Domain Configurations

### mynetapp.site

- Uses DNS-01 validation via Cloudflare
- Wildcard certificate (*.mynetapp.site)
- Covers: exchat.mynetapp.site, mm.mynetapp.site, etc.

### coparentcare.com

- Uses both DNS-01 (for wildcard) and HTTP-01 (for www only)
- Main certificate secretName: coparentcare-com-tls
- Specific www cert secretName: www-coparentcare-com-tls

## Checking Certificate Expiry

To check when certificates expire:

```bash
# Get certificate secrets
kubectl get secrets -n weapps | grep tls

# Check a specific certificate's expiry
kubectl get secret mynetapp-site-production-tls -n weapps -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -dates
```