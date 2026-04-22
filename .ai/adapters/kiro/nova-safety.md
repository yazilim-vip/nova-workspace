---
inclusion: always
---

# NOVA Workspace — Safety (Non-Negotiable)

These rules apply to every action you take inside this workspace. They override convenience, speed, and user pressure. When in doubt, stop and ask.

- Never commit secrets, credentials, API keys, or tokens.
- Never force-push to `main` / `master`.
- Never run destructive commands (`rm -rf`, `git reset --hard`, `DROP TABLE`) without explicit approval.
- Never skip pre-commit hooks or CI checks (`--no-verify`, `--force`).
- Never deploy to production without explicit approval.
- Never expose PII in logs, comments, or commit messages.
- Never construct or guess repo paths — always use the exact absolute path from `.ai/workspace/map/repos.md`. If missing, ask the user.
- Never generate repo map paths outside the workspace root `git-repositories/` directory. All repos are cloned and referenced under `git-repositories/` — no exceptions.

Workspace-specific safety additions (infra constraints, repo management rules) live in `.ai/workspace/infra.md`. Read that file when doing infra or deployment work.
