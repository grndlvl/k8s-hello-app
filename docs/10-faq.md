# ❓ FAQ: Frequently Asked Questions

This FAQ answers common questions you might have while working through the tutorial.

---

## 1. Why do we use a custom namespace?

Namespaces keep resources isolated and organized.
By setting your context to `hello`, all commands apply to this project without affecting other workloads.

---

## 2. Why is `imagePullPolicy: Never` set?

We build the image inside **Minikube** and don’t push it to a registry.
Setting `Never` ensures Kubernetes won’t try to pull from Docker Hub, which would cause `ImagePullBackOff`.

---

## 3. Why run the container as non-root UID 10001?

Running as root inside containers is unsafe.
We assign UID/GID `10001` and enforce it with `securityContext` to reduce risk if the container is compromised.

---

## 4. Why set resource requests and limits?

Requests/limits tell Kubernetes how to schedule pods and prevent resource hogging.
They are also required for the **Horizontal Pod Autoscaler (HPA)** to function.

---

## 5. Why doesn’t my Ingress work?

- Make sure the ingress controller (`ingress-nginx`) is running.
- Verify `/etc/hosts` has an entry for `hello.local` pointing to your **Minikube IP** (`minikube ip`).
- Run `kubectl describe ingress hello-api` to check rules.

---

## 6. Why do I see “connection refused” or “service not found”?

- The service name must match the deployment label (`hello-api`).
- Ensure pods are running and ready.
- Use `kubectl get endpoints hello-api` to confirm pods are attached.

---

## 7. Why doesn’t HPA scale my app?

- HPA only works if metrics-server is installed (`kubectl top pods`).
- CPU requests must be set.
- Scaling takes ~5 minutes after sustained load.

---

## 8. How do I regenerate TLS certificates?

If using self-signed certs:

```bash
kubectl delete secret hello-tls
kubectl create secret tls hello-tls --cert=tls.crt --key=tls.key
```

For production: use **cert-manager** to automate renewal.

---

## 9. What if I need to change environment variables?

Update the ConfigMap or Secret, then restart the deployment:

```bash
kubectl apply -f k8s/manifests/configmap.yaml
kubectl apply -f k8s/manifests/secret.yaml
kubectl rollout restart deployment hello-api
```

---

## 10. Can I reuse this setup for other apps?

Yes 👍
Just update the app name, image, and domain in the manifests.
The same workflow applies to most FastAPI/Flask/Node apps.

---

## 11. How do I clean everything up?

To remove all resources:

```bash
kubectl delete -f k8s/manifests/
```

Or delete the entire namespace:

```bash
kubectl delete ns hello
```

---

## 12. What’s next after this tutorial?

- Learn about **cert-manager** for automated TLS.
- Explore **network policies** for better isolation.
- Add **CI/CD pipelines** to build and deploy automatically.
- Try deploying to a cloud provider (GKE, EKS, AKS).
