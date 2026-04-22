# Adapters

Framework procedure — read when the user asks to set up, generate, or refresh a non-Claude agent adapter (Kiro, Cursor, Windsurf, Copilot, etc.). Not a skill.

## Why adapters exist

Each agent has its own rules/memory/steering convention, and none of them read NOVA's files the same way. Adapters bridge the gap by giving each host agent a tiny pointer — in its native format — that tells it where NOVA's real instructions live.

Note: **Claude Code does not natively read `AGENTS.md`** (only `CLAUDE.md`). A committed root `CLAUDE.md` with the plain text "read AGENTS.md" is a text instruction, not enforcement. The Claude adapter strengthens this by generating a `.claude/CLAUDE.md` that uses Claude's native `@path` import syntax to load `AGENTS.md` into context at session start — same mechanism as any `CLAUDE.md`.

## Core principle — **STRICT**

**Adapters are pointers. Not copies.**

Every rule NOVA enforces — safety, navigation, identity, skills — already lives in `AGENTS.md`, `.ai/workspace/`, or `.ai/<procedure>/`. An adapter's only job is to tell the host agent "read those files, obey them, do not paraphrase them." Observed failure mode: when adapters duplicate content, the host agent reads the copy once and never consults the source, so rules drift, updates in `.ai/` go unnoticed, and the steering files grow into a second source of truth that contradicts the first.

**Rules for authoring an adapter template:**

1. **Reference, never reproduce.** Steering/rules files MUST point at paths under `AGENTS.md` or `.ai/`. They MUST NOT copy rule text from those files. If you see yourself typing a safety rule, a navigation step, or an identity line into a steering file — stop. Write a reference instead.
2. **Only platform-specific content may live in the adapter directory.** Example: Kiro's terminal-hang rules only apply to Kiro, so they live at `.ai/adapters/kiro/terminal.md`. The steering file references that path. A rule that applies to all agents does not belong in an adapter — it goes in `AGENTS.md` or `.ai/`.
3. **The steering/rules file must instruct the host agent to read the source, not to trust the shim.** Phrasing like "Read `AGENTS.md` and obey it. Do not paraphrase." is the pattern.
4. **If the host agent ignores the pointer and makes things up, that is a host-agent problem, not an excuse to duplicate.** Strengthen the pointer's language first. Duplication is a last resort and must be discussed.

## Directory shape

Each platform directory has two kinds of files:

| Subdir | Purpose | Copied to user workspace? |
|--------|---------|---------------------------|
| `.ai/adapters/<platform>/steering/` | Templates for the platform's rules engine. Pure pointers. | Yes — copied to platform's output dir on generate. |
| `.ai/adapters/<platform>/*.md` (top-level) | Platform-specific rule sources of truth, referenced from the steering templates. | No — stay in framework, referenced by path. |

## Supported platforms

| Platform | Steering templates | Output dir | Inclusion mechanism |
|----------|-------------------|-----------|---------------------|
| Kiro | `.ai/adapters/kiro/steering/` | `.kiro/steering/` | YAML front matter (`inclusion: always`) |
| Claude Code | `.ai/adapters/claude/steering/` | `.claude/` | `@path` imports (native to `CLAUDE.md`) |

### Kiro — terminal hazards

Kiro has known terminal integration bugs that hang the CLI session on heredocs, complex multi-line commands, long-running processes, and certain shell themes. Strict rules live in `.ai/adapters/kiro/terminal.md` (source of truth), referenced by the steering pointer in `.ai/adapters/kiro/steering/nova.md`. Treat them as non-negotiable — they exist because users hit those hangs repeatedly.

### Claude Code — import-based pointer

Claude Code reads `CLAUDE.md` natively and supports `@path` imports that expand into context at session start. The generated `.claude/CLAUDE.md` uses `@../AGENTS.md` to robustly load the framework instructions, rather than relying on a plain text "read AGENTS.md" instruction (which is context, not enforcement). No Claude-specific rule sources currently — Claude Code's host behavior is well-aligned with NOVA's expectations out of the box.

More platforms get added to the table as they're supported.

## When to Trigger

- "set up kiro adapter", "generate kiro steering", "make nova work in kiro"
- User mentions their IDE isn't reading `AGENTS.md`
- Optional: during onboarding, if the user names a non-Claude agent as their primary tool

## Procedure

1. **Confirm the platform.** Ask which IDE/agent the user wants to adapt for. Only supported platforms from the table above.
2. **Check the output directory.**
   - If it doesn't exist, create it.
   - If it already has files, list them and ask before overwriting. Don't clobber existing user customizations silently.
3. **Copy steering templates only.** Copy everything under `.ai/adapters/<platform>/steering/` to the platform's output directory. Do **not** copy top-level rule sources (e.g. `terminal.md`) — they stay in the framework and are referenced by path from the steering files.
4. **Verify `.gitignore`.** The platform's output directory must be gitignored at the workspace root. If it's not, add it and tell the user.
5. **Report.** Tell the user what was generated, where, and how to test it (restart the agent, open a chat, confirm it references NOVA's files rather than repeating their contents).

## Authoring rules (when editing templates)

- **Never commit generated adapter files.** They're machine-local — the framework regenerates them on demand.
- **Never modify the user's existing steering/rules files without asking.** If they've hand-written something, surface it first.
- **Reference, never reproduce.** See Core Principle above. This is the rule adapters exist to enforce; breaking it defeats the purpose.
- **When NOVA's navigation protocol or safety rules change, adapter templates usually need no edits** — they reference paths, not content. That's the whole point.
