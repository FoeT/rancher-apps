# Static Workloads

This directory contains workloads that are deployed directly via kubectl and not managed by Fleet.
These workloads are deployed by the `setup.sh` script.

## Current Static Workloads:

- **PiHole**: DNS-based ad blocker with a fixed LoadBalancer IP (172.16.0.95)
  - Uses persistent storage via pinas-root PVC
  - Deployed with a fixed IP to avoid conflicts with Fleet management

## Why are these workloads static?

Some workloads may have specific requirements that make them difficult to manage through Fleet:

1. Fixed IP addresses that might cause conflicts with Fleet's reconciliation
2. Specialized persistence requirements
3. Services that need to be carefully managed during updates

Adding a workload to this directory means it will be deployed directly through kubectl
rather than through Fleet's GitOps process.