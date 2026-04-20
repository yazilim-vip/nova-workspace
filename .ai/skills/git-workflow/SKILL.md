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
- Include a `Co-Authored-By` trailer for AI-assisted commits if your workspace's convention calls for it (check workspace-level rules)

### Example — good vs bad

**Bad:**

```
updated auth stuff

fixed the bug
```

**Good:**

```
fix(auth): reject expired JWTs at middleware layer

Tokens past `exp` were reaching handlers because the middleware only
checked signature validity. Add explicit `exp` comparison before the
signature check so invalid timestamps short-circuit faster and produce
a clearer 401 response.

Refs: INCIDENT-412
```

Why it's better: scope makes the area clear (`auth`), the subject names the fix not the symptom, the body explains *why* the previous code was wrong, and the trailer links to context outside git.

## Merge Requests / Pull Requests

- One logical change per MR/PR
- Title follows conventional commit format
- Include description: what, why, how to test
- CI must pass before merging
- Squash-merge feature branches to keep history clean

## Merge Conflicts

- Resolve by understanding both sides, not by picking one reflexively
- If a conflict is in a file you didn't touch, read the other side's commits (`git log --oneline <their-branch>` over the file) before resolving — their change may invalidate your assumptions
- After resolving: re-run tests. Conflict resolution often breaks things that neither side's tests caught alone
- Never resolve a conflict with `-X theirs` / `-X ours` globally — it suppresses the signal

## Multi-Repo Operations

- Every Bash call targeting a repo must begin with `cd /absolute/path/to/repo &&`
- Never run git commands in parallel across different repos — sequential, one repo at a time
- Complete one repo fully (branch → commit → push) before moving to the next

## Release

- Semantic versioning: `MAJOR.MINOR.PATCH`
- Tag releases on `main`
- Maintain changelog for user-facing projects
