# Kubernetes Starter: Ingress + Probes + Autoscaling

This is the **start branch** — your starting point for the tutorial.  

- All documentation (`docs/00-overview.md` … `docs/10-faq.md`) is **complete** here.  
- The code (`app/` and `k8s/`) is a **scaffold** — you will add to it as you follow the tutorial.  

## How to use this repo

1. Start on the `start` branch and follow the steps in `docs/`.
2. Add code and manifests as you go — the tutorial will guide you.
3. If you need to **validate your work** or you get stuck, you can check out the matching git tag.  
   Each tag shows the repo at the end of that step.

## Tutorial tags

- `step-02-app-container` → FastAPI app + Dockerfile  
- `step-03-k8s-deploy` → namespace, deployment, service  
- `step-04-configmap-secret` → environment variables & secrets  
- `step-05-ingress-tls` → ingress with TLS + redirect  
- `step-06-hpa-scaling` → autoscaling with HPA  
- `step-07-security-basics` → pod/container hardening  

The `main` branch contains the **final, complete version**.

## Conventions

- App name: `hello-app`
- Base URL: `http://hello.local`
- We use a kubectl alias for minikube:
  ```bash
  alias kubectl="minikube kubectl --"
  ```
