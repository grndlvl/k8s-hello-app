# Kubernetes Starter: Ingress + Probes + Autoscaling

A beginner-friendly project for learning Kubernetes the **practical way**.
We’ll deploy a small **FastAPI “Hello World” app** on minikube with Ingress, health probes, resource limits, and autoscaling.

---

## 🚀 What this is

A minimal, production-minded Kubernetes deployment of a single service with:

- **Ingress (NGINX)** – route external traffic to the app
- **Readiness/Liveness probes** – so Kubernetes knows when pods are healthy
- **Resource requests/limits** – CPU & memory constraints for predictable scheduling
- **HorizontalPodAutoscaler (HPA)** – auto-scale pods up/down based on CPU
- **ConfigMap & Secret examples** – inject config and secrets without rebuilding images

---

## ✅ Prerequisites

Make sure you have these installed:

- [Docker](https://docs.docker.com/get-docker/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [minikube](https://minikube.sigs.k8s.io/docs/start/)
- (Optional) [`hey`](https://github.com/rakyll/hey) or [`ab`](https://httpd.apache.org/docs/2.4/programs/ab.html) for load testing

---

## 🏃 Quick start

Want to see the finished project right away?
Check out the final code and run it locally:

    git checkout main        # final version of the project
    make dev-up              # builds image, starts minikube, applies manifests
    make test-load           # runs load to trigger HPA
    make status              # shows pods, svc, hpa
    make down                # cleanup

Once deployed, open:

- App: https://hello.local
- FastAPI Docs: https://hello.local/docs
- ReDoc: https://hello.local/redoc

👉 If you prefer to learn step-by-step, start with [00-overview.md](./docs/00-overview.md).

---

## 📸 Screenshots

- ✅ `kubectl get hpa` showing scale-up
  ![HPA Screenshot](./docs/images/hpa.png)

- 🌐 Curl showing `https://hello.local`
  ![Ingress Screenshot](./docs/images/ingress.png)

- 📦 `kubectl rollout status deployment/hello-app`
  ![Rollout Screenshot](./docs/images/rollout.png)

---

## 🎬 Capstone Demo

See the whole project in action — from deploying the app, checking Ingress,
and then watching the Horizontal Pod Autoscaler scale the pods under load:

![Project Capstone Demo](./docs/images/k8s-instructional-capstone.gif)

---

## 📚 Documentation

The full step-by-step walkthrough lives in [docs/](./docs).

👉 To follow along from scratch, start from the `start` branch.
👉 To view the completed project, use `main`.
👉 Each step is also available as a git tag (see Tutorial Tags).

- [00-overview.md](./docs/00-overview.md) – project goals, architecture, repo map **👈 start here**
- [01-prereqs-setup.md](./docs/01-prereqs-setup.md) – install and start minikube
- [02-app-container.md](./docs/02-app-container.md) – build and run the FastAPI app
- [03-k8s-deploy.md](./docs/03-k8s-deploy.md) – deploy the app into Kubernetes
- [04-configmap-secret.md](./docs/04-configmap-secret.md) – inject config & secrets
- [05-ingress-tls.md](./docs/05-ingress-tls.md) – ingress with TLS
- [06-hpa-scaling.md](./docs/06-hpa-scaling.md) – autoscaling with HPA
- [07-security-basics.md](./docs/07-security-basics.md) – pod/container hardening
- [08-troubleshooting.md](./docs/08-troubleshooting.md) – common issues
- [09-runbook-ops.md](./docs/09-runbook-ops.md) – ops runbook
- [10-faq.md](./docs/10-faq.md) – frequently asked questions

---

## 🌿 Tutorial Tags

This repo has multiple ways to follow along:

- **`start` branch** → clean slate to begin the tutorial from scratch
- **`main` branch** → finished project with all steps completed
- **step-XX tags** → optional shortcuts to jump to specific milestones

Tags (optional jump points):
- `step-02-app-container` → FastAPI app + Dockerfile
- `step-03-k8s-deploy` → namespace, deployment, service
- `step-04-configmap-secret` → environment variables & secrets
- `step-05-ingress-tls` → ingress with TLS
- `step-06-hpa-scaling` → autoscaling with HPA

👉 By default, check out the `start` branch and follow the docs step by step.
👉 Use tags only if you want to **jump ahead** or **catch up** at a given step.

---

## 🙌 Why this project?

Kubernetes can feel overwhelming. This repo gives you a **guided, repeatable workflow** that covers the 80% you’ll need for real-world apps — without cloud vendor lock-in or complex tooling.

---

## ⚠️ Disclaimer

This project was created as a learning resource with the assistance of AI tools.
All code and documentation have been **reviewed and tested for accuracy**, but it is intended **for educational purposes only** and is **not production-ready**.
