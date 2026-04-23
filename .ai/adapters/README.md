# Adapters

Framework procedure — read when the user asks to set up, generate, or refresh an agent adapter (Claude Code, Kiro, and future platforms). Not a skill.

## Why adapters exist

Each agent has its own rules/memory/steering/hook convention, and none of them read NOVA's files the same way. Adapters bridge the gap by giving each host agent a tiny pointer — in its native format — that tells it where NOVA's real instructions live, plus platform-native enforcement that converts prose suggestions into deterministic context.

**The enforcement contract lives at `.ai/enforcement.md`.** Three MUST capabilities (session-start broadcast, per-turn re-injection, scoped activation) and two SHOULD capabilities (pre-edit gate, focused subagent). Every adapter's README maps the contract to its platform-native mechanism. Read the contract before editing an adapter.

Note: **Claude Code does not natively read `AGENTS.md`** (only `CLAUDE.md`). A committed root `CLAUDE.md` with the plain text "read AGENTS.md" is a text instruction, not enforcement. The Claude adapter strengthens this by generating a `.claude/CLAUDE.md` that uses Claude's native `@path` import syntax to load `AGENTS.md` (plus workspace `AGENTS.md` and `repos.md`) into context at session start — transitive `@` expansion, same mechanism as any `CLAUDE.md`.

## Core principle — **STRICT**

**Adapters are pointers. Not copies.**

Every rule NOVA enforces — safety, navigation, identity, skills — already lives in `AGENTS.md`, `.ai/workspace/`, or `.ai/<procedure>/`. An adapter's only job is to tell the host agent "read those files, obey them, do not paraphrase them." Observed failure mode: when adapters duplicate content, the host agent reads the copy once and never consults the source, so rules drift, updates in `.ai/` go unnoticed, and the steering files grow into a second source of truth that contradicts the first.

**Rules for authoring an adapter template:**

1. **Reference, never reproduce.** Steering/rules files MUST point at paths under `AGENTS.md` or `.ai/`. They MUST NOT copy rule text from those files. If you see yourself typing a safety rule, a navigation step, or an identity line into a steering file — stop. Write a reference instead.
2. **Only platform-specific content may live in the adapter directory.** Example: Kiro's terminal-hang rules only apply to Kiro, so they live at `.ai/adapters/kiro/terminal.md`. The steering file references that path. A rule that applies to all agents does not belong in an adapter — it goes in `AGENTS.md` or `.ai/`.
3. **The steering/rules file must instruct the host agent to read the source, not to trust the shim.** Phrasing like "Read `AGENTS.md` and obey it. Do not paraphrase." is the pattern.
4. **If the host agent ignores the pointer and makes things up, that is a host-agent problem, not an excuse to duplicate.** Strengthen the pointer's language first. Duplication is a last resort and must be discussed.

## Directory shape

Each platform directory has three kinds of files:

| Subdir / file | Purpose | Copied to user workspace? |
|---------------|---------|---------------------------|
| `.ai/adapters/<platform>/README.md` | Adapter README — capability mapping table, platform specifics. | No — framework-committed docs. |
| `.ai/adapters/<platform>/steering/` | Templates for the platform's rules engine. Pure pointers. | Yes — copied to platform's output dir. |
| `.ai/adapters/<platform>/hooks/` | Hook scripts + platform hook config (e.g. `.kiro.hook`). Reference `_shared/` content. | Yes — copied + chmod +x. |
| `.ai/adapters/<platform>/agents/` | Subagent templates (markdown with YAML frontmatter). Pre-load scoped context into a fresh window. | Yes — copied to platform's agents output dir. |
| `.ai/adapters/<platform>/*.md` (top-level) | Platform-specific rule sources of truth, referenced from steering/hooks. | No — stay in framework, referenced by path. |
| `.ai/adapters/<platform>/*-snippet.json` | Settings fragments to merge into the platform's config. | Merged, not copied wholesale. |

**`.ai/adapters/_shared/`** is not a platform directory — it holds content used by every adapter (e.g. `checklist.md` consumed by all per-turn hooks). The adapter procedure MUST skip `_shared/` when enumerating platforms.

## Supported platforms

| Platform | Adapter dir | Output dir | Enforcement primitives used |
|----------|-------------|-----------|-----------------------------|
| Claude Code | `.ai/adapters/claude/` | `.claude/` | `@path` imports + `SessionStart` / `UserPromptSubmit` hooks + subdir `CLAUDE.md` shims |
| Kiro | `.ai/adapters/kiro/` | `.kiro/` | `inclusion: always/fileMatch` steering + `#[[file:]]` live refs + `promptSubmit` hook |

### Kiro — terminal hazards

Kiro has known terminal integration bugs that hang the CLI session on heredocs, complex multi-line commands, long-running processes, and certain shell themes. Strict rules live in `.ai/adapters/kiro/terminal.md` (source of truth), referenced by the steering pointer in `.ai/adapters/kiro/steering/nova.md`. Treat them as non-negotiable — they exist because users hit those hangs repeatedly.

### Claude Code — see `.ai/adapters/claude/README.md`

Full capability mapping and platform specifics (chained `@` imports, `SessionStart` + `UserPromptSubmit` hooks, auto-memory redirection, subdir shims for per-repo scope) live in the adapter's own README. Read it when editing any `.ai/adapters/claude/` file.

### Kiro — see `.ai/adapters/kiro/README.md`

Full capability mapping and platform specifics (`inclusion: always/fileMatch` steering, `#[[file:]]` live references, `promptSubmit` hook) live in the adapter's own README.

More platforms get added as they're supported.

## When to Trigger

- "set up kiro adapter", "generate kiro steering", "make nova work in kiro"
- User mentions their IDE isn't reading `AGENTS.md`
- Optional: during onboarding, if the user names a non-Claude agent as their primary tool

## Procedure

1. **Confirm the platform.** Ask which IDE/agent the user wants to adapt for. Only supported platforms from the table above. Skip `_shared/` — it is not a platform.
2. **Check the output directory.**
   - If it doesn't exist, create it.
   - If it already has files, list them and ask before overwriting. Don't clobber existing user customizations silently.
3. **Copy steering templates.** Copy everything under `.ai/adapters/<platform>/steering/` to the platform's steering output directory. Do **not** copy top-level rule sources (e.g. `terminal.md`) — they stay in the framework and are referenced by path from the steering files.
4. **Install subagents.** For each file in `.ai/adapters/<platform>/agents/`:
   - Copy to the platform's agents runtime directory (`.claude/agents/`, `.kiro/agents/`).
   - Preserve existing user-authored agents — ask before overwriting if the target exists and differs from the template.
   - Claude Code: subagents load at session start. User must restart Claude Code or use `/agents` to reload after changes.
5. **Install hooks.** For each file in `.ai/adapters/<platform>/hooks/`:
   - Copy `*.sh` scripts into the platform's runtime hook directory (`.claude/hooks/`, `.kiro/hooks/`).
   - `chmod +x` each copied script.
   - Copy platform hook config files (`*.kiro.hook` for Kiro) into the same runtime hook directory.
   - Verify each script is readable and executable; do a dry-run `bash -n` syntax check before considering the step done.
   - **Never rewrite a user's existing hook script without asking** — if the target path exists and differs, surface the diff first.
6. **Merge settings snippets, if any.** If the platform ships a `*-snippet.json` under `.ai/adapters/<platform>/`, merge it into the platform's local settings file — **merge, don't overwrite**. Rules:
   - Preserve every existing top-level key (permissions, env, etc.).
   - For nested arrays (e.g. `hooks.SessionStart`), append entries — do not replace the array. User-authored hooks must survive the merge.
   - Example: Claude → merge `.ai/adapters/claude/settings-snippet.json` into `.claude/settings.local.json`.
   - Prefer a dry-run diff output to the user before applying if ambiguity exists.
7. **Generate per-repo artifacts (C3 — scoped rule activation).** For each cloned repo under `git-repositories/` that also appears in `.ai/workspace/map/repos.md`:
   - **Claude:** render `.ai/adapters/claude/templates/repo-shim.md` with `{{REPO_NAME}}` and `{{REPO_PATH}}` → `git-repositories/<repo-path>/.claude/CLAUDE.md`. Do **not** write anywhere else inside the repo. The file is gitignored by the repo's own `.gitignore` (add `.claude/` to the repo's `.gitignore` if absent — ask the user first, since we're touching a different repo).
   - **Kiro:** render `.ai/adapters/kiro/templates/repo-steering.md` → `.kiro/steering/<slug>.md` where `<slug>` is the repo's path with `/` replaced by `-`.
   - Skip repos in `repos.md` that aren't cloned. Warn on repos that are cloned but missing from `repos.md`.
   - Idempotency: if the target file already exists and matches the template, do nothing. If it differs (user edited), show the diff and confirm before overwriting.
8. **Verify `.gitignore`.** The platform's output directory must be gitignored at the workspace root. If it's not, add it and tell the user.
9. **Report.** Tell the user what was generated, where, and how to test it:
   - Restart the agent.
   - Open a chat; confirm the agent references NOVA's files rather than repeating their contents.
   - For per-turn hooks: ask the agent "was a NOVA checklist injected this turn?" — a yes confirms C2 is wired.
   - For scoped activation: open a file under `git-repositories/<any-repo>/`, ask "what are this repo's conventions?" — the agent should answer without a prior tool call.
   - For subagents: ask "is a repo-worker subagent available?" — Claude should list it via `/agents` or its description. Invoke it with a bounded task in a named repo.

## Authoring rules (when editing templates)

- **Never commit generated adapter files.** They're machine-local — the framework regenerates them on demand.
- **Never modify the user's existing steering/rules files without asking.** If they've hand-written something, surface it first.
- **Reference, never reproduce.** See Core Principle above. This is the rule adapters exist to enforce; breaking it defeats the purpose.
- **When NOVA's navigation protocol or safety rules change, adapter templates usually need no edits** — they reference paths, not content. That's the whole point.
