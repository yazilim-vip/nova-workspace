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
overrides:                          # optional — per-surface escape hatches
  claude:
    <claude-only fields>
  kiro_cli:
    <kiro-cli-only JSON fields>
  kiro_ide:
    <kiro-ide-only frontmatter fields>
---
```

## Body

The agent's system prompt. Markdown. Each surface inlines or embeds it natively:
- Claude: body of `.claude/agents/<name>.md` after the frontmatter.
- Kiro CLI: inlined as the `prompt` field (string) in the JSON. (Kiro CLI's `prompt` field also accepts `file://` URIs, but NOVA generators inline the string for self-containment — see Anti-patterns.)
- Kiro IDE: body of `.kiro/agents/<name>.md` after the frontmatter.

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

## Surfaces

Three host surfaces, each with its own native format. **Clean separation — each output file is self-contained; no cross-references between surfaces.**

Verified against [Kiro CLI agent configuration reference](https://kiro.dev/docs/cli/custom-agents/configuration-reference/) and [Kiro IDE subagents docs](https://kiro.dev/docs/chat/subagents/) (both retrieved 2026-04-30).

| Surface | Native format | Workspace path | Global path | Notes |
|---------|--------------|----------------|-------------|-------|
| Claude Code | Markdown (YAML frontmatter + body) | `.claude/agents/<n>.md` | `~/.claude/agents/<n>.md` | Claude's native subagent loader. |
| Kiro CLI | JSON (single self-contained file) | `.kiro/agents/<n>.json` | `~/.kiro/agents/<n>.json` | Kiro CLI reads JSON. Prompt goes into the `prompt` field as an inlined string. |
| Kiro IDE | Markdown (YAML frontmatter + body) | `.kiro/agents/<n>.md` | `~/.kiro/agents/<n>.md` | Kiro IDE reads markdown. Frontmatter carries config, body carries the prompt. |

**The two Kiro surfaces share the same directory `.kiro/agents/`**; they're disambiguated by file extension (`.json` for CLI, `.md` for IDE). Both surfaces co-exist in that one directory by design — that's how Kiro's loaders find them. NOVA does not split them into subfolders.

**One canonical AGENT.md fans out to one file per surface.** A spec relevant to both Kiro CLI and Kiro IDE generates two distinct files (`<n>.json` and `<n>.md`) in the same `.kiro/agents/` directory. The two files are independent artifacts of the same source; **neither references the other**.

If the user runs only Claude Code, only `.claude/agents/<n>.md` is generated; the Kiro generators are no-ops. Same for the inverse.

## Platform translation (generator's job)

Each adapter's generator translates this neutral spec into the native format for its surface. Per-surface translation tables live in each generator's procedure file:

- Claude → `.ai/adapters/claude/agent-gen.md`
- Kiro CLI → `.ai/adapters/kiro/cli-agent-gen.md` (when built)
- Kiro IDE → `.ai/adapters/kiro/ide-agent-gen.md` (when built)

The neutral spec fields and their canonical meaning + per-surface mapping:

| Spec field | Meaning | Claude (MD frontmatter) | Kiro CLI (JSON field) | Kiro IDE (MD frontmatter) |
|------------|---------|-------------------------|-----------------------|---------------------------|
| `name` | Stable identifier. | filename + frontmatter `name` | filename (without `.json`) becomes the name; optional `name` field overrides | filename (without `.md`) is default; required frontmatter `name` |
| `description` | Auto-route key. | `description` | `description` | `description` |
| `tools` (neutral) | Tool allowlist. | `tools: Read, Edit, Bash, ...` (capitalized, comma-separated) | `tools: ["read", "write", "shell", ...]` (lowercase, array) | `tools: ["read", "write", "shell", ...]` (lowercase, array) |
| `resources` `file://` | Pre-loaded files. | `@`-imports inserted into the body (Claude has no `resources` array) | `resources: ["file://..."]` | not natively supported in IDE frontmatter — skip or surface in body |
| `resources` `skill://` | Pre-loaded skill files. | Read in body at runtime | `resources: ["skill://..."]` | not natively supported — skip |
| `model` | Model tier. | `model: sonnet/opus/haiku/inherit` | `model: "claude-sonnet-4"` (or platform-specific id) | `model: claude-sonnet-4` |
| `write_scope` | `fs_write` path restriction. | not enforced; body should respect | `toolsSettings.write.allowedPaths: [...]` | not natively supported |
| `welcome` | First-message hint. | not present in Claude | `welcomeMessage: "..."` | not in IDE frontmatter docs (TBD) |
| `keyboard_shortcut` | Keybinding. | ignored | `keyboardShortcut: "ctrl+shift+r"` | not in IDE frontmatter docs (TBD) |
| `mcp_servers` (allowlist) | MCP server activation. | settings.json `enabledMcpjsonServers` | `mcpServers: { ... }` (full inline config) or `includeMcpJson: true` | `includeMcpJson: true` / `includePowers: true` |
| `body` | System prompt. | markdown body after frontmatter | `prompt: "<inlined string>"` (NOT `file://` — keep self-contained) | markdown body after frontmatter |
| `overrides.claude` | Surface-specific escape. | merged into Claude frontmatter | ignored | ignored |
| `overrides.kiro_cli` | Surface-specific escape. | ignored | merged into Kiro CLI JSON | ignored |
| `overrides.kiro_ide` | Surface-specific escape. | ignored | ignored | merged into Kiro IDE frontmatter |

Each generator's procedure file holds the canonical table for its surface; keep this overview in sync.

## Anti-patterns

- **No platform-specific behavior in the body.** If two surfaces truly need different prompts, split into two agents or use `overrides.<surface>.system_prompt_append`.
- **No invented tool names.** Use the neutral set above. New neutral names require a spec update.
- **No empty `description`.** Without it the agent never auto-routes — it's invisible.
- **No paraphrasing of NOVA rules** in the body. Reference by path.
- **No mirrors.** Generators write directly to native locations from the canonical AGENT.md. Mirroring of any tier (skills, prompts, configs) is forbidden by C4.
- **No cross-surface file references.** Kiro CLI JSON's `prompt` field accepts inline strings OR `file://` URIs ([CLI configuration reference](https://kiro.dev/docs/cli/custom-agents/configuration-reference/)), but NOVA generators always inline the prompt as a string. Pointing the CLI's `prompt` at a `.md` file would create implicit coupling with the Kiro IDE file in the same `.kiro/agents/` directory. Each surface's output stands alone. The legacy paired `repo-worker.{json,md}` shape (where the JSON used `systemPromptFile` to reference the MD) is being phased out — note that `systemPromptFile` is not a documented CLI field; it is a convention from earlier internal use.

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
