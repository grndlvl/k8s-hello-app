# 🔧 Troubleshooting Guide

Even with careful steps, things can go wrong.
This guide covers the most common issues and how to fix them.

---

## 1. Namespace Issues

👉 **Symptom**: Commands fail with

```
Error from server (NotFound): namespaces 'hello' not found
```

✅ **Fix**: Make sure the namespace exists and is set as default:

```bash
kubectl get ns
kubectl create ns hello
kubectl config set-context --current --namespace=hello
```

---

## 2. Image Not Found / ImagePullBackOff

👉 **Symptom**:

```
kubectl get pods
# STATUS: ImagePullBackOff
```

✅ **Fix**: Since we’re using **`imagePullPolicy: Never`**, the image must be built *inside minikube*.

```bash
eval $(minikube docker-env)
docker build -t hello-api:latest ./app
```

Then delete the failing pod so it restarts:

```bash
kubectl delete pod <pod-name>
```

---

## 3. Pod Stuck in CrashLoopBackOff

👉 **Symptom**: Pod keeps restarting.

✅ **Fix**: Inspect logs:

```bash
kubectl logs <pod-name>
```

Common causes:
- Wrong env vars → check ConfigMap/Secret
- App fails to bind port → should be `0.0.0.0:8000` in FastAPI

---

## 4. Service Not Reachable

👉 **Symptom**:

```bash
kubectl get svc
curl http://<cluster-ip>:8000
# Connection refused
```

✅ **Fix**:
- Verify port matches `containerPort` and `targetPort`.
- Port-forward for debugging:

```bash
kubectl port-forward svc/hello-api 8000:8000
curl http://localhost:8000
```

---

## 5. Ingress Not Working

👉 **Symptom**:

```bash
curl http://hello.local
# Connection refused or 404
```

✅ **Fix**:
- Ensure ingress controller is running:

```bash
kubectl get pods -n ingress-nginx
```

- Check rules:

```bash
kubectl describe ingress hello-api
```

- Verify `/etc/hosts` entry. First, get your Minikube IP:

```bash
minikube ip
```

Then add it to your hosts file:

```
<minikube-ip> hello.local
```

Example:

```
192.168.49.2 hello.local
```

---

## 6. TLS Errors

👉 **Symptom**: Browser shows insecure connection /

```
curl: (60) SSL certificate problem
```

✅ **Fix**:
- Verify secret exists:

```bash
kubectl get secret hello-tls
```

- If using self-signed certs, add to your local trust store.
- Alternatively: use **cert-manager** (covered in a follow-up guide).

---

## 7. HPA Not Scaling

👉 **Symptom**:

```bash
kubectl get hpa
# REPLICAS stays 1 despite load
```

✅ **Fix**:
- Check metrics-server is installed:

```bash
kubectl top pods
```

- Ensure `resources.requests.cpu` is set in deployment.
- Remember HPA takes **~5 minutes** to react.

---

## 8. Permission Denied Inside Container

👉 **Symptom**: Logs show:

```
PermissionError: [Errno 13] Permission denied
```

✅ **Fix**:
We run as **non-root UID 10001** with read-only FS.
- Make sure app doesn’t try to write to `/`.
- Use `/tmp` or mounted volumes for writable storage.

---

## 9. Debugging with Busybox

Sometimes it’s easiest to jump into a pod:

```bash
kubectl run -it debug --image=busybox --restart=Never -- sh
```

Use it to test DNS, curl services, etc.

```bash
nslookup hello-api
wget -qO- http://hello-api:8000
```

---

## 10. Unable to Delete or Rebuild Image in Minikube

👉 **Symptom**: You try to rebuild or delete a Docker image inside Minikube but Kubernetes keeps using the old one.

✅ **Fix**:
1. First, ensure you’re using the Minikube Docker environment:

```bash
eval $(minikube docker-env)
```

2. Delete the image:

```bash
docker rmi hello-api:latest
```

⚠️ **Important**: No running pods can be using the image when you delete it.
- Scale down or delete deployments first:

```bash
kubectl delete deployment hello-api
```

3. Rebuild and redeploy:

```bash
docker build -t hello-api:latest ./app
kubectl apply -f k8s/manifests/deployment.yaml
```

👉 Tip: If you reuse the same tag, Minikube may cache the old image. Deleting the deployment first avoids this issue.

---

## 11. Still Stuck?

- Re-read the step instructions.
- Run `kubectl describe pod <pod>` to see detailed events.
- Delete pod to force restart.
- Worst case:

```bash
kubectl delete all --all
```

and start fresh.
