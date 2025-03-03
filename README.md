# Rancher Fleet Applications

This repository contains organized YAML configurations for deploying applications using Fleet in Rancher.

## Quick Start

To deploy these applications:

1. Clone this repository
2. Run the setup script to initialize resources:
   ```bash
   ./setup.sh
   ```
3. Apply the Fleet GitRepo configuration:
   ```bash
   kubectl apply -f fleet-repo.yaml
   ```

## Directory Structure

```
/
├── base/                         # Shared configurations
│   ├── fleet.yaml                # Base Fleet config
│   ├── persistent-volumes.yaml   # PVC definitions
│   └── secrets.yaml              # Secret templates
│
├── services/                     # Application configurations
│   ├── cert-manager/             # TLS certificate management
│   │   ├── certificates.yaml
│   │   ├── fleet.yaml
│   │   └── issuers.yaml
│   │
│   ├── common/                   # Common resources
│   │   ├── fleet.yaml
│   │   └── namespace.yaml
│   │
│   ├── databases/                # Database services (start first)
│   │   ├── fleet.yaml            # Databases parent config
│   │   ├── xchat-db/             # ExChat database
│   │   │   ├── deployment.yaml
│   │   │   └── fleet.yaml
│   │   ├── foretold-db/          # Foretold database
│   │   │   ├── deployment.yaml
│   │   │   └── fleet.yaml
│   │   └── mm-db/                # MM database
│   │       ├── deployment.yaml
│   │       └── fleet.yaml
│   │
│   ├── coparentcare/             # Coparentcare application
│   │   ├── deployment.yaml
│   │   └── fleet.yaml
│   │
│   ├── code-server/              # Code Server IDE
│   │   ├── deployment.yaml
│   │   └── fleet.yaml
│   │
│   ├── exchat/                   # Exchat application
│   │   ├── deployment.yaml
│   │   ├── dev-environment.yaml
│   │   └── fleet.yaml
│   │
│   ├── ha-proxy/                 # Home Assistant proxy
│   │   ├── deployment.yaml
│   │   └── fleet.yaml
│   │
│   ├── nextcloud/                # Nextcloud
│   │   ├── deployment.yaml
│   │   └── fleet.yaml
│   │
│   ├── nginx/                    # NGINX web server
│   │   ├── deployment.yaml
│   │   └── fleet.yaml
│   │
│   ├── pihole/                   # Pi-hole DNS service
│   │   ├── deployment.yaml
│   │   └── fleet.yaml
│   │
│   └── traefik-config/           # Traefik configuration (for existing instance)
│       ├── fleet.yaml
│       ├── ingressclass.yaml
│       └── middlewares.yaml
│
└── fleet.yaml                    # Main Fleet configuration
```

## Deployment Order

The applications deploy in the following order:

1. Core infrastructure:
   - cert-manager (TLS certificate management)

2. Common resources and configuration:
   - Common namespace and resources
   - Traefik configuration (updates for existing K3s Traefik)

3. Databases (ensure they start first):
   - xchat-db (ExChat database)
   - mm-db (MM database)
   - foretold-db (Foretold database)

4. Application services:
   - NGINX (Web server)
   - Code Server
   - Nextcloud
   - ExChat (Social application)
   - Pi-hole (DNS server)
   - Home Assistant Proxy
   - Coparentcare

## Usage

To deploy these applications using Fleet:

1. Add this repository to your Fleet GitRepo
2. Adjust configuration as needed for your environment
3. Commit and push changes to trigger deployment

## Configuration Notes

- All applications deploy to the `weapps` namespace
- Ingress resources use the `traefik` IngressClass (from K3s)
- TLS certificates use `cert-manager` with LetsEncrypt
- Most applications mount files from the `pinas-root` persistent volume
- Uses the existing Traefik instance in K3s (kube-system namespace)

## Domain Configuration

- Primary domain: mynetapp.site
- Additional domain: coparentcare.com
- DNS managed through Cloudflare