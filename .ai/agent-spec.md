# NOVA Agent Spec

Canonical, platform-neutral format for NOVA agents. Each adapter ships a generator that emits this spec into the host's native agent format.

> **Status:** draft — ratifies the Agent-Native redesign. See `.ai/enforcement.md` § C4 (to be rewritten) for the binding contract.

## Why

Agent-Native NOVA: every NOVA capability is a native subagent on the host platform, dispatched via the host's native description-based auto-router. No skills tier, no platform skill folders, no manual invocation by name. The user describes a task; the host picks the right agent.

## Decisions baked into this spec

- **No `nova-*` prefix** on framework agents. Description-based routing makes name collisions a non-issue; framework vs workspace distinguishes by file path.
- **Mid-session new agents take effect next session.** Generators run at adapters-procedure time; no live re-registration. Simpler than the alternative.
- **`agent-author` writes to `.ai/workspace/agents/` by default.** Project-scoped agents go to `<repo>/.ai/agents/` only when the agent declares itself project-scoped during authoring.

## File location

- **Workspace agents** (user-authored, cross-repo): `.ai/workspace/agents/<name>/AGENT.md`
- **Framework agents** (NOVA-shipped): `.ai/<name>/AGENT.md`
- **Project agents** (single-repo): `<repo>/.ai/agents/<name>/AGENT.md` — declared in that repo's `AGENTS.md`

One agent = one folder. Folder may hold supporting files (templates, sub-prompts, fixtures).

## Frontmatter schema

```yaml
---
name: <agent-id>                    # required, kebab-case, unique within its scope
description: <auto-route prompt>    # required — host's auto-router matches against this; see § Description
tools:                              # optional — neutral tool names; generator maps to native
  - read
  - edit
  - write
  - bash
  - grep
  - glob
  - agent
resources:                          # optional — files/skills/URIs to pre-load
  - file://.ai/workspace/AGENTS.md
  - file://.ai/workspace/map/repos.md
model: sonnet | opus | haiku        # optional — tier hint; generator maps to platform default
write_scope:                        # optional — restrict fs_write paths
  - git-repositories/**
  - scripts/**
welcome: |                          # optional — first-message hint
  Brief note on what this agent does.
keyboard_shortcut: cmd+shift+g      # optional — Kiro-only; Claude ignores
mcp_servers:                        # optional — MCP server allowlist
  - github
  - bookmarks
overrides:                          # optional — per-platform escape hatches
  claude:
    <claude-only fields>
  kiro:
    <kiro-only fields>
---
```

## Body

The agent's system prompt. Markdown. Becomes:
- `systemPromptFile` reference in Kiro agent JSON
- Body of `.claude/agents/<name>.md` after the frontmatter

Write the prompt platform-neutrally. Reference NOVA conventions by path (`AGENTS.md`, `.ai/<...>`); never inline.

## Description (the most important field)

Hosts auto-route by matching the user's request against agent descriptions. Investment here = correct activation rate.

A good description states:
- **What it does** in one clause.
- **When to invoke** — verb-prompted patterns the user is likely to say.
- **When NOT to invoke** — adjacent capabilities, to disambiguate.

Example:
```
description: Manages git workflow — branching, conventional commits, MRs/PRs, multi-repo ops, semantic versioning. Use when the user mentions branches, commits, PRs, or releases. NOT for general code review (use code-quality) or CI debugging (use ci-cd).
```

## Platform translation (generator's job)

Each adapter's generator translates this neutral spec into native files:

| Spec field | Claude `.claude/agents/<n>.md` | Kiro `.kiro/agents/<n>.{json,md}` |
|------------|-------------------------------|-----------------------------------|
| name | filename `<n>.md` | filename + JSON `name` |
| description | frontmatter `description:` | JSON `description` |
| tools | frontmatter `tools:` (capitalized: `Read, Edit, Bash`) | JSON `tools` (`read, edit, execute_terminal_command`) + `toolsSettings` |
| resources `file://` | frontmatter `resources:` (file paths) | JSON `resources: ["file://path"]` |
| resources `skill://` | Claude has no native skill URI — load via Read in body | JSON `resources: ["skill://path"]` |
| model | frontmatter `model:` (`sonnet`/`opus`/`haiku`) | JSON `model:` (Kiro tier names) |
| write_scope | not enforced; body should respect | JSON `toolsSettings.fs_write.allowedPaths` |
| welcome | not present (Claude has no welcome surface) | JSON `welcomeMessage` |
| keyboard_shortcut | ignored | JSON `keyboardShortcut` |
| mcp_servers | settings.json `enabledMcpjsonServers` | JSON `mcpServers` |
| body | markdown body after frontmatter | `.md` referenced by JSON `systemPromptFile` |
| `overrides.claude` | merged into Claude frontmatter | ignored |
| `overrides.kiro` | ignored | merged into Kiro JSON |

## Anti-patterns

- **No platform-specific behavior in the body.** If Kiro and Claude truly need different prompts, split into two agents or use `overrides.<platform>.system_prompt_append`.
- **No invented tool names.** Use the neutral set above. New neutral names require a spec update.
- **No empty `description`.** Without it the agent never auto-routes — it's invisible.
- **No paraphrasing of NOVA rules** in the body. Reference by path.
- **No mirrors.** Generators write directly to native locations from the canonical AGENT.md. Mirroring of any tier (skills, prompts, configs) is forbidden by C4.

## Generator contract

Each adapter ships a generator invoked by the adapters procedure (`.ai/adapters/SKILL.md`):

1. Discover all `AGENT.md` under `.ai/`, `.ai/workspace/agents/`, and each registered project `<repo>/.ai/agents/`.
2. Parse frontmatter + body.
3. Translate per the table above.
4. Write native agent files to the host's native location (e.g. `.claude/agents/<n>.md`).
5. Delete runtime files from `.claude/agents/` / `.kiro/agents/` whose backing spec no longer exists.
6. Report what was generated, updated, or removed.

## Migration from `SKILL.md`

Old skills under `.ai/workspace/skills/<n>/SKILL.md` migrate by:
1. Move folder `.ai/workspace/skills/<n>/` → `.ai/workspace/agents/<n>/`.
2. Rename `SKILL.md` → `AGENT.md`.
3. Augment frontmatter (most fields infer from existing skill frontmatter; add `tools`, `model`, `write_scope` as needed).
4. Re-run each adapter's generator.

The `agent-author` meta-agent automates this — it walks an existing SKILL.md and produces the equivalent AGENT.md.
