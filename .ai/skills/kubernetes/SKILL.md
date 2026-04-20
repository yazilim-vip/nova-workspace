---
name: kubernetes
description: Kubernetes manifest conventions, Kustomize patterns, resource constraints, and secrets handling. Use when writing K8s manifests, setting up deployments, managing namespaces, or handling encrypted secrets.
metadata:
  author: yazilim-vip
  version: "0.1.0"
  status: "stable"
---

# Kubernetes

## Manifest Conventions

- **Namespace** matches the project name (`gym-tracker` project → `gym-tracker` namespace)
- **Resource names:** `<app-name>` for the primary workload, `<app-name>-<component>` for secondary pieces (e.g. `gym-tracker`, `gym-tracker-worker`)
- **Standard labels** on every resource:
  ```yaml
  labels:
    app.kubernetes.io/name: gym-tracker
    app.kubernetes.io/part-of: gym-tracker
    app.kubernetes.io/component: api        # optional: api | worker | web | job
    app.kubernetes.io/version: v1.2.3
  ```
- **Always** set `resources.requests` and `resources.limits` — unset requests make the scheduler blind; unset limits make the node OOM-kill lottery unfair

## Kustomize Patterns

Layout:

```
k8s/
├── base/
│   ├── kustomization.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── configmap.yaml
└── overlays/
    ├── dev/
    │   ├── kustomization.yaml
    │   └── patches/
    └── prod/
        ├── kustomization.yaml
        └── patches/
```

- Patch over copy — overlays add `patchesStrategicMerge` or `patches:`, they never re-specify the whole resource
- Env-specific values (replicas, resource size, ingress host) live in overlays
- Secrets never live in `base/` — overlays reference a secret that exists in the cluster (created via SOPS or SealedSecrets)

## Health Probes

All long-running workloads need three probes:

```yaml
startupProbe:        # lets slow-starting apps finish booting
  httpGet: { path: /health/ready, port: 8080 }
  failureThreshold: 30
  periodSeconds: 5
readinessProbe:      # gates traffic
  httpGet: { path: /health/ready, port: 8080 }
  periodSeconds: 10
livenessProbe:       # triggers restart on hang
  httpGet: { path: /health/live, port: 8080 }
  periodSeconds: 30
  failureThreshold: 3
```

- `/ready` = "I can accept a request now" (check deps: DB, cache)
- `/live` = "the process is not wedged" (just returns 200)
- Don't use `/ready` as `livenessProbe` — a temporary DB blip will restart-loop your whole deployment

## Constraints

- **No** `kubectl apply` to production without approval — prod changes go through GitOps
- **No** namespace deletion without approval — it cascades, and cascades can't be undone
- **Verify with `kubectl diff`** before applying in any environment — catches unintended changes from stale local files

## Secrets

- **Encryption at rest in git:** use [SOPS](https://github.com/getsops/sops) with [Age](https://github.com/FiloSottile/age) keys. Private key lives outside the repo (e.g. in a password manager or the infra CLI's env file)
- Encrypted secret files are committable; the Age private key never is
- K8s Secret `type` is **immutable** — to change type (e.g. `kubernetes.io/dockerconfigjson` → `Opaque`), delete and recreate the secret
- **Never** display decrypted secret values in tool output — verify structure (keys, base64-ness) only, never values

## Minimal Deployment example

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gym-tracker
  namespace: gym-tracker
  labels:
    app.kubernetes.io/name: gym-tracker
    app.kubernetes.io/part-of: gym-tracker
spec:
  replicas: 2
  selector:
    matchLabels: { app.kubernetes.io/name: gym-tracker }
  template:
    metadata:
      labels: { app.kubernetes.io/name: gym-tracker }
    spec:
      containers:
        - name: api
          image: registry.example.com/gym-tracker:v1.2.3
          ports: [{ containerPort: 8080 }]
          resources:
            requests: { cpu: 100m, memory: 256Mi }
            limits:   { cpu: 500m, memory: 512Mi }
          readinessProbe:
            httpGet: { path: /health/ready, port: 8080 }
          livenessProbe:
            httpGet: { path: /health/live, port: 8080 }
            periodSeconds: 30
```

## Common Pitfalls

- **`imagePullPolicy: Always`** on a `:latest` tag creates a new image fetch on every pod restart — combined with a flaky registry, this causes restart storms. Use a real tag.
- **`readOnlyRootFilesystem: true`** breaks apps that write to `/tmp` or home — add `emptyDir` volume mounts for writable paths.
- **`imagePullSecrets` missing** on the ServiceAccount → pods stuck in `ImagePullBackOff` with a cryptic auth error. Check the SA before the registry.
- **Hostname collisions** from copy-pasted Ingresses across namespaces → the later-applied one silently takes effect. Use `kubectl get ingress -A` to verify.
