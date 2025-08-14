# HPA Scaling
Check metrics-server is working, then apply the HPA:
```bash
kubectl apply -f k8s/manifests/hpa.yaml
kubectl get hpa -n demo

Generate load:
```bash
hey -z 30s -c 20 http://myapp.local/
kubectl get hpa -w -n demo

Expected: replicas increase while CPU > target, then scale down.
