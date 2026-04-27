# Infrastructure — Workspace Config

Workspace-specific infra conventions for {{workspace-name}}. Populated during onboarding. If your team has infra-flavored skills, store them at the tier that fits — workspace user skills (your adapter's native location, see `.ai/adapters/<platform>/README.md` § "Skills") or per-repo project skills (declared in the repo's own `AGENTS.md`). See root `AGENTS.md` § "Skills" for the multi-tier model.

## Safety

{{List workspace-specific safety rules here — e.g. CLI wrappers that must be used instead of raw tooling, repo management constraints, etc. Remove sections you don't use.}}

## Infrastructure-as-Code

{{Describe IaC tooling (Terraform, Pulumi, OpenTofu, CloudFormation), wrapper CLIs, state backend, approval flow.}}

## Secrets

{{Describe secret management tooling — SOPS, Vault, AWS Secrets Manager, Azure Key Vault, Doppler, etc.}}

## Deployment

{{Describe the deployment flow — GitOps (Flux, Argo), CI-triggered, manual, etc.}}

## CI/CD

{{Describe CI/CD conventions — which platform (GitHub Actions, GitLab CI, Tekton, Jenkins), reusable pipeline catalogs, required stages.}}

## Orchestration / Runtime

{{If applicable: Kubernetes clusters, ECS, serverless, bare metal — which environments, how to reach them, deploy protocol.}}
