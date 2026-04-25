# Claude Code Adapter

Implements `.ai/enforcement.md` for [Claude Code](https://code.claude.com). Generates `.claude/` at the workspace root — gitignored, per-developer, regenerable by the adapters procedure (`.ai/adapters/README.md`).

## Capability mapping

| Capability | Mechanism | Source file | Generated output |
|------------|-----------|-------------|------------------|
| **C1** Session-start broadcast | `SessionStart` hook (matcher `startup\|resume\|clear`) | `hooks/session-start.sh` | `.claude/hooks/session-start.sh` |
| **C2** Per-turn re-injection | `UserPromptSubmit` hook | `hooks/user-prompt-submit.sh` | `.claude/hooks/user-prompt-submit.sh` |
| **C3** Scoped rule activation | *Not implemented in the main agent.* Claude Code's only viable mechanism (a subdir `CLAUDE.md` shim) requires writing into someone else's git tree, which NOVA refuses to do. Delegated entirely to **S2** — the `repo-worker` subagent — whose system prompt makes "read the named repo's `AGENTS.md`" its first action. | — | — |
| S1 Pre-edit gate | *(not yet implemented)* | | |
| **S2** Focused subagent | Native Claude Code subagent (auto-delegated or invoked explicitly) | `agents/repo-worker.md` | `.claude/agents/repo-worker.md` |

## How the pointer chain works

`.claude/CLAUDE.md` is Claude Code's native entry point. Our generated copy contains three `@` imports that Claude Code expands transitively into context at session start:

```
@../AGENTS.md
@../.ai/workspace/AGENTS.md
@../.ai/workspace/map/repos.md
```

This handles Navigation Protocol steps 1–3 automatically.

Step 4 (per-repo `AGENTS.md`) is **NOT** auto-loaded in the main agent. The historical mechanism — a subdir `CLAUDE.md` shim under `git-repositories/<repo>/` — was removed because it forced every cloned repo to either gitignore the generated path or live with persistent untracked-file noise, and we don't want the adapters procedure writing inside someone else's git tree at all. Per-repo activation is handled in two ways instead:

- **`repo-worker` subagent (S2)** — fresh context, target repo named at invocation, system prompt makes "read this repo's `AGENTS.md`" its first action. Use this whenever a task is bounded to one repo.
- **Manual Navigation Protocol step 4** — when staying in the main agent for an ad-hoc task in a repo, the agent reads that repo's `AGENTS.md` explicitly via the Navigation Protocol.

## Hooks

Hook scripts are bash — macOS / Linux only. Windows users: pending.

Both hooks `cat` the shared checklist (`.ai/adapters/_shared/checklist.md`). They add no Claude-specific rule text — the checklist is the single source of truth across all platforms. If future Claude-only enforcement is needed, write a new hook script under `hooks/` and register it in `settings-snippet.json`.

Exit codes:
- `0` → stdout appended to Claude's context (success path — what we want).
- `2` → blocking error, stdout ignored, stderr shown to Claude. **Our hooks never exit 2.** Fail-open: if the checklist file is missing, the hook should still exit 0 silently.
- Other → non-blocking error, execution continues.

## Settings snippet

`settings-snippet.json` is merged (not overwritten) into `.claude/settings.local.json` during the adapters procedure. Current contents:

- `autoMemoryDirectory` — redirects auto-memory into `.claude/memory/` (per-project, not per-user). Claude Code explicitly refuses this key from shared `.claude/settings.json` to prevent a shared repo from hijacking a teammate's memory path — that's why it lives in `settings.local.json`.
- `hooks.SessionStart` and `hooks.UserPromptSubmit` — hook registrations pointing at `$CLAUDE_PROJECT_DIR/.claude/hooks/...`.

**Merge rule.** Existing top-level keys (permissions, etc.) are preserved. Inside `hooks`, entries are appended to the event's array — existing user hooks are not clobbered.

## Anti-duplication

Hooks `cat` a shared file. They do not paraphrase. If future work tempts you to inline a rule into a hook script, re-read `.ai/adapters/README.md` — the adapter is a pointer, not a copy. Same rule binds hooks.

## Subagents

### `agents/repo-worker.md`

Generic archetype for tasks scoped to one repo under `git-repositories/`. It:

- Pre-loads framework + workspace + repo-map via `@../../AGENTS.md`, `@../../.ai/workspace/AGENTS.md`, `@../../.ai/workspace/map/repos.md` (paths resolve from the runtime location `.claude/agents/repo-worker.md`).
- Runs in a fresh context window — zero rot.
- System prompt instructs it to read the target repo's own `AGENTS.md` as its first action. Since NOVA no longer ships subdir `CLAUDE.md` shims, this is the canonical C3 mechanism on Claude — there is no fallback path inside the cloned repo's tree.

**When to invoke.** When main context is getting long, when a task is bounded to one repo, or explicitly: *"Use repo-worker to <task> in <repo>"*. Claude auto-delegates based on the subagent's description; manual invocation via `/agents` also works.

### `agents/dream-worker.md`

Memory-consolidation archetype. Read-only (`tools: Read, Grep, Glob`). Reviews `.ai/workspace/learnings/`, `.ai/workspace/drift-log.md`, and per-repo `AGENTS.md` files; returns a structured Dream Report of proposals. User approves; parent applies.

**When to invoke.** User-triggered only — via `/dream` slash command, or explicit "use the dream-worker subagent". Auto-invocation is disabled on the command side so Claude doesn't proactively tidy the workspace. Full procedure at `.ai/dream/README.md`.

### Adding archetypes

Don't add `frontend-repo`, `backend-repo`, etc. speculatively — only when a concrete pattern is repeating and its maintenance cost is clearly worth it.

## Commands

### `commands/dream.md` → `/dream`

Shortcut that delegates to the `dream-worker` subagent. Uses `disable-model-invocation: true` — Claude will not invoke `/dream` on its own; only the user can trigger it. MVP is strictly user-triggered; scheduled/automatic dreaming is explicitly deferred per `.ai/dream/README.md`.

## Regeneration

Run the adapters procedure (`.ai/adapters/README.md`). It:

1. Copies `steering/CLAUDE.md` → `.claude/CLAUDE.md`.
2. Copies `hooks/*.sh` → `.claude/hooks/`, sets them executable.
3. Copies `agents/*.md` → `.claude/agents/`.
4. Merges `settings-snippet.json` into `.claude/settings.local.json` surgically.
5. Reports what changed.

Runtime outputs (the workspace-root `.claude/` only) are gitignored. Sources under `.ai/adapters/claude/` are committed. The procedure does NOT write anywhere under `git-repositories/<repo>/` — see `.ai/adapters/README.md` step 7 hard rule.
