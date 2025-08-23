# 📘 Runbook: Operations Guide

This runbook collects common operational tasks for the **hello-api** app.
Use it as a quick reference during day-to-day operations or incident response.

---

## 1. Check Application Health

Verify pods are running and ready:

```bash
kubectl get pods -l app=hello-api
kubectl describe pod <pod-name>
```

Check logs:

```bash
kubectl logs -l app=hello-api
```

Health endpoint:

```bash
curl http://hello.local/healthz
```

---

## 2. Restart Pods

Sometimes a quick restart clears transient issues:

```bash
kubectl rollout restart deployment hello-api
kubectl get pods -w
```

---

## 3. Scale Deployment Manually

To temporarily override HPA:

```bash
kubectl scale deployment hello-api --replicas=3
kubectl get pods -l app=hello-api
```

---

## 4. View Resource Usage

Check metrics (requires metrics-server):

```bash
kubectl top pods -l app=hello-api
kubectl top nodes
```

---

## 5. Rotate ConfigMap / Secret

After updating config or secrets:

```bash
kubectl apply -f k8s/manifests/configmap.yaml
kubectl apply -f k8s/manifests/secret.yaml
kubectl rollout restart deployment hello-api
```

---

## 6. Check Ingress & Service

Verify ingress is routing:

```bash
kubectl describe ingress hello-api
curl -v http://hello.local
```

Check service endpoints:

```bash
kubectl get endpoints hello-api
```

---

## 7. TLS Certificate Renewal

If using self-signed certs, regenerate and update the secret:

```bash
kubectl delete secret hello-tls
kubectl create secret tls hello-tls \
  --cert=tls.crt \
  --key=tls.key
kubectl rollout restart deployment hello-api
```

👉 In production: prefer **cert-manager** for auto-renewal.

---

## 8. Debugging Network Issues

Run a debug pod:

```bash
kubectl run -it debug --image=busybox --restart=Never -- sh
```

Inside:

```bash
wget -qO- http://hello-api:8000
nslookup hello-api
```

---

## 9. Clean Up All Resources

To tear down the app completely:

```bash
kubectl delete -f k8s/manifests/
```

Or nuke the namespace:

```bash
kubectl delete ns hello
```

---

## 10. Common Incident Response

- **Pod crash loops** → check logs (`kubectl logs`) and events (`kubectl describe pod`).
- **No traffic** → verify ingress, hosts entry, and service endpoints.
- **High latency / 5xx** → check resource usage with `kubectl top` and consider scaling.
- **TLS failure** → check `hello-tls` secret and certificate expiration.

---

✅ Keep this runbook handy. It should be the first place you look during an incident.
