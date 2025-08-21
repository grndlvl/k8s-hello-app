# 03 – Deploying to Kubernetes

Now that we have our app container built, it’s time to run it inside Kubernetes.

We’ll create:

1. A **Namespace** to isolate our resources  
2. A **Deployment** for the app pods (with probes, security, resources)  
3. A **Service** to expose the pods internally  

---

## 🏷️ Step 1. Create a Namespace

Namespaces help keep resources grouped logically. We’ll use `hello`.

```yaml
# k8s/manifests/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: hello
```

Apply it:

```bash
kubectl apply -f k8s/manifests/namespace.yaml
```

Set the namespace as the current context so all future commands default to it:

```bash
kubectl config set-context --current --namespace=hello
kubectl get ns
```

You should see `hello` listed and marked as active.

---

## 📦 Step 2. Create a Deployment

A Deployment manages pods for us. We’ll run **2 replicas** of `hello-api` by default.

```yaml
# k8s/manifests/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-api
  namespace: hello
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-api
  template:
    metadata:
      labels:
        app: hello-api
    spec:
      # Pod-level security context
      securityContext:
        runAsUser: 10001
        runAsGroup: 10001
        runAsNonRoot: true
      containers:
      - name: hello-api
        image: hello-api:1.0
        imagePullPolicy: Never   # Always use the locally loaded image in minikube
        ports:
        - containerPort: 8080
        # Container-level hardening
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop: ["ALL"]
        resources:
          # ⚠️ Required for HPA (CPU-based) to work properly
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
        readinessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 2
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /livez
            port: 8080
          initialDelaySeconds: 2
          periodSeconds: 10
```

Apply it:

```bash
kubectl apply -f k8s/manifests/deployment.yaml
kubectl get pods
kubectl rollout status deployment/hello-api
```

---

### 🛡️ Why the security context?

- The Dockerfile already uses UID/GID `10001`.  
- Adding `securityContext` enforces it at the cluster level.  
- Container hardening prevents privilege escalation, locks the filesystem, and drops Linux capabilities.  

---

### 📊 Why set resources?

- Kubernetes needs CPU/memory requests to schedule pods.  
- The HPA later uses `requests.cpu` as the baseline for scaling. Without them, HPA can’t function properly.  

---

## 🌐 Step 3. Create a Service

A Service exposes pods internally in the cluster. We’ll use a **ClusterIP** service so the Deployment can later be wired into an Ingress.

```yaml
# k8s/manifests/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-api
  namespace: hello
spec:
  selector:
    app: hello-api
  ports:
    - port: 80
      targetPort: 8080
```

Apply it:

```bash
kubectl apply -f k8s/manifests/service.yaml
kubectl get svc
```

---

## 🔍 Step 4. Verify the Deployment

Port-forward to test the service:

```bash
kubectl port-forward svc/hello-api 8080:80
```

Now open a new terminal and curl the endpoint:

```bash
curl http://localhost:8080/
```

Expected output (your pod name will vary):

```json
{
  "greeting": {
    "message": "Hello from Kubernetes!!!",
    "env": "dev",
    "pod_name": "hello-api-5f9d7c8d9c-xyz12"
  },
  "secrets": {
    "api_key": "<unset>",
    "db_password": "<unset>"
  }
}
```

Stop port-forwarding with `Ctrl-C`.

---

## 🔄 Developer Notes: Updating Images

When you change `main.py` or rebuild the container, you’ll need to reload the image into minikube:

```bash
docker build -t hello-api:1.0 ./app
minikube image load hello-api:1.0
kubectl rollout restart deployment/hello-api
```

> ⚠️ Because we’re using `imagePullPolicy: Never`, Kubernetes will **only** use the image that’s inside minikube.
> If you forget to reload, pods will still run the old version.> 
>
> - **Best practice:** bump the tag each time (e.g., `hello-api:1.1`, `hello-api:2.0`) so you can safely load a new image without conflicts.  
> - **If you re-use the same tag** (e.g., rebuild `hello-api:1.0`), you must first remove the old image from minikube. But this only works if **no pods are currently running that image**:
>   ```bash
>   kubectl delete deployment hello-api
>   minikube image rm hello-api:1.0
>   docker build -t hello-api:1.0 ./app
>   minikube image load hello-api:1.0
>   kubectl apply -f k8s/manifests/deployment.yaml
>   ```
>   If pods are still referencing the old image, minikube won’t let you remove it.

---

✅ At this point, you have a working Deployment and Service in Kubernetes. Next we’ll configure environment variables using **ConfigMaps** and **Secrets**.
