# NOVA — Workspace Engineering Intelligence

A minimal, opinionless framework for running AI agents across multi-repo development workspaces. Originated and maintained by the [yazilim.vip](https://yazilim.vip) crew; shipped for anyone who wants it.

NOVA is a markdown-based framework built on the [AGENTS.md](https://agents.md) convention. It gives an AI agent a consistent identity, safety rules, and navigation protocol across a multi-repo workspace — so the agent behaves the same way whether you're in Claude Code, Cursor, Codex, or any other AGENTS.md-compatible tool.

**NOVA does not ship opinions and does not ship skills.** Opinions about how you write code, use git, run Kubernetes, or manage infrastructure belong to you. The framework ships only its own machinery: how to onboard a new workspace, how to pull upstream changes deliberately, and a convention for how individual projects organize their agent-facing content.

## What you get

- **`AGENTS.md`** — the agent's identity, safety rules, and navigation protocol.
- **`SOUL.md`** — voice and depth, loaded only when the task demands it.
- **`.ai/enforcement.md`** — platform-agnostic contract that turns prose rules into deterministic agent behavior (session-start broadcast, per-turn re-injection, scoped activation, optional pre-edit gate, focused subagent).
- **`.ai/adapters/`** — per-platform implementations of the enforcement contract. Ships [Claude Code](.ai/adapters/claude/README.md) and [Kiro](.ai/adapters/kiro/README.md) today; pluggable for more.
- **Framework procedures under `.ai/<name>/`** — read on trigger:
  - `onboarding/` — guided workspace setup.
  - `self-update/` — deliberate upstream sync.
  - `adapters/` — generate per-platform steering, hooks, subagents.
  - `ide/` — editor setup. IntelliJ multi-module project; Neovim with `claudecode.nvim` MCP bridge.
  - `terminal/` — terminal multiplexer (tmux) and host-emulator settings Claude requires.
  - `dream/` — periodic memory consolidation pass over learnings + drift log.
- **`.ai/project-structure.md`** — NOVA's convention for a single project's AGENTS.md / `.ai/` layout. A reference doc.
- **`.ai/workspace/`** — the local workspace instance (gitignored; populated during onboarding). **Your skills live here** at `.ai/workspace/skills/<name>/SKILL.md`, in the [agentskills.io](https://agentskills.io) format.
- **`git-repositories/`** — the clone convention (`<platform>/<group>/<repo>`; gitignored).

**Mental model:**
- `.ai/<name>/` = NOVA's own procedures (read on trigger).
- `.ai/*.md` = NOVA's conventions (read when context demands).
- `.ai/adapters/` = per-platform pointers + hooks + subagents (committed; runtime outputs like `.claude/`, `.kiro/` are gitignored, regenerable).
- `.ai/workspace/` = yours (local, gitignored). Skills, infra config, learnings — all yours.

NOVA never writes into `.ai/workspace/` upstream and never ships a committed skills folder. Your skills stay local by default.

## Why workspace-level, not repo-level?

Most agent tooling operates inside a single repo. Real engineering work spans many repos — apps, infra, shared libraries, docs. NOVA sits one level above: it's the thing that tells the agent *which* repo to enter, what conventions it uses, and where your tooling lives.

## Why prose plus enforcement?

LLM compliance with prose rules is probabilistic, and attention to mid-context instructions decays as the conversation grows. NOVA's `AGENTS.md` is the prose; `.ai/adapters/` is what makes it stick:

- **Session-start broadcast** — workspace identity + nav protocol injected at position 0 (Claude `@`-imports, Kiro `inclusion: always` steering).
- **Per-turn re-injection** — a 5-line checklist re-injected on every user prompt via platform hooks, refreshing attention at the end of context where it's strongest.
- **Scoped activation** — entering `git-repositories/<repo>/` auto-loads that repo's `AGENTS.md` (Kiro `fileMatch`; on Claude, delegated to the `repo-worker` subagent).
- **Optional pre-edit gate** — `fs_write` under a repo blocks until that repo's `AGENTS.md` was read this session (Kiro `preToolUse` hook; opt-in).
- **Focused subagents** — `repo-worker` and `dream-worker` ship as fresh-context archetypes with the rulebook pre-walked at definition time.

The full contract lives at [.ai/enforcement.md](.ai/enforcement.md). Adapters are pointers, never copies — every rule still has one source of truth.

## Getting started

1. Clone this repo into a new workspace directory.
2. Open the workspace in your agent (Claude Code, Kiro, Cursor, Codex, etc.).
3. Say **"set up my workspace"** — NOVA will guide you through onboarding.
4. Say **"set up the \<platform> adapter"** to generate platform-native steering, hooks, and subagents (`.claude/`, `.kiro/`).
5. (Optional) Clone your project repos into `git-repositories/` following the `<platform>/<group>/<repo>` convention.

Manual alternative: copy `.ai/onboarding/assets/map/repos.md` → `.ai/workspace/map/repos.md` and `.ai/onboarding/assets/infra.md` → `.ai/workspace/infra.md`, then fill them in yourself.

## What onboarding looks like

NOVA uses a guided conversation — it asks 2-3 questions at a time, adapts to your answers, and generates the workspace instance files at the end.

See a full example conversation in [.ai/onboarding/assets/example-dialogue.md](.ai/onboarding/assets/example-dialogue.md) — identity → repos → infra → rules → AI tool → generated-files preview, plus short variants for skipping a topic, adding a repo later, and the first post-onboarding task.

## Bringing your own skills

Author them in the [agentskills.io](https://agentskills.io) format and drop them at `.ai/workspace/skills/<name>/SKILL.md`. That path is gitignored — machine-local, per-developer.

**Sharing skills across a team is a fork-level decision, not a framework one.** Common patterns teams use:

- Fork NOVA and override `.gitignore` in your fork to commit `.ai/workspace/skills/`.
- Keep team skills in a separate repo and symlink or copy them in.
- Use any other sharing convention that fits your team.

NOVA stays out of that choice — it doesn't ship a prescribed "team skills" slot because prescribing one would push teams into a pattern that doesn't suit them.

Example skill frontmatter:

```markdown
---
name: my-skill
description: One-line description of what this skill does and when to use it.
metadata:
  author: your-name
  version: "0.1.0"
---
```

## Staying current with upstream

If you've forked NOVA, sync deliberately — don't blind-merge:

```bash
git remote add upstream https://github.com/yazilim-vip/nova-workspace.git
```

Then ask your agent to "sync with upstream". It'll follow the flow in [.ai/self-update/SKILL.md](.ai/self-update/SKILL.md): fetch, classify each change, surface conflicts, apply or skip with reasons recorded.

## Contributing upstream

If you've built framework-level improvement — a better onboarding question, a fix to the self-update flow, a clearer convention — open a PR. Keep it focused: framework changes, not opinions. By contributing, you agree to the MIT License.

## Status

Early. Minimal on purpose. Shipped as *how our crew runs its agent workflow*, not as a polished product. Take what's useful, fork it, adapt it.

## License

[MIT](./LICENSE) © yazilim.vip
