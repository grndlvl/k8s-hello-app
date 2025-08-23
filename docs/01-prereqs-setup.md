# 01 – Prerequisites & Setup

Before we dive into Kubernetes, let’s set up the tools you’ll need for this project.
This guide assumes you’re running on **Linux** or **macOS**. Windows users can follow along with [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install).

---

## ✅ Prerequisites

Install the following tools:

1. **Docker** – to build and run containers.
   - Install: https://docs.docker.com/get-docker/
   - Verify:
     ```bash
     docker --version
     docker run hello-world
     ```

2. **kubectl** – the Kubernetes command-line tool.
   - Install: https://kubernetes.io/docs/tasks/tools/
   - Verify:
     ```bash
     kubectl version --client
     ```

3. **minikube** – local Kubernetes cluster (our playground).
   - Install: https://minikube.sigs.k8s.io/docs/start/
   - Verify:
     ```bash
     minikube version
     ```

4. **make** – to use the provided `Makefile` shortcuts.
   - Already installed on most systems.
   - Verify:
     ```bash
     make --version
     ```

> 📝 Tip: If you’re on Windows without WSL2, you can still follow along with [Docker Desktop’s built-in Kubernetes](https://docs.docker.com/desktop/kubernetes/).

---

## 🔧 Make `kubectl` Work with minikube

When using minikube, the `kubectl` binary on your system may not point to the cluster.
Instead of typing `minikube kubectl -- get pods` each time, you can map `kubectl` directly:

```bash
alias kubectl="minikube kubectl --"
```

Now a simple:

```bash
kubectl get pods -A
```

will work as expected.

👉 To make this persistent across shells, add the alias to your shell config:

```bash
echo 'alias kubectl="minikube kubectl --"' >> ~/.bashrc
# or, if using zsh:
echo 'alias kubectl="minikube kubectl --"' >> ~/.zshrc
```

Reload your shell and test:

```bash
kubectl get ns
```

---

## 🚀 Start minikube

Launch your local Kubernetes cluster with:

```bash
minikube start --cpus=2 --memory=4096
```

This allocates 2 CPUs and 4GB RAM — more than enough for our demo.

Verify your cluster is running:

```bash
kubectl get nodes
```

Expected output (your node name may differ):

```
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   1m    v1.30.0
```

---

## 🌐 Enable NGINX Ingress

We’ll use an Ingress Controller to route external traffic into the cluster.

Enable the addon:

```bash
minikube addons enable ingress
```

Verify the controller is running:

```bash
kubectl get pods -n ingress-nginx
```

You should see a pod like `ingress-nginx-controller-xxxxx` in **Running** status.

---

## 🔑 (Optional) Enable cert-manager

For TLS, we’ll use `cert-manager`. Install it with:

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.0/cert-manager.yaml
```

Verify:

```bash
kubectl get pods -n cert-manager
```

You should see pods for `cert-manager`, `cert-manager-cainjector`, and `cert-manager-webhook`.

---

## 📍 Add local DNS entry

We’ll access the app at `https://hello.local`.
Add this hostname to your `/etc/hosts` file:

```bash
echo "$(minikube ip) hello.local" | sudo tee -a /etc/hosts
```

Verify:

```bash
ping -c 1 hello.local
```

You should see it resolve to your minikube IP.

---

## ⏭️ Next Step

Cluster is ready and Ingress is enabled. 🚀

Continue to [02-app-container.md](02-app-container.md) where we’ll build and containerize the FastAPI app.
