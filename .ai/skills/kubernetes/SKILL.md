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

- Namespace matches project name
- Resource names: `<app-name>` or `<app-name>-<component>`
- Standard labels: `app.kubernetes.io/name`, `app.kubernetes.io/part-of`
- Always set resource requests and limits
- Kustomize: `base/` + `overlays/<env>/`, patches over copies

## Constraints

- No `kubectl apply` to production without approval
- No namespace deletion without approval
- Verify with `kubectl diff` before applying

## Secrets

- Never display decrypted secret values in tool output — verify structure only
- K8s secret `type` field is immutable — to change type (e.g. `dockerconfigjson` → `Opaque`), delete and recreate the secret
