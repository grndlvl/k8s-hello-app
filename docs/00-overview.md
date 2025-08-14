# Overview
**Goal:** Deploy a small FastAPI service on Kubernetes with Ingress, probes, ConfigMap/Secret, and HPA.

## Architecture
- FastAPI container → Deployment (2 replicas) → Service (ClusterIP) → Ingress (NGINX)
- Config via ConfigMap/Secret; autoscaling via HPA (CPU)

![Architecture](./images/arch-diagram.png)

## Success Criteria
- App reachable at http://myapp.local
- HPA scales under load (2 → 5 replicas)
- Config change visible without image rebuild
