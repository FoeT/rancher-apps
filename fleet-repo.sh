#!/bin/bash

# Try to get GitHub token from kubernetes secret
if kubectl get secret -n fleet-local github-readonly-token &>/dev/null; then
  echo "Getting GitHub token from Kubernetes secret..."
  READ_ONLY_TOKEN=$(kubectl get secret -n fleet-local github-readonly-token -o jsonpath='{.data.token}' | base64 -d)
  
  # Create/update the github-container-registry secret for Fleet
  echo "Updating GitHub container registry secret for Fleet deployments..."
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

cat <<EOF | kubectl apply -f -
apiVersion: fleet.cattle.io/v1alpha1
kind: GitRepo
metadata:
  name: rancher-apps
  namespace: fleet-local
  annotations:
    meta.helm.sh/release-name: rancher-apps
    meta.helm.sh/release-namespace: weapps
  labels:
    app.kubernetes.io/managed-by: Helm
spec:
  repo: https://github.com/FoeT/rancher-apps
  branch: main
#  revision: 1eed8c5f8685818e2327c5d65d0a3cb12c5715fb
  paths:
  - fleet
  helmRepoURLRegex: "https://charts.*"
  clientSecretName: foet-git
  forceSyncGeneration: 0
  # Force resources to be adopted
  correctDrift:
    enabled: true
  # Don't use a global targetNamespace to allow cluster-scoped resources
  # Each component will set its own namespace as needed
  targets:
  - clusterName: local
EOF
