# NOVA — Workspace Engineering Intelligence

How the [yazilim.vip](https://yazilim.vip) crew runs their agent-driven development workspace.

NOVA is an opinionated, markdown-based framework built on the [AGENTS.md](https://agents.md) convention. It gives an AI agent a consistent identity, safety rules, navigation protocol, and skill library across a multi-repo workspace — so the agent behaves the same way whether you're in Claude Code, Cursor, Codex, or any other AGENTS.md-compatible tool.

## What you get

- **`AGENTS.md`** — the agent's identity, safety rules, and navigation protocol.
- **`SOUL.md`** — voice and depth, loaded only when the task demands it.
- **`.ai/skills/`** — reusable skills (git workflow, code quality, terraform, kubernetes, ci/cd, project scaffolding, workspace onboarding).
- **`.ai/workspace-template/`** — templates for per-machine workspace config (repo map, infra).
- **`.ai/workspace/`** — the local workspace instance (gitignored; populated on bootstrap).
- **`git-repositories/`** — the clone convention (`<platform>/<group>/<repo>`; gitignored).

## Why workspace-level, not repo-level?

Most agent tooling operates inside a single repo. Real engineering work spans many repos — apps, infra, shared libraries, docs. NOVA sits one level above: it's the thing that tells the agent *which* repo to enter, what conventions it uses, and where the shared skills live.

## Getting started

1. Clone this repo into a new workspace directory.
2. Copy `.ai/workspace-template/map/repos.md` → `.ai/workspace/map/repos.md` and fill in your repos.
3. Copy `.ai/workspace-template/infra.md` → `.ai/workspace/infra.md` and fill in your infra tooling.
4. Clone your project repos into `git-repositories/` following the convention.
5. Open the workspace in an AGENTS.md-aware agent. Say "set up my workspace" to trigger onboarding.

## Status

Early. Opinionated. Shipped as *how we actually work*, not as a polished product. Take what's useful, fork it, adapt it.

## License

[MIT](./LICENSE) © yazilim.vip
