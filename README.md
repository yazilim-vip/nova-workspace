# NOVA — Workspace Engineering Intelligence

How the [yazilim.vip](https://yazilim.vip) crew runs their agent-driven development workspace.

NOVA is an opinionated, markdown-based framework built on the [AGENTS.md](https://agents.md) convention. It gives an AI agent a consistent identity, safety rules, navigation protocol, and skill library across a multi-repo workspace — so the agent behaves the same way whether you're in Claude Code, Cursor, Codex, or any other AGENTS.md-compatible tool.

## What you get

- **`AGENTS.md`** — the agent's identity, safety rules, and navigation protocol.
- **`SOUL.md`** — voice and depth, loaded only when the task demands it.
- **`.ai/skills/`** — reusable skills (git workflow, code quality, terraform, kubernetes, ci/cd, project scaffolding, workspace onboarding).
- **`.ai/workspace/`** — the local workspace instance (gitignored; populated during onboarding).
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

## Adding your own skills

NOVA recognizes two places for skills:

**Team-shared skills → fork model.** Skills your whole team should have (an internal tool, a mandatory deployment flow, a custom review checklist) go in `.ai/skills/<your-skill>/SKILL.md` — committed to *your fork*. The yazilim.vip crew does this with the `openclaw` skill. Your fork is the source of truth for your team; upstream NOVA stays generic.

To pull in upstream changes:

```bash
git remote add upstream https://github.com/yazilim-vip/nova-workspace.git
git fetch upstream
git merge upstream/main
```

**Personal, local-only skills → `.ai/workspace/skills/`.** One-off helpers, experiments, machine-specific shortcuts. This directory is gitignored — nothing shared, nothing committed. If a skill name collides, the local version wins.

Every skill has a `SKILL.md` with YAML frontmatter:

```markdown
---
name: my-skill
description: One-line description of when to load this skill.
metadata:
  author: your-name
  version: "0.1.0"
  status: "stable"
---
```

See `.ai/skills/git-workflow/SKILL.md` or `.ai/skills/terraform/SKILL.md` for reference.

## Contributing upstream

If you've built something generic enough that other teams would benefit — a new skill, a fix, a better onboarding question — open a PR. Keep it focused and opinionated: "this is how we do it, here's why" beats "adds optional support for X." By contributing, you agree to the MIT License.

## Status

Early. Opinionated. Shipped as *how we actually work*, not as a polished product. Take what's useful, fork it, adapt it.

## License

[MIT](./LICENSE) © yazilim.vip
