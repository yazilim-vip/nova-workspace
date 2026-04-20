# Infrastructure — Workspace Config

Workspace-specific infra conventions for {{workspace-name}}. Extends `.ai/skills/terraform/SKILL.md` and `.ai/skills/kubernetes/SKILL.md`.

## Safety

{{List workspace-specific safety rules here — e.g. CLI wrappers that must be used instead of raw terraform, repo management constraints, etc.}}

## Terraform / Terragrunt

{{Describe how terraform/terragrunt operations work in this workspace — CLI tools, approval flow, any wrappers.}}

## Secrets

{{Describe secret management tooling — SOPS, Vault, AWS Secrets Manager, etc.}}

## Deployment

{{Describe the deployment flow for this workspace — GitOps, manual, CI-triggered, etc.}}

## CI/CD

{{Describe CI/CD conventions — reusable pipeline catalog, required stages, etc.}}
