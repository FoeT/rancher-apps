# Rancher Fleet Applications

This repository contains organized YAML configurations for deploying applications using Fleet in Rancher, along with static workloads deployed directly.

## Quick Start

To deploy these applications:

1. Clone this repository
2. Create a GitHub read-only token (Personal Access Token):
   - Go to GitHub → Settings → Developer Settings → Personal Access Tokens → Fine-grained tokens
   - Create a token with read-only access to your repositories (packages read permission is also needed for container registry access)
   - Store the token in a Kubernetes secret (recommended):
     ```bash
     kubectl create secret generic github-readonly-token -n fleet-local --from-literal=token=YOUR_TOKEN
     ```
   - This token will be used for:
     - Git repository access
     - GitHub Container Registry access for all deployments 
     - Fleet GitRepo image pulls
3. Run the setup script to initialize resources and deploy static workloads:
   ```bash
   ./setup.sh
   ```
4. Apply the Fleet GitRepo configuration to deploy Fleet-managed workloads:
   ```bash
   ./fleet-repo.sh
   ```

## Managing the Repository

## Important Notes

### Bundle Naming Convention

Fleet automatically prefixes bundles with the GitRepo name. For this repository, bundles will be named:
- `rancher-apps-fleet-` (main bundle)
- `rancher-apps-fleet-services-cert-manager` (cert-manager bundle)
- `rancher-apps-fleet-services-common` (common services bundle)
- etc.

When using `dependsOn` in your fleet.yaml files, always use the full bundle name including this prefix. For example:
```yaml
dependsOn:
  - name: rancher-apps-fleet-services-cert-manager
```

### Updating and Pushing Changes

Use the included update script for pushing changes to the repository:

```bash
# Make your changes, then run:
./update-repo.sh -m "Your commit message" -p

# Or without arguments for interactive prompts:
./update-repo.sh
```

### Pulling Updates

To pull the latest changes from the repository and automatically update deployments:

```bash
./new_git_pull.sh
```

This script:
1. Uses a read-only GitHub token for secure access
2. Pulls the latest changes from the repository
3. Updates the GitHub container registry secret
4. Applies any changes to static workloads

The script uses the GitHub token from the Kubernetes secret named `github-readonly-token` in the `fleet-local` namespace. This same token is used for:
- Git repository access
- GitHub Container Registry authentication
- Updating the Kubernetes secret used by container deployments

## Directory Structure

```
/
├── fleet/                        # Fleet-managed workloads
│   ├── base/                     # Shared configurations
│   │   ├── fleet.yaml            # Base Fleet config
│   │   ├── persistent-volumes.yaml # PVC definitions
│   │   └── secrets.yaml          # Secret templates
│   │
│   ├── services/                 # Application configurations
│   │   ├── cert-manager/         # TLS certificate management
│   │   │   ├── certificates.yaml
│   │   │   ├── fleet.yaml
│   │   │   └── issuers.yaml
│   │   │
│   │   ├── common/               # Common resources
│   │   │   ├── fleet.yaml
│   │   │   └── namespace.yaml
│   │   │
│   │   ├── databases/            # Database services (start first)
│   │   │   ├── fleet.yaml        # Databases parent config
│   │   │   ├── xchat-db/         # ExChat database
│   │   │   │   ├── deployment.yaml
│   │   │   │   └── fleet.yaml
│   │   │   ├── foretold-db/      # Foretold database
│   │   │   │   ├── deployment.yaml
│   │   │   │   └── fleet.yaml
│   │   │   └── mm-db/            # MM database
│   │   │       ├── deployment.yaml
│   │   │       └── fleet.yaml
│   │   │
│   │   ├── coparentcare/         # Coparentcare application
│   │   │   ├── deployment.yaml
│   │   │   └── fleet.yaml
│   │   │
│   │   ├── code-server/          # Code Server IDE
│   │   │   ├── deployment.yaml
│   │   │   └── fleet.yaml
│   │   │
│   │   ├── exchat/               # Exchat application
│   │   │   ├── deployment.yaml
│   │   │   ├── dev-environment.yaml
│   │   │   └── fleet.yaml
│   │   │
│   │   ├── ha-proxy/             # Home Assistant proxy
│   │   │   ├── deployment.yaml
│   │   │   └── fleet.yaml
│   │   │
│   │   ├── nextcloud/            # Nextcloud
│   │   │   ├── deployment.yaml
│   │   │   └── fleet.yaml
│   │   │
│   │   ├── nginx/                # NGINX web server
│   │   │   ├── deployment.yaml
│   │   │   └── fleet.yaml
│   │   │
│   │   └── traefik-config/       # Traefik configuration (for existing instance)
│   │       ├── fleet.yaml
│   │       ├── ingressclass.yaml
│   │       └── middlewares.yaml
│   │
│   └── fleet.yaml                # Main Fleet configuration
│
├── static/                       # Directly deployed workloads (not Fleet-managed)
│   ├── pihole/                   # Pi-hole DNS service
│   │   └── deployment.yaml
│   └── README.md                 # Documentation for static workloads
│
├── setup.sh                      # Setup script to deploy static workloads
└── fleet-repo.sh                 # Script to register Fleet GitRepo
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
   - Home Assistant Proxy
   - Coparentcare

5. Static (Direct) Deployments:
   - Pi-hole (DNS server) - deployed via setup.sh

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