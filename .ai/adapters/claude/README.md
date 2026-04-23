# Claude Code Adapter

Implements `.ai/enforcement.md` for [Claude Code](https://code.claude.com). Generates `.claude/` at the workspace root — gitignored, per-developer, regenerable by the adapters procedure (`.ai/adapters/README.md`).

## Capability mapping

| Capability | Mechanism | Source file | Generated output |
|------------|-----------|-------------|------------------|
| **C1** Session-start broadcast | `SessionStart` hook (matcher `startup\|resume\|clear`) | `hooks/session-start.sh` | `.claude/hooks/session-start.sh` |
| **C2** Per-turn re-injection | `UserPromptSubmit` hook | `hooks/user-prompt-submit.sh` | `.claude/hooks/user-prompt-submit.sh` |
| **C3** Scoped rule activation | Subdir `CLAUDE.md` shim in each `git-repositories/<repo>/` (parent-dir walk + subdir discovery) | adapters/IDE procedure generator | `git-repositories/<repo>/.claude/CLAUDE.md` |
| S1 Pre-edit gate | *(not yet implemented)* | | |
| S2 Focused subagent | *(not yet implemented)* | | |

## How the pointer chain works

`.claude/CLAUDE.md` is Claude Code's native entry point. Our generated copy contains three `@` imports that Claude Code expands transitively into context at session start:

```
@../AGENTS.md
@../.ai/workspace/AGENTS.md
@../.ai/workspace/map/repos.md
```

This handles Navigation Protocol steps 1–3 automatically. Step 4 (per-repo `AGENTS.md`) is handled by the subdir `CLAUDE.md` shim — when the user edits a file under `git-repositories/<repo>/`, Claude Code walks parent dirs and discovers the shim, which `@`-imports that repo's `AGENTS.md`.

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

## Regeneration

Run the adapters procedure (`.ai/adapters/README.md`). It:

1. Copies `steering/CLAUDE.md` → `.claude/CLAUDE.md`.
2. Copies `hooks/*.sh` → `.claude/hooks/`, sets them executable.
3. Merges `settings-snippet.json` into `.claude/settings.local.json` surgically.
4. Reports what changed.

Runtime outputs (`.claude/`, subdir shims) are gitignored. Sources under `.ai/adapters/claude/` are committed.
