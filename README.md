# Kubernetes Starter: Ingress + Probes + Autoscaling

## What this is
A minimal, production-minded Kubernetes deployment of a single service with:
- Ingress (NGINX)
- Readiness/Liveness probes
- Resource requests/limits
- HorizontalPodAutoscaler (CPU)
- ConfigMap & Secret examples

## Prereqs
- Docker, kubectl, minikube
- (Optional) hey or ab for load testing

## Quick start
make dev-up       # builds image, starts minikube, applies manifests
make test-load    # runs load to trigger HPA
make status       # shows pods, svc, hpa
make down         # cleanup

## Screenshots
[insert: kubectl get hpa, Ingress URL in browser, rollout status]
