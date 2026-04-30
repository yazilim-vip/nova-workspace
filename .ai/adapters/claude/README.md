# Claude Code Adapter

Implements `.ai/enforcement.md` for [Claude Code](https://code.claude.com). Generates `.claude/` at the workspace root — gitignored, per-developer, regenerable by the adapters procedure (`.ai/adapters/SKILL.md`).

## Capability mapping

| Capability | Mechanism | Source file | Generated output |
|------------|-----------|-------------|------------------|
| **C1** Session-start broadcast | `SessionStart` hook (matcher `startup\|resume\|clear`) prints `.ai/adapters/_shared/checklist.md`. **Currently empty** (subtraction pass 2026-04-30) — mechanism intact; refill the checklist file to re-enable. | `hooks/session-start.md` (bash code block extracted at install) | `.claude/hooks/session-start.sh` |
| **C2** Per-turn re-injection | `UserPromptSubmit` hook prints the shared checklist + emits `task-pointers.md` matches. **Both currently silent** (subtraction pass 2026-04-30) — checklist + pointer patterns emptied; refill either file to re-enable. | `hooks/user-prompt-submit.md` (bash code block extracted at install) | `.claude/hooks/user-prompt-submit.sh` |
| **C3** Scoped rule activation | *Not implemented in the main agent.* Claude Code's only viable mechanism (a subdir `CLAUDE.md` shim) requires writing into someone else's git tree, which NOVA refuses to do. Delegated entirely to **S2** — the `repo-worker` subagent — whose system prompt makes "read the named repo's `AGENTS.md`" its first action. | — | — |
| **C4** User-skill surfacing | Mirror inlined in the Claude session-start (and per-turn) hook bash. Source `.ai/workspace/skills/` → destination `.claude/skills/`. `rsync --delete` preferred, `cp -R` fallback. Claude's native skill loader then picks up workspace skills as if they were authored there. Hand-authored Claude-only skills must live at `~/.claude/skills/` (user-scoped) — `.claude/skills/` is exclusive to the mirror. | `hooks/session-start.md`, `hooks/user-prompt-submit.md` (sync logic inlined in each bash block) | `.claude/skills/<name>/SKILL.md` (mirrored on every session start + per-turn) |
| **C5** PKM agent doctrine | **Disabled in Claude main agent (subtraction pass 2026-04-30).** Was `@`-imported into `steering/CLAUDE.md`; the import was dropped to reduce always-on token weight since PKM features fire only when the user invokes them. The doctrine file still exists; PKM-relevant work should read it on demand. Re-enable by adding `@../.ai/adapters/_shared/personal-knowledge-management.md` back to `steering/CLAUDE.md`. Kiro keeps the always-on import. | `.ai/adapters/_shared/personal-knowledge-management.md` | Read on demand |
| **Skills** | See **C4** above — workspace user skills are mirrored from `.ai/workspace/skills/` into `.claude/skills/` so the native loader sees them. Framework `nova-*` skills do **not** land in `.claude/skills/`; they stay at `.ai/<name>/SKILL.md` and load via the AGENTS.md "Framework Skills" table reference. Hand-authored Claude-only skills go at `~/.claude/skills/` (user-scoped) — `.claude/skills/` is owned by the C4 mirror. | `.ai/workspace/skills/<name>/SKILL.md` (source) | `.claude/skills/<name>/SKILL.md` (mirrored) |
| **S1** Pre-edit gate | `PreToolUse` hook matching `Edit\|Write\|MultiEdit` returns exit 2 to block writes under `git-repositories/<repo>/` until that repo's `AGENTS.md` was read this session. Companion `PostToolUse` hook on `Read` drops a session marker on AGENTS.md reads. **Default-ON** (Kiro keeps it opt-in; Claude has reliable session id and gentler escape hatches). | `hooks/pre-edit-gate.md` + `hooks/pre-edit-gate-tracker.md` | `.claude/hooks/pre-edit-gate.sh` + `.claude/hooks/pre-edit-gate-tracker.sh` |
| **S2** Focused subagent | Native Claude Code subagent (auto-delegated or invoked explicitly) | `agents/repo-worker.md` | `.claude/agents/repo-worker.md` |

## How the pointer chain works

`.claude/CLAUDE.md` is Claude Code's native entry point. Our generated copy contains two `@` imports that Claude Code expands transitively into context at session start:

```
@../AGENTS.md
@../.ai/workspace/AGENTS.md
```

This handles framework defaults + workspace identity automatically. The repository map (`.ai/workspace/map/repos.md`) and PKM doctrine were previously auto-loaded too — both were dropped on 2026-04-30 to reduce always-on token weight; the agent reads them on demand when the task calls for them.

Step 4 (per-repo `AGENTS.md`) is **NOT** auto-loaded in the main agent. The historical mechanism — a subdir `CLAUDE.md` shim under `git-repositories/<repo>/` — was removed because it forced every cloned repo to either gitignore the generated path or live with persistent untracked-file noise, and we don't want the adapters procedure writing inside someone else's git tree at all. Per-repo activation is handled in two ways instead:

- **`repo-worker` subagent (S2)** — fresh context, target repo named at invocation, system prompt makes "read this repo's `AGENTS.md`" its first action. Use this whenever a task is bounded to one repo.
- **Manual Navigation Protocol step 4** — when staying in the main agent for an ad-hoc task in a repo, the agent reads that repo's `AGENTS.md` explicitly via the Navigation Protocol.

## Hooks

Hook **sources** are markdown (`hooks/<name>.md`) — each contains one fenced bash code block plus prose explaining purpose, runtime path, and mode. The adapters procedure extracts the bash block and writes the runtime `.sh` (gitignored). No `.sh` files are committed under `.ai/`. macOS / Linux only — Windows users pending.

Both hooks `cat` the shared checklist (`.ai/adapters/_shared/checklist.md`). They add no Claude-specific rule text — the checklist is the single source of truth across all platforms. The C4 user-skill mirror logic is inlined in the bash block of each hook (deliberate duplication, two hook files only, bounded). If future Claude-only enforcement is needed, write a new hook source under `hooks/<name>.md` and register the runtime path in `settings-snippet.json`.

Exit codes:
- `0` → stdout appended to Claude's context (success path — what we want).
- `2` → blocking error, stdout ignored, stderr shown to Claude. **Our hooks never exit 2.** Fail-open: if the checklist file is missing, the hook should still exit 0 silently.
- Other → non-blocking error, execution continues.

## Settings snippet

`settings-snippet.json` is merged (not overwritten) into `.claude/settings.local.json` during the adapters procedure. Current contents:

- `autoMemoryDirectory` — redirects auto-memory into `.claude/memory/` (per-project, not per-user). Claude Code explicitly refuses this key from shared `.claude/settings.json` to prevent a shared repo from hijacking a teammate's memory path — that's why it lives in `settings.local.json`.
- `hooks.SessionStart` (matcher `startup|resume|clear`) — fires `session-start.sh` for C1 + C4.
- `hooks.UserPromptSubmit` — fires `user-prompt-submit.sh` for C2 + C4 + task-aware pointers.
- `hooks.PreToolUse` (matcher `Edit|Write|MultiEdit`) — fires `pre-edit-gate.sh` for S1.
- `hooks.PostToolUse` (matcher `Read`) — fires `pre-edit-gate-tracker.sh` to clear S1 on AGENTS.md reads.

**Merge rule.** Existing top-level keys (permissions, etc.) are preserved. Inside `hooks`, entries are appended to the event's array — existing user hooks are not clobbered.

**Disabling S1.** If the pre-edit gate becomes friction-heavy, remove **both** the `PreToolUse` and `PostToolUse` blocks from `.claude/settings.local.json`. Removing only one half leaves the gate active without a way to clear it.

## Anti-duplication

Hooks `cat` a shared file. They do not paraphrase. If future work tempts you to inline a rule into a hook script, re-read `.ai/adapters/SKILL.md` — the adapter is a pointer, not a copy. Same rule binds hooks.

## Subagents

### `agents/repo-worker.md`

Generic archetype for tasks scoped to one repo under `git-repositories/`. It:

- Pre-loads framework + workspace + repo-map via `@../../AGENTS.md`, `@../../.ai/workspace/AGENTS.md`, `@../../.ai/workspace/map/repos.md` (paths resolve from the runtime location `.claude/agents/repo-worker.md`).
- Runs in a fresh context window — zero rot.
- System prompt instructs it to read the target repo's own `AGENTS.md` as its first action. Since NOVA no longer ships subdir `CLAUDE.md` shims, this is the canonical C3 mechanism on Claude — there is no fallback path inside the cloned repo's tree.

**When to invoke.** When main context is getting long, when a task is bounded to one repo, or explicitly: *"Use repo-worker to <task> in <repo>"*. Claude auto-delegates based on the subagent's description; manual invocation via `/agents` also works.

### `agents/dream-worker.md`

Memory-consolidation archetype. Read-only (`tools: Read, Grep, Glob`). Reviews `.ai/workspace/learnings/`, `.ai/workspace/drift-log.md`, and per-repo `AGENTS.md` files; returns a structured Dream Report of proposals. User approves; parent applies.

**When to invoke.** User-triggered only — via `/dream` slash command, or explicit "use the dream-worker subagent". Auto-invocation is disabled on the command side so Claude doesn't proactively tidy the workspace. Full procedure at `.ai/dream/SKILL.md`.

### Adding archetypes

Don't add `frontend-repo`, `backend-repo`, etc. speculatively — only when a concrete pattern is repeating and its maintenance cost is clearly worth it.

## Skills

Three lanes, three locations:

- **Workspace user skills** — authored once at `.ai/workspace/skills/<name>/SKILL.md` (committed, source of truth). Mirrored to `.claude/skills/<name>/SKILL.md` on every session start by `_shared/sync-skills.sh` (capability **C4**). Claude's native loader picks them up at trigger time as if they were authored there.
- **Hand-authored Claude-only skills** — live at `~/.claude/skills/<name>/SKILL.md` (user-scoped). Loaded by Claude regardless of project. Use this lane for things that are specific to your Claude setup and don't belong in the shared workspace skills source.
- **Framework skills (`nova-*`)** — stay at `.ai/<name>/SKILL.md` (committed). Load via the root `AGENTS.md` "Framework Skills" table — that table is `@`-imported into context at session start and the agent reasons against each skill's `description` to route.

**Why mirror instead of authoring directly under `.claude/skills/`.** `.claude/` is gitignored / per-developer. Authoring there means workspace skills become per-machine and aren't shared across team members or across the same user's machines. Authoring at `.ai/workspace/skills/` keeps a single committed source of truth; the mirror just makes the platform's native loader see them.

**Why `.claude/skills/` is exclusive to the mirror.** `rsync --delete` keeps the mirror exact — anything in `.claude/skills/` that isn't in `.ai/workspace/skills/` will be removed. Hand-authored Claude-only skills must therefore live at `~/.claude/skills/`, not at `.claude/skills/`. This is a deliberate ownership rule: keeping the dirs disjoint prevents the mirror from clobbering hand-authored work.

**Mid-session edits.** The user-prompt-submit hook re-runs the mirror, so edits to `.ai/workspace/skills/` land in `.claude/skills/` on the next prompt without requiring `/clear` (Claude may still need a session reset to fully re-read updated descriptions, depending on caching).

## Commands

### `commands/dream.md` → `/dream`

Shortcut that delegates to the `dream-worker` subagent. Uses `disable-model-invocation: true` — Claude will not invoke `/dream` on its own; only the user can trigger it. MVP is strictly user-triggered; scheduled/automatic dreaming is explicitly deferred per `.ai/dream/SKILL.md`.

### `commands/repo.md` → `/repo`

Shortcut that spawns the `repo-worker` subagent on a named repo with a task. Usage: `/repo <repo-name> <task>`. The command resolves the name against `.ai/workspace/map/repos.md` (and `repos-extended.md` if not found in the primary), then invokes the subagent with a self-contained prompt that pre-loads the repo's path and instructs "read its AGENTS.md first." Uses `disable-model-invocation: true` — user-triggered only.

### `commands/drift.md` → `/drift`

Shortcut that appends a one-line entry to `.ai/workspace/learnings/drift-log.md`. Usage: `/drift <freeform description of what the agent missed>`. The command reads the schema from the log file's header, parses the freeform input into the schema fields (using `unknown` where unclear), and appends in chronological order. Uses `disable-model-invocation: true` — user-triggered only. Without the log being kept, there's no measurement signal for whether the rest of the enforcement layer is actually working — `enforcement.md` § Measurement names this as the foundational feedback loop.

## Regeneration

Run the adapters procedure (`.ai/adapters/SKILL.md`). It:

1. Copies `steering/CLAUDE.md` → `.claude/CLAUDE.md`.
2. For each `hooks/<name>.md`, extracts its bash code block to `.claude/hooks/<name>.sh` and `chmod +x`.
3. Copies `agents/*.md` → `.claude/agents/`.
4. Merges `settings-snippet.json` into `.claude/settings.local.json` surgically.
5. Runs `.claude/hooks/session-start.sh` once at install time so the C4 mirror populates `.claude/skills/` immediately — the hook keeps it fresh from then on.
6. Reports what changed.

Runtime outputs (the workspace-root `.claude/` only) are gitignored. Sources under `.ai/adapters/claude/` are committed. The procedure does NOT write anywhere under `git-repositories/<repo>/` — see `.ai/adapters/SKILL.md` step 7 hard rule.
