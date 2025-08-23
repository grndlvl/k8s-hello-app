# 07 -- Security Basics

In [03-k8s-deploy.md](03-k8s-deploy.md), we introduced some basic security practices:  

- Run the container as a non-root user (`UID 10000`, `GID 10001`).  
- Set CPU/memory requests and limits (needed for scheduling and HPA).  

That gave us a secure starting point. In this step, we’ll **go deeper** and enforce hardening at the cluster level.

---

## What you will add in this step

- Enforce non-root at the Pod level (runtime, not just in the image).  
- Harden the container: prevent privilege escalation, lock down the root filesystem, drop Linux capabilities.  
- Use a default **seccomp** profile.  
- Make only `/tmp` writable (via an `emptyDir` volume).  
- Verify these controls actually work.  

---

## 1. Pod Security Context

We already run our app as UID `10000` in group `10001`. In step 3, we set this in the Pod’s `securityContext`.  
Here in step 7, we’ll **extend** it with `fsGroup` and a `seccompProfile`:

```yaml
spec:
  template:
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 10000
        runAsGroup: 10001
        fsGroup: 10001
        seccompProfile:
          type: RuntimeDefault
```

**Verify:**

```bash
kubectl exec deploy/hello-api -- id
```

✅ Expected output:
```
uid=10000 gid=10001 groups=10001
```

### Why UID 10000 and GID 10001?

- **Non-root enforcement**: any UID other than `0` avoids root privileges.  
- **Avoid conflicts**: IDs below 1000 are reserved for system accounts. Starting at 10000 is safe.  
- **Separation of user/group**: distinct UID/GID follows hardened image conventions (distroless, bitnami).  
- **Consistency**: the numbers aren’t special -- what matters is consistency between Dockerfile and manifest.

---

## 2. Container Hardening

Inside the container spec, add strict controls:

```yaml
containers:
- name: hello-api
  image: hello-api:latest
  imagePullPolicy: Never
  securityContext:
    allowPrivilegeEscalation: false
    readOnlyRootFilesystem: true
    capabilities:
      drop: ["ALL"]
  volumeMounts:
    - name: tmp
      mountPath: /tmp
      readOnly: false
```

We mount `/tmp` from an `emptyDir` volume so the app has a writable scratch space while the rest of the filesystem remains read-only.

```yaml
volumes:
  - name: tmp
    emptyDir: {}
```

**Why these matter:**  
- `allowPrivilegeEscalation: false` → no gaining root privileges.  
- `readOnlyRootFilesystem: true` → filesystem is immutable.  
- `capabilities: drop: ["ALL"]` → strips all Linux kernel extras.  
- `emptyDir` for `/tmp` → gives the app a safe ephemeral scratch directory.  

---

## 3. Verification

Check each control in action:

```bash
# 1) Confirm non-root UID/GID
kubectl exec deploy/hello-api -- id
# expect: uid=10000 gid=10001 groups=10001

# 2) Root FS is read-only
kubectl exec deploy/hello-api -- sh -lc 'touch /etc/should-fail'
# expect: Read-only file system

# 3) /tmp is writable
kubectl exec deploy/hello-api -- sh -lc 'echo ok >/tmp/probe && cat /tmp/probe'
# expect: ok
```

---

## 4. Resource Limits (Recap)

From step 03 we set:

```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 200m
    memory: 256Mi
```

These not only help the scheduler and HPA, but also prevent noisy pods from hogging cluster resources.

---

## 5. Summary

By now, our pod is **hardened**:

- ✅ Running as non-root (`10000:10001`)  
- ✅ No privilege escalation  
- ✅ Read-only filesystem (with writable `/tmp`)  
- ✅ No Linux capabilities  
- ✅ Resource requests/limits  
- ✅ Seccomp default profile  

This is the baseline for a production-ready security posture. In production, you’d also use RBAC, ServiceAccounts, and NetworkPolicies to control access.

---

## 📚 Read More

- Dockerfile best practices -- [Use a non-root user](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user)  
- Dockerfile reference -- [USER instruction](https://docs.docker.com/reference/dockerfile/#user)  
- Kubernetes docs -- [Pod Security Standards: Restricted](https://kubernetes.io/docs/concepts/security/pod-security-standards/#restricted)  

---

📸 **Screenshot ideas for `docs/images/`:**  
- Output of `kubectl exec deploy/hello-api -- id`  
- Failure writing to `/etc`  
- Success writing to `/tmp`  

---

👉 Next: we’ll look at **Troubleshooting** common issues in Kubernetes.
