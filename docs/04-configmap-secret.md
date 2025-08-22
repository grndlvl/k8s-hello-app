# 🔑 Step 4: ConfigMaps and Secrets

In real-world applications, you don’t want to hardcode settings or sensitive values directly into your container image. Kubernetes provides two key resource types to manage this:

- **ConfigMap** → for non-sensitive configuration (e.g., greetings, app settings).  
- **Secret** → for sensitive data (e.g., passwords, API tokens).  

We’ll update our app to read environment variables from both. ConfigMaps will live in the repo, but real Secrets will be kept in a private `.secrets/` directory and excluded from version control. For learners, we’ll also include an example manifest under `k8s/examples/`.

---

## 1. Create a ConfigMap

📄 `k8s/manifests/configmap.yaml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: hello-app-config
  namespace: hello
data:
  APP_MESSAGE: "Hello from ConfigMap 👋"
  APP_MODE: "develop"
```

Apply it:

```bash
kubectl apply -f k8s/manifests/configmap.yaml
```

Verify:

```bash
kubectl get configmap hello-app-config -o yaml
```

---

## 2. Prepare Secret Storage

We don’t want real secrets in Git. Let’s create a private folder and ignore it:

```bash
mkdir -p .secrets
```

📄 `.gitignore` (add this if not present)

```gitignore
# keep real k8s Secrets out of the repo
.secrets/
```

---

## 3. Example Secret (committed)

This stays in the repo as a reference only.

📄 `k8s/examples/hello-app-secret.example.yaml`

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: hello-app-secret
  namespace: hello
type: Opaque
stringData:
  SECRET_API_KEY: "replace-me-in-real-secret"
  SECRET_DB_PASSWORD: "replace-me-in-real-secret"
```

---

## 4. Real Secret (private, not committed)

Create your real Secret manifest locally:

📄 `.secrets/hello-app-secret.yaml`

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: hello-app-secret
  namespace: hello
type: Opaque
stringData:
  SECRET_API_KEY: "replace-me-in-real-secret"
  SECRET_DB_PASSWORD: "replace-me-in-real-secret"
```

Apply it:

```bash
kubectl apply -f .secrets/secret.yaml
```

Verify:

```bash
kubectl get secret hello-app-secret -n hello -o yaml
```

Values will show up under `data:` in base64 form (that’s expected).

---

## 5. Alternative: Create Secret directly

Instead of a file, you can generate it with `kubectl`:

```bash
kubectl create secret generic hello-app-secret \
  --namespace hello \
  --from-literal=API_KEY="super-secret-key" \
  --dry-run=client -o yaml > .secrets/hello-app-secret.yaml

kubectl apply -f .secrets/hello-app-secret.yaml
```

---

## 6. Update the Deployment

We now inject the ConfigMap and Secret values as environment variables.

📄 `k8s/manifests/deployment.yaml` (excerpt)

```yaml
# k8s/manifests/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-app
  namespace: hello
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-app
  template:
    metadata:
      labels:
        app: hello-app
    spec:
      # Pod-level security context
      securityContext:
        runAsUser: 10001
        runAsGroup: 10001
        runAsNonRoot: true
      containers:
      - name: hello-app
        image: hello-app:1.0
        imagePullPolicy: Never   # Always use the locally loaded image in minikube
        ports:
        - containerPort: 8080
        env:
        - name: APP_MESSAGE
          valueFrom:
            configMapKeyRef:
              name: hello-app-config
              key: APP_MESSAGE
        - name: APP_MODE
          valueFrom:
            configMapKeyRef:
              name: hello-app-config
              key: APP_MODE
        - name: SECRET_API_KEY
          valueFrom:
            secretKeyRef:
              name: hello-app-secret
              key: SECRET_API_KEY
        - name: SECRET_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: hello-app-secret
              key: SECRET_DB_PASSWORD
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

Reapply:

```bash
kubectl apply -f k8s/manifests/deployment.yaml
```

---

## 7. Verify Inside the Pod

Open a shell inside the pod:

```bash
kubectl exec -it deploy/hello-app -- sh
```

Check the environment variables:

```bash
echo $GREETING
echo $API_KEY
```

Expected output:

```
Hello from ConfigMap 👋
super-secret-key
```

Exit:

```bash
exit
```

---

## ⏭️ Next Step

✅ At this point, your app can read configuration and secrets securely from Kubernetes.  

Next, we’ll expose the app outside the cluster with an **Ingress** and secure it with **TLS**.  
Continue to [05-ingress-tls.md](05-ingress-tls.md).
