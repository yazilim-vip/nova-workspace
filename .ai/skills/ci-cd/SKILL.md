---
name: ci-cd
description: CI/CD pipeline standards, image tag conventions, and deployment flow. Use when writing pipeline configs, building container images, setting up release automation, or managing deployment stages.
metadata:
  author: yazilim-vip
  version: "0.1.0"
  status: "stable"
---

# CI/CD

## Pipeline Standards

- Standard stages: build → test → deploy
- Never store secrets in CI config files — use CI/CD variables
- Never disable security scanning

## Image Tags

- Semantic version (`v1.2.3`) for releases
- Commit SHA for dev builds
- Never `latest` in production

## Deployment

- Code merge → image build → GitOps controller detects → updates cluster
