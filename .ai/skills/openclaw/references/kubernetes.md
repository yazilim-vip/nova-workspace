# Kubernetes Deployment

Reference for deploying OpenClaw on Kubernetes using Kustomize.

## Design Philosophy

Kustomize over Helm — OpenClaw is a single container with config files. The customization is in agent content (markdown files, skills, config overrides), not infrastructure templating.

## Prerequisites

- Active Kubernetes cluster (AKS, EKS, GKE, k3s, kind, OpenShift)
- `kubectl` CLI configured
- API credentials from at least one model provider

## Container Image

```
ghcr.io/openclaw/openclaw:latest
```

- Port: **18789**
- Non-root user: UID 1000
- Expects config at startup
- **Requires 4GB+ V8 heap** — set `NODE_OPTIONS=--max-old-space-size=4096`
- Cold start: 2–4 minutes (jiti transpiles 100+ TypeScript extensions)

## Deployed Resources

| Resource | Purpose |
|----------|---------|
| Namespace | Isolation (`openclaw`) |
| Deployment | Single-pod with security hardening |
| Service | ClusterIP on port 18789 |
| PersistentVolumeClaim | 10Gi for agent state and config |
| ConfigMap | `openclaw.json` + `AGENTS.md` |
| Secret | API keys + gateway token + channel tokens |

## Security Context

```yaml
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000
  containers:
    - securityContext:
        readOnlyRootFilesystem: false          # gateway writes to ~/.openclaw/ and /tmp/jiti/
        capabilities:
          drop:
            - ALL
```

> **Note:** `readOnlyRootFilesystem: true` is NOT compatible — the gateway writes transpilation cache to `/tmp/jiti/` and rewrites `openclaw.json` at startup (adds `meta`, `plugins`, `auth.token` fields).

## Manifest Structure

Recommended layout when using Kustomize's `configMapGenerator` to assemble the ConfigMap from on-disk files (keeps `openclaw.json`, agent prompts, and init scripts as first-class files, easy to review in diffs):

```
k8s/
├── kustomization.yaml
├── namespace.yaml
├── deployment.yaml
├── service.yaml
├── pvc.yaml
├── httproute.yaml                # optional — Gateway API exposure
├── limitrange.yaml               # optional — namespace resource caps
├── config/openclaw.json          # gateway + channel + provider config
├── agents/<agent>.md             # per-agent system prompt (one file per agent)
├── scripts/copy-config.sh        # init: seed config + agent prompts to PVC
├── scripts/setup-skills.sh       # init: install openclaw skills to PVC (idempotent)
└── secrets/                      # SOPS-encrypted or externally generated
```

## ConfigMap Pattern

Use `configMapGenerator` so each file stays separate and reviewable. The ConfigMap carries at minimum:
1. `openclaw.json` — gateway + channel + provider configuration
2. One `<agent>.md` per agent — becomes the agent's `workspace/AGENTS.md`
3. Init scripts (`copy-config.sh`, `setup-skills.sh`) — consumed by init containers

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: openclaw

resources:
  - namespace.yaml
  - pvc.yaml
  - deployment.yaml
  - service.yaml
  - secrets/openclaw-secrets.yaml

configMapGenerator:
  - name: openclaw-config
    files:
      - openclaw.json=config/openclaw.json
      - jarvis.md=agents/jarvis.md
      - copy-config.sh=scripts/copy-config.sh
      - setup-skills.sh=scripts/setup-skills.sh

generatorOptions:
  disableNameSuffixHash: true     # stable name so Deployment can reference it
```

Inline ConfigMap also works (single YAML file with `data:` block) but loses syntax highlighting and diff clarity for the embedded JSON/markdown.

### Gateway Binding

| Scenario | `gateway.bind` value |
|----------|----------------------|
| Behind ingress/reverse proxy | `lan` (binds `0.0.0.0`) |
| Port-forward only | `loopback` (binds `127.0.0.1`, default) |
| Auto-detect | `auto` |

> **Important:** Do NOT use raw IPs like `"0.0.0.0"` — use the named bind values above.

### Config Mount Strategy

OpenClaw rewrites `openclaw.json` at startup (adds `meta`, `plugins`, `auth.token`). Do NOT mount it read-only via ConfigMap `subPath` — use an init container to copy files into a writable PVC.

**Split-file layout on the PVC:**
- `~/.openclaw/openclaw.json` — gateway config (seed once; openclaw owns it after first start)
- `~/.openclaw/workspace/AGENTS.md` — primary agent prompt (can be refreshed every start; not rewritten by openclaw)

Example `scripts/copy-config.sh` (consumed by the init container from the ConfigMap):

```sh
#!/bin/sh
set -e
# Seed gateway config only if absent — openclaw rewrites this file,
# so clobbering on every start triggers config-diff restart loops.
[ -f /home/node/.openclaw/openclaw.json ] \
  || cp /openclaw-config/openclaw.json /home/node/.openclaw/

# Agent prompt lives in the workspace, not alongside openclaw.json.
# Safe to overwrite every start — openclaw does not rewrite this file.
mkdir -p /home/node/.openclaw/workspace
cp /openclaw-config/jarvis.md /home/node/.openclaw/workspace/AGENTS.md
```

```yaml
initContainers:
  - name: copy-config
    image: busybox:1.37
    command: ["sh", "/openclaw-config/copy-config.sh"]
    volumeMounts:
      - { name: config, mountPath: /openclaw-config, readOnly: true }
      - { name: data,   mountPath: /home/node/.openclaw }
```

### Skill Pre-Install Pattern

To pre-install OpenClaw skills (e.g. `self-improving-agent`, `notion-api`) so they are available on first boot, add a second init container using the OpenClaw image itself. Guard each install with an existence check so the step is idempotent and survives pod restarts (the PVC caches previously-installed skills):

```sh
#!/bin/sh
# scripts/setup-skills.sh
set -e
for skill in self-improving-agent notion-api; do
  if [ ! -d "/home/node/.openclaw/workspace/skills/$skill" ]; then
    echo "Installing $skill..."
    openclaw skills install "$skill"
  fi
done
```

```yaml
initContainers:
  - name: setup-skills
    image: ghcr.io/openclaw/openclaw:<pinned-version>
    command: ["sh", "/openclaw-config/setup-skills.sh"]
    envFrom:
      - secretRef: { name: openclaw-secrets }    # skills may need API keys at install time
    volumeMounts:
      - { name: config, mountPath: /openclaw-config, readOnly: true }
      - { name: data,   mountPath: /home/node/.openclaw }
```

### Volumes and Deployment Strategy

```yaml
volumes:
  - name: config
    configMap: { name: openclaw-config }
  - name: data
    persistentVolumeClaim: { claimName: openclaw-data }
  - name: tmp
    emptyDir: {}                                 # mount at /tmp for jiti transpile cache

containers:
  - name: openclaw
    volumeMounts:
      - { name: data, mountPath: /home/node/.openclaw }
      - { name: tmp,  mountPath: /tmp }          # jiti writes ~100+ cached .ts → .js files here

# Required when the PVC is RWO (EBS gp3, GCE PD, standard single-attach):
# Recreate prevents two pods from trying to mount the same volume during rollouts.
strategy:
  type: Recreate
```

## Secret Pattern

Secrets should contain API keys and tokens as environment variables:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: openclaw-secrets
  namespace: openclaw
type: Opaque
stringData:
  ANTHROPIC_API_KEY: ""
  OLLAMA_API_KEY: ""
  OPENCLAW_GATEWAY_TOKEN: ""
  DISCORD_BOT_TOKEN: ""
```

The deployment references secrets via `envFrom`:
```yaml
envFrom:
  - secretRef:
      name: openclaw-secrets
```

## Ingress Patterns

### Port-Forward (simplest)

```bash
kubectl port-forward svc/openclaw 18789:18789 -n openclaw
```

### Ingress / Gateway API

For production, expose via your cluster's ingress controller:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: openclaw-route
  namespace: openclaw
spec:
  parentRefs:
    - name: my-gateway
      namespace: gateway-system
  hostnames:
    - "openclaw.your-domain.example.com"
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: openclaw
          port: 18789
```

## FluxCD Integration

For GitOps deployments with FluxCD:

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: openclaw
  namespace: flux-system
spec:
  interval: 1m
  path: ./apps/openclaw
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
  decryption:
    provider: sops
    secretRef:
      name: sops-age
```

## Secret Management Options

| Method | Use Case |
|--------|----------|
| SOPS + age | GitOps-friendly, encrypted in Git |
| External Secrets Operator | Pull from AWS SM, Vault, GCP SM |
| Sealed Secrets | Bitnami, cluster-side decryption |
| Manual `kubectl create secret` | Simplest, not GitOps |

## Local Testing with Kind

```bash
# Create cluster
kind create cluster --name openclaw

# Apply manifests
kubectl apply -k k8s/

# Port-forward
kubectl port-forward svc/openclaw 18789:18789 -n openclaw

# Get gateway token
kubectl get secret openclaw-secrets -n openclaw \
  -o jsonpath='{.data.OPENCLAW_GATEWAY_TOKEN}' | base64 -d
```

## Lifecycle

```bash
# Deploy / redeploy
kubectl apply -k k8s/

# Check status
kubectl get all -n openclaw
kubectl logs -n openclaw deploy/openclaw -f

# Delete everything
kubectl delete namespace openclaw
```

## Resource Requirements

The gateway needs significantly more memory than typical Node.js apps due to runtime TypeScript transpilation of 100+ extensions:

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| CPU request | 100m | 200m |
| CPU limit | 2 | 2 |
| Memory request | 512Mi | 1Gi |
| Memory limit | 4Gi | 4Gi |

**Critical:** Set `NODE_OPTIONS=--max-old-space-size=4096` — without this, the gateway OOMs during startup.

```yaml
env:
  - name: NODE_OPTIONS
    value: "--max-old-space-size=4096"
```

## Health Probes

The gateway takes 2–4 minutes for cold start (jiti transpilation). Use a `startupProbe` with generous thresholds:

```yaml
startupProbe:
  httpGet:
    path: /healthz
    port: 18789
  initialDelaySeconds: 30
  periodSeconds: 10
  failureThreshold: 30          # 30 × 10s = 5 min grace
readinessProbe:
  httpGet:
    path: /healthz
    port: 18789
  periodSeconds: 10
livenessProbe:
  httpGet:
    path: /healthz
    port: 18789
  periodSeconds: 30
```

## Troubleshooting

| Issue | Check |
|-------|-------|
| OOMKilled / CrashLoopBackOff | Set `NODE_OPTIONS=--max-old-space-size=4096` and memory limit to 4Gi |
| Pod restarting after 2–3 min | Startup probe too aggressive — increase `failureThreshold` |
| Config validation errors | Check `kubectl logs` — common issues: missing `models[].name`, invalid `gateway.bind`, bad token ref format |
| CrashLoopBackOff (config) | `kubectl logs` — look for "Config invalid" with specific field errors |
| Pod pending | PVC not bound — check StorageClass exists |
| Channel not connecting | Verify token env vars are set in secret |
| No response from bot | Check model provider API key and connectivity |
| Gateway not reachable | Verify `gateway.bind` is `lan` (not `loopback`) for in-cluster access |
