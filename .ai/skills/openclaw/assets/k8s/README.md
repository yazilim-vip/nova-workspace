# OpenClaw Kubernetes Example

Minimal Kustomize deployment for OpenClaw with Discord and Ollama Cloud.

## Quick Start

```bash
# 1. Create your secret from the example
cp secret.example.yaml secret.yaml
# Edit secret.yaml with your real API keys

# 2. Apply
kubectl apply -f secret.yaml
kubectl apply -k .

# 3. Verify
kubectl get all -n openclaw
kubectl logs -n openclaw deploy/openclaw -f
```

## Access

```bash
# Port-forward
kubectl port-forward svc/openclaw 18789:18789 -n openclaw
```

## Important Notes

- **Memory:** Gateway needs 4GB V8 heap — `NODE_OPTIONS=--max-old-space-size=4096` is set in the deployment. Memory limit is 4Gi.
- **Cold start:** First startup takes 2–4 minutes (jiti transpiles 100+ TypeScript extensions). The `startupProbe` allows up to 5 minutes.
- **Config rewrite:** OpenClaw rewrites `openclaw.json` at startup (adds meta, plugins, auth token). The init container only seeds config if it doesn't exist yet — overwriting on every restart causes an infinite restart loop.
- **Filesystem:** `readOnlyRootFilesystem` is `false` — required for jiti cache (`/tmp/jiti/`) and config rewrites.

## Customization

- **Channel config** — edit `configmap.yaml` → `openclaw.json`
- **Agent instructions** — edit `configmap.yaml` → `AGENTS.md`
- **Different provider** — swap the `models.providers` section (see `references/providers.md`)
- **Storage class** — add `storageClassName` to `pvc.yaml` for your cluster
- **Ingress** — add an Ingress or HTTPRoute for external access

## Security

The deployment runs with:
- All Linux capabilities dropped
- Non-root user (UID 1000)
- Init container pattern for config injection

See `references/kubernetes.md` for detailed deployment guidance.
