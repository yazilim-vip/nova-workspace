# NOVA — Workspace Engineering Intelligence

A minimal, opinionless framework for running AI agents across multi-repo development workspaces. Originated and maintained by the [yazilim.vip](https://yazilim.vip) crew; shipped for anyone who wants it.

NOVA is a markdown-based framework built on the [AGENTS.md](https://agents.md) convention. It gives an AI agent a consistent identity, safety rules, and navigation protocol across a multi-repo workspace — so the agent behaves the same way whether you're in Claude Code, Cursor, Codex, or any other AGENTS.md-compatible tool.

**NOVA does not ship opinions about how you write code, use git, run Kubernetes, or manage infrastructure.** Those belong to you. The framework ships only the machinery it needs to work — onboarding, upstream syncing, project-structure conventions — and gives you two clean places to bring your own skills.

## What you get

- **`AGENTS.md`** — the agent's identity, safety rules, and navigation protocol.
- **`SOUL.md`** — voice and depth, loaded only when the task demands it.
- **`.ai/skills/`** — three framework-shipped skills (`workspace-onboarding`, `self-update`, `project-scaffold`) plus whatever team-shared skills you commit here.
- **`.ai/workspace/`** — the local workspace instance (gitignored; populated during onboarding). Personal local-only skills live at `.ai/workspace/skills/`.
- **`git-repositories/`** — the clone convention (`<platform>/<group>/<repo>`; gitignored).

## Why workspace-level, not repo-level?

Most agent tooling operates inside a single repo. Real engineering work spans many repos — apps, infra, shared libraries, docs. NOVA sits one level above: it's the thing that tells the agent *which* repo to enter, what conventions it uses, and where the shared skills live.

## Getting started

1. Clone this repo into a new workspace directory.
2. Open the workspace in an AGENTS.md-aware agent (Claude Code, Cursor, Codex, etc.).
3. Say **"set up my workspace"** — NOVA will guide you through onboarding.
4. (Optional) Clone your project repos into `git-repositories/` following the `<platform>/<group>/<repo>` convention.

Manual alternative: copy `.ai/skills/workspace-onboarding/assets/map/repos.md` → `.ai/workspace/map/repos.md` and `.ai/skills/workspace-onboarding/assets/infra.md` → `.ai/workspace/infra.md`, then fill them in yourself.

## What onboarding looks like

NOVA uses a guided conversation — it asks 2-3 questions at a time, adapts to your answers, and generates the workspace instance files at the end.

See a full example conversation in [.ai/skills/workspace-onboarding/assets/example-dialogue.md](.ai/skills/workspace-onboarding/assets/example-dialogue.md) — identity → repos → infra → rules → AI tool → generated-files preview, plus short variants for skipping a topic, adding a repo later, and the first post-onboarding task.

## Bringing your own skills

Two locations, same [agentskills.io](https://agentskills.io) format — pick based on who should have the skill.

**Team-shared → `.ai/skills/<your-skill>/` (committed to your repo or fork).** Anything the whole team should have: a mandatory deployment flow, an internal tool's config recipe, a review checklist, team-wide git/code/terraform conventions. If you're forking upstream NOVA, pull updates with:

```bash
git remote add upstream https://github.com/yazilim-vip/nova-workspace.git
git fetch upstream
git merge upstream/main
```

(Or use the `self-update` skill — it reviews incoming upstream changes instead of merging blindly.)

**Personal, local-only → `.ai/workspace/skills/<your-skill>/` (gitignored).** One-off helpers, experiments, machine-specific shortcuts. Nothing shared, nothing committed. On name collision, the local version wins.

Every skill has a `SKILL.md` with agentskills.io-compliant YAML frontmatter:

```markdown
---
name: my-skill
description: One-line description of what this skill does and when to use it.
metadata:
  author: your-name
  version: "0.1.0"
---
```

See `.ai/skills/workspace-onboarding/SKILL.md` for a full reference example.

## Contributing upstream

If you've built something generic enough that other teams would benefit — a new skill, a fix, a better onboarding question — open a PR. Keep it focused and opinionated: "this is how we do it, here's why" beats "adds optional support for X." By contributing, you agree to the MIT License.

## Status

Early. Opinionated. Shipped as *how we actually work*, not as a polished product. Take what's useful, fork it, adapt it.

## License

[MIT](./LICENSE) © yazilim.vip
