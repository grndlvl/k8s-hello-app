# 📘 Runbook: Operations Guide

This runbook collects common operational tasks for the **hello-api** app.
Use it as a quick reference during day-to-day operations or incident response.

---

## 1. Check Application Health

Verify pods are running and ready:

```bash
kubectl -n hello get pods -l app=hello-api
kubectl -n hello describe pod <pod-name>
```

Check logs:

```bash
kubectl -n hello logs -l app=hello-api
```

Health endpoint:

```bash
curl http://hello.local/healthz
```

---

## 2. Restart Pods

Sometimes a quick restart clears transient issues:

```bash
kubectl -n hello rollout restart deployment hello-api
kubectl -n hello get pods -w
```

---

## 3. Scale Deployment Manually

To temporarily override HPA:

```bash
kubectl -n hello scale deployment hello-api --replicas=3
kubectl -n hello get pods -l app=hello-api
```

---

## 4. View Resource Usage

Check metrics (requires metrics-server):

```bash
kubectl -n hello top pods -l app=hello-api
kubectl -n hello top nodes
```

---

## 5. Rotate ConfigMap / Secret

After updating config or secrets:

```bash
kubectl -n hello apply -f k8s/manifests/configmap.yaml
kubectl -n hello apply -f k8s/manifests/secret.yaml
kubectl -n hello rollout restart deployment hello-api
```

---

## 6. Check Ingress & Service

Verify ingress is routing:

```bash
kubectl -n hello describe ingress hello-api
curl -v http://hello.local
```

Check service endpoints:

```bash
kubectl -n hello get endpoints hello-api
```

---

## 7. TLS Certificate Renewal

If using self-signed certs, regenerate and update the secret:

```bash
kubectl -n hello delete secret hello-tls
kubectl -n hello create secret tls hello-tls \
  --cert=tls.crt \
  --key=tls.key
kubectl -n hello rollout restart deployment hello-api
```

👉 In production: prefer **cert-manager** for auto-renewal.

---

## 8. Debugging Network Issues

Run a debug pod:

```bash
kubectl -n hello run -it debug --image=busybox --restart=Never -- sh
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
kubectl -n hello delete -f k8s/manifests/
```

Or nuke the namespace:

```bash
kubectl -n hello delete ns hello
```

---

## 10. Common Incident Response

- **Pod crash loops** → check logs (`kubectl -n hello logs`) and events (`kubectl -n hello describe pod`).
- **No traffic** → verify ingress, hosts entry, and service endpoints.
- **High latency / 5xx** → check resource usage with `kubectl -n hello top` and consider scaling.
- **TLS failure** → check `hello-tls` secret and certificate expiration.

---

✅ Keep this runbook handy. It should be the first place you look during an incident.
