# Base Fleet configuration
defaultNamespace: weapps

# Use Helm with takeOwnership to address existing GitRepo issues
helm:
  takeOwnership: true   # This will add the required labels and annotations to existing resources
  force: false          # Don't force resource updates
  releaseName: rancher-apps  # Specify the release name to match existing GitRepo
  releaseNamespace: weapps   # Specify the release namespace for annotations

targetCustomizations:
  - name: default
    helm:
      # Common Helm values for all applications in this bundle
      values:
        global:           # Configure common services
          ingressClass: traefik
          domains:
            - domainSuffix: mynetapp.site
              tlsSecretName: mynetapp-site-production-tls
            - domainSuffix: coparentcare.com
              tlsSecretName: coparentcare-com-tls