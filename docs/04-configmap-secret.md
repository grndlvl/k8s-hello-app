# ConfigMap & Secret
Create example resources (safe for repo):
- `k8s/examples/app-config.yaml`
- `k8s/examples/app-secret.yaml` (dummy values)

Apply:
```bash
kubectl apply -f k8s/examples/app-config.yaml
kubectl apply -f k8s/examples/app-secret.yaml

Inject via `envFrom` in the Deployment. Never commit real secrets—use `.secrets/` for local-only values (ignored by git).
