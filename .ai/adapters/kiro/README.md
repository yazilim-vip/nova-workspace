# Kiro Adapter

Implements `.ai/enforcement.md` for [Kiro](https://kiro.dev). Generates `.kiro/` at the workspace root — gitignored, per-developer, regenerable by the adapters procedure (`.ai/adapters/README.md`).

## Capability mapping

| Capability | Mechanism | Source file | Generated output |
|------------|-----------|-------------|------------------|
| **C1** Session-start broadcast | `inclusion: always` steering + `#[[file:]]` live reference to `terminal.md` | `steering/nova.md` | `.kiro/steering/nova.md` |
| **C2** Per-turn re-injection | Hook with `promptSubmit` trigger, shell-command action | `hooks/prompt-submit.sh` + `hooks/prompt-submit.kiro.hook` | `.kiro/hooks/...` |
| **C3** Scoped rule activation | `inclusion: fileMatch` steering per registered repo | adapters/IDE procedure generator | `.kiro/steering/<repo>.md` |
| **C4** Host-environment doctrine | `#[[file:...]]` live reference from `steering/nova.md`; activation gated on the workspace's declared `Host Environments` (see `.ai/workspace/AGENTS.md` and `.ai/onboarding/README.md` step 6). One doctrine file per host. | `intellij-mcp.md` (more as hosts are added) | Pulled inline by `.kiro/steering/nova.md` |
| S1 Pre-edit gate | *(not yet implemented)* | | |
| **S2** Focused subagent | Native Kiro IDE subagent (auto-selected or invoked via `/repo-worker`) | `agents/repo-worker.md` | `.kiro/agents/repo-worker.md` |

## Platform-specific sources of truth

- `terminal.md` — Kiro terminal hang rules. Strict, non-negotiable. Referenced from `steering/nova.md` via `#[[file:...]]` live reference.
- `intellij-mcp.md` — IDEA MCP capability doctrine for Kiro CLI in IntelliJ terminal. Conditional (gated on declared host); referenced from `steering/nova.md` the same way.
- `hooks/prompt-submit.sh` — shell script that `cat`s the shared checklist (`.ai/adapters/_shared/checklist.md`).

No Kiro-specific rule text lives in steering or hooks beyond what's in these files. Both reference the shared checklist or platform-specific sources; they do not paraphrase NOVA rules.

## Steering strategy

Steering is Kiro's native auto-injection mechanism. Three inclusion modes:

- `always` — loaded into every Kiro interaction. Used for `nova.md` (workspace identity + nav protocol).
- `fileMatch` with `fileMatchPattern` — loaded only when referenced files match the glob. Used for per-repo steering generated under `.kiro/steering/<repo>.md` with pattern `git-repositories/<repo>/**`.
- `manual` — on-demand via `#steering-file-name` in chat. Not used by this adapter.

**Why shrink `nova.md`.** Long always-inject docs consume attention budget without proportional return — middle-of-context tokens decay. A short checklist paired with the per-turn hook (C2) is more resilient than a long always-inject doc alone.

## Hooks

Kiro hooks live under `.kiro/hooks/<name>.kiro.hook` (JSON). Our `prompt-submit.kiro.hook` registers the shell script. Kiro injects the script's stdout into agent context on exit 0.

The shell script is bash — macOS / Linux only. Windows users: pending.

## Anti-duplication

Steering points at `AGENTS.md` and `.ai/` paths — does not reproduce them. The `#[[file:]]` inclusion used in `nova.md` pulls Kiro's platform-specific `terminal.md` inline, but that file lives under `.ai/adapters/kiro/` by design (platform-specific source of truth). That is a reference, not a duplication.

## Subagents

### `agents/repo-worker.md`

Generic archetype for tasks scoped to one repo under `git-repositories/`. Pre-loads framework + workspace + repo-map via `#[[file:]]` live refs, then reads the target repo's own `AGENTS.md` as its first action. Fresh Kiro subagent context → zero rot.

Invoke via auto-selection, `/repo-worker`, or "use the repo-worker subagent to..." in chat.

### `agents/dream-worker.md`

Memory-consolidation archetype. Tools restricted to `read`, `grep`, `glob`. Reviews `.ai/workspace/learnings/`, `.ai/workspace/drift-log.md`, and per-repo `AGENTS.md` files; returns a structured Dream Report. User-triggered via `/dream-worker` or "use the dream-worker subagent". Full procedure at `.ai/dream/README.md`.

## Regeneration

Run the adapters procedure (`.ai/adapters/README.md`). It:

1. Copies `steering/*.md` → `.kiro/steering/`.
2. Copies `hooks/*.sh` → `.kiro/hooks/`, sets executable.
3. Copies `hooks/*.kiro.hook` → `.kiro/hooks/`.
4. Copies `agents/*.md` → `.kiro/agents/`.
5. Reports what changed.

Runtime outputs (`.kiro/`) are gitignored. Sources under `.ai/adapters/kiro/` are committed.
