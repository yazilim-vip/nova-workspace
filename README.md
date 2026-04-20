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

NOVA uses a guided conversation — it asks 2-3 questions at a time, adapts to your answers, and generates the workspace instance files at the end. Here's a condensed example.

---

**You:** set up my workspace

> **NOVA:** NOVA online. I'll need a few minutes to map the terrain — once I know your workspace, your repos, and your rules, I can be genuinely useful rather than a sophisticated guessing machine.
>
> Let's start with the basics: what are you building here, what's the org or workspace called, and is this primarily product work, infrastructure, open source, or something else?

**You:** It's called `acme-platform`. We're an e-commerce startup. Mix of product code and infra — one team, maybe 8 engineers.

> **NOVA:** Got it — `acme-platform`, product + infra, small team. Tell me about the repos. For each one:
> - Name, where it lives (GitHub/GitLab, group path)
> - What it does — one sentence is enough
> - Tech stack
>
> Start with the ones that matter most. We can fill in the rest later.

**You:** Main ones: `acme-api` (github.com/acme/platform/acme-api, Go + Postgres, our core API), `acme-web` (same group, Next.js frontend), `acme-infra` (Terraform modules for AWS). That's the critical three. We have a few more microservices but they're less active.

> **NOVA:** Three critical, a few satellites — noted. Let's talk infrastructure.
>
> Specifically: IaC tooling and whether there's a CLI wrapper I should use instead of raw terraform. Kubernetes clusters if any. How secrets are managed. Anything where the rule is "use this tool, not that one directly."

**You:** Plain Terraform, no wrapper yet. EKS cluster in AWS. Secrets in AWS Secrets Manager. The only strict rule: nobody runs `terraform apply` from their laptop against prod — that has to go through CI.

> **NOVA:** Good boundary. Last two questions.
>
> Any other rules I should treat as non-negotiable? Think: how repos get created/deleted, what needs approval before it runs, branch or CI requirements, anything that caused a problem before and now has a rule because of it.
>
> And: which AI assistant are you primarily using — Claude Code, Cursor, Codex, something else? I'll set up the right adapter.

**You:** Protected main branches on all repos, PRs need one approval. Using Claude Code.

> **NOVA:** Here's what I'll write. Review before I commit anything:
>
> 1. `.ai/workspace/map/repos.md` — acme-api, acme-web, acme-infra with paths and stacks
> 2. `.ai/workspace/infra.md` — Terraform, EKS, AWS Secrets Manager, the "no laptop apply to prod" rule
> 3. Update `AGENTS.md` Identity — workspace name `acme-platform`, e-commerce product + infra context
> 4. `.claude/` adapter enabled
>
> Look good, or want to adjust anything first?

---

Once you confirm, NOVA writes the files and drops a `.ai/workspace/.initialized` sentinel so future sessions skip onboarding. You can run onboarding again any time by deleting that file or asking to reconfigure.

### A few more flavors

**Skipping a topic:**

> **You:** Skip infra for now, we haven't decided.
>
> **NOVA:** Fine — I'll mark infra as TBD in the generated file and we can fill it in when you're ready. Moving on.

**Adding a repo later:**

> **You:** Add `acme-analytics` to the map — GitHub, same group, Python + dbt, internal data pipeline.
>
> **NOVA:** Adding. Should I treat it as critical (top-level in the map) or a satellite under `acme-platform`?

**First task after onboarding:**

> **You:** Let's add a new endpoint to acme-api.
>
> **NOVA:** Entering `acme-api`. Reading its `AGENTS.md`... Go + Postgres, gRPC-first, PRs require one approval. What's the endpoint — resource and behavior?

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
