# 📈 Step 6: HPA (Horizontal Pod Autoscaler)

Now that `hello-app` is running behind an Ingress, let’s add **automatic scaling** based on CPU usage with the **Horizontal Pod Autoscaler (HPA)**.

The HPA watches Pod metrics (CPU/Memory) and adjusts the number of replicas in your Deployment to meet a target utilization.

---

## 0. Verify metrics are available

> 📌 Prereq: Ensure the Kubernetes **metrics-server** is installed as described in [01-prereqs-setup.md](01-prereqs-setup.md).

Quick check:

```bash
kubectl -n hello top nodes
kubectl -n hello top pods
```

Expected: You should see CPU/Memory usage numbers. If you see errors about metrics not being available, fix metrics-server before continuing.

---

## 1. Confirm resource requests in the Deployment

> HPA uses **resource requests** to compute utilization. We already added them to the container earlier, but verify they’re present:

📄 `k8s/manifests/deployment.yaml` (excerpt)

```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 200m
    memory: 256Mi
```

If you had to add or change these, reapply and roll the Deployment:

```bash
kubectl -n hello apply -f k8s/manifests/deployment.yaml
kubectl -n hello rollout restart deploy/hello-app
kubectl -n hello rollout status deploy/hello-app
```

---

## 2. Create the HPA manifest

We’ll scale between **2 and 5 replicas**, targeting **70% CPU utilization** of the container’s CPU **request** (100m).  
That means: if average CPU > 70m across Pods, HPA will scale out; if below, it scales in.

📄 `k8s/manifests/hpa.yaml`

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: hello-app-hpa
  namespace: hello
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: hello-app
  minReplicas: 2
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

Apply it:

```bash
kubectl -n hello apply -f k8s/manifests/hpa.yaml
```

Verify:

```bash
kubectl -n hello get hpa
kubectl -n hello describe hpa hello-app-hpa
```

Expected (example):

```
NAME            REFERENCE              TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
hello-app-hpa   Deployment/hello-app   5%/70%    2         5         2          10s
```

> `TARGETS` shows current CPU vs target. It will update every ~15s–30s as metrics come in.

---

## 3. Generate load to trigger scaling

We’ll use [`hey`](https://github.com/rakyll/hey), a small HTTP load generator.

### Install hey (one-time)

**macOS (Homebrew):**
```bash
brew install hey
```

**Linux (Go required):**
```bash
go install github.com/rakyll/hey@latest
```

---

### Run the load test

If you mapped `hello.local` in `/etc/hosts`:

```bash
hey -z 2m -c 50 https://hello.local/
```

If you did **not** edit `/etc/hosts`:

```bash
MINIKUBE_IP=$(minikube ip)
hey -z 2m -c 50 -host hello.local https://$MINIKUBE_IP/
```

- `-z 2m` → run for 2 minutes  
- `-c 50` → 50 concurrent requests  
- `-host hello.local` → sets the Host header when not using `/etc/hosts`

---

### Watch HPA respond

In another terminal:

```bash
watch kubectl -n hello get hpa,deploy,pods
```

*In order to watch multiple resources at once, we use watch instead of `-w` as it will not allow you to watch multiple resources.*
*Press `Ctrl+C` to stop watching when done.*

Expected behavior:
- `TARGETS` rises toward/above your utilization target (e.g., 60–70%).  
- Deployment `REPLICAS` increases (e.g., 1 → 3 → 5).  
- New Pods appear and become `Running`.

---

⏱️ **Note on timing:**  
- Scaling **up** usually happens within ~30–60 seconds once CPU is above target.  
- Scaling **down** is slower — HPA has a **5-minute stabilization window** by default, so replicas won’t drop immediately when load stops.

---

## 4. Alternative: one‑liner autoscale (optional)

You can also create an HPA without a manifest using the imperative command:

```bash
kubectl -n hello autoscale deploy hello-app \
  --cpu-percent=70 \
  --min=1 \
  --max=5
```

> We prefer keeping the **YAML** (`k8s/manifests/hpa.yaml`) so changes are tracked in Git.

---

## 5. Troubleshooting

- **No metrics available**
  ```bash
  kubectl -n hello top pods
  kubectl -n kube-system logs deploy/metrics-server
  ```
- **HPA never scales**
  - Ensure `resources.requests.cpu` is set on the container.
  - Verify your load actually hits the app (check Pod logs, Service, and Endpoints).
  - Check HPA events:
    ```bash
    kubectl -n hello describe hpa hello-app-hpa
    ```

---

## ✅ What we accomplished

- Added an **HPA** that scales `hello-app` between **2–5** replicas targeting **70% CPU**.  
- Verified scaling behavior under load and cooldown back to 2 replica.

---

## ⏭️ Next Step

Time to tighten the screws.  
Continue to [07-security-basics.md](07-security-basics.md) to add **readiness/liveness probes** and enforce **Pod/Container securityContext** best practices.
