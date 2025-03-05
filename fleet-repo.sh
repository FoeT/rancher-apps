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
