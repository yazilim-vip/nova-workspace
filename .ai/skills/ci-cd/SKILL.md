---
name: ci-cd
description: CI/CD pipeline standards, image tag conventions, and deployment flow. Use when writing pipeline configs, building container images, setting up release automation, or managing deployment stages.
metadata:
  author: yazilim-vip
  version: "0.1.0"
  status: "stable"
---

# CI/CD

Platform-agnostic conventions. The same rules apply whether you're using GitHub Actions, GitLab CI, Jenkins, CircleCI, or others — only the syntax differs.

## Pipeline Standards

- **Standard stages:** `build → test → deploy` (add `lint` or `security-scan` as needed, but don't skip `test`)
- Every stage must be reproducible — same input produces same output
- No stage modifies source files unless the stage exists specifically to do that (formatting/codegen), and then it commits back explicitly
- **Never** store secrets in CI config files — use the platform's secret/variable store
- **Never** disable security scanning to unblock a release

## Secrets Handling

- Reference secrets via the CI platform's injection mechanism (`${{ secrets.X }}`, `$CI_VARIABLE`, `env:`, etc.)
- Never echo/print a secret in logs — if you need to verify presence, check `[ -z "$VAR" ]` style, not its value
- Rotate any secret that appears in a failed pipeline log

## Image Tags

| Context | Tag format | Example |
|---------|-----------|---------|
| Production release | `v<MAJOR>.<MINOR>.<PATCH>` | `v1.2.3` |
| Pre-release | `v<MAJOR>.<MINOR>.<PATCH>-<stage>` | `v1.2.3-rc.1` |
| Dev / PR build | Short commit SHA | `a4f8e91` |
| Dev pinned by branch | `<branch>-<sha>` | `feature-login-a4f8e91` |

- **Never** push/deploy `:latest` in production — it breaks rollbacks and makes deploys non-deterministic
- Sign release images if your platform supports it (cosign, Notary)

## Release Automation

- Releases triggered by a git tag matching `v*.*.*` on `main` (not by timestamps or manual dispatch alone)
- Tag creation → pipeline builds release image → pushes to registry with semver tag → updates changelog → updates GitOps repo (or equivalent)
- Changelog generated from conventional commit messages between the previous and current tag
- A released version is immutable — never rebuild the same tag with different contents; cut a new patch version instead

## Deployment Flow

The team uses **GitOps** for cluster deployments:

```
developer pushes code
  → CI builds image, pushes to registry
  → CI commits new image digest to GitOps repo
  → GitOps controller (Flux, Argo) detects diff
  → controller reconciles cluster to match repo
```

Key consequence: the cluster state is whatever the GitOps repo says — not whatever someone ran `kubectl apply` with. If a deploy seems wrong, read the GitOps repo first, not the cluster.

## Example — minimal GitLab CI stage

```yaml
build:
  stage: build
  image: docker:24
  services: [docker:24-dind]
  variables:
    IMAGE: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
  script:
    - docker build -t $IMAGE .
    - docker push $IMAGE
```

## Debugging Failing Pipelines

- Read the **first** failing job, not the last — later jobs usually fail as a cascade
- Re-run with more verbose logging before assuming it's a flaky test
- If a test passes locally but fails in CI, the difference is usually: env vars, file permissions, or network access — check those three before anything else
