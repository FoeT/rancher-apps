# Fleet-Managed Workloads

This directory contains all workloads managed by Fleet through GitOps. The GitRepo is configured to track only this
directory using the path `fleet` in the GitRepo configuration.

## Structure

- **base/** - Contains base configurations and persistent volume definitions
- **services/** - Application services organized by component
  - **common/** - Shared resources used by multiple services
  - **traefik-config/** - Traefik ingress controller configuration
  - **cert-manager/** - Certificate management
  - **databases/** - Database services
  - And other application services...

## Configuration

The main Fleet configuration is in `fleet.yaml` in this directory. It defines:

1. Default namespace for workload deployment
2. Dependencies between components
3. Deployment order for components

## Excluded Workloads

Some workloads with special requirements (like fixed IPs) are managed outside of Fleet.
These workloads are in the `/static` directory at the root of the repository and
are deployed directly via the `setup.sh` script.