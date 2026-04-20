---
name: git-workflow
description: Branching strategy, conventional commits, merge/pull requests, multi-repo git operations, and semantic versioning. Use when creating branches, writing commit messages, opening MRs/PRs, or managing releases.
metadata:
  author: yazilim-vip
  version: "0.1.0"
  status: "stable"
---

# Git Workflow

## Branching

- `main` is production — always deployable
- Feature branches branch from `main` and merge back
- Never commit directly to `main`
- Branch naming: `<type>/<short-description>`
  - Types: `feature`, `fix`, `refactor`, `chore`, `docs`, `test`

## Commits

- Follow [Conventional Commits](https://www.conventionalcommits.org/)
- Format: `<type>(<scope>): <description>`
- Types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `ci`, `style`, `perf`
- First line under 72 characters
- Body explains *why*, not *what*
- Always include `Co-Authored-By` trailer for AI-assisted commits

## Merge Requests / Pull Requests

- One logical change per MR/PR
- Title follows conventional commit format
- Include description: what, why, how to test
- CI must pass before merging
- Squash-merge feature branches to keep history clean

## Multi-Repo Operations

- Every Bash call targeting a repo must begin with `cd /absolute/path/to/repo &&`
- Never run git commands in parallel across different repos — sequential, one repo at a time
- Complete one repo fully (branch → commit → push) before moving to the next

## Release

- Semantic versioning: `MAJOR.MINOR.PATCH`
- Tag releases on `main`
- Maintain changelog for user-facing projects
