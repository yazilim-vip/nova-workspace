# Kiro Adapter

Implements `.ai/enforcement.md` for [Kiro](https://kiro.dev). Generates `.kiro/` at the workspace root — gitignored, per-developer, regenerable by the adapters procedure (`.ai/adapters/SKILL.md`).

## Capability mapping

| Capability | Mechanism | Source file | Generated output |
|------------|-----------|-------------|------------------|
| **C1** Session-start broadcast | `inclusion: always` steering + `#[[file:]]` live reference to `terminal.md` | `steering/nova.md` | `.kiro/steering/nova.md` |
| **C2** Per-turn re-injection | Hook with `promptSubmit` trigger, shell-command action | `hooks/prompt-submit.sh` + `hooks/prompt-submit.kiro.hook` | `.kiro/hooks/...` |
| **C3** Scoped rule activation | `inclusion: fileMatch` steering per registered repo | adapters/IDE procedure generator | `.kiro/steering/<repo>.md` |
| **C5** PKM agent doctrine | `#[[file:...]]` live reference from `steering/nova.md`; always-on. Captures trigger recognition for capture verbs ("capture to inbox", "log to daily", etc.), required first read of the contract on any PKM trigger, viewer-detection (`notes/.obsidian/`) for the every-note-is-a-folder-note override, path discipline, safety guards (vault is gitignored, never proactive). Always-on because triggers fire from cold sessions before any vault declaration exists. | `.ai/adapters/_shared/personal-knowledge-management.md` (shared with Claude) | Pulled inline by `.kiro/steering/nova.md` |
| **Skills** | User skills only — Kiro's native `skill://` URI in agent `resources` points at `.ai/workspace/skills/<skill>/SKILL.md` (gitignored, machine-local). Framework `nova-*` skills stay at `.ai/<name>/SKILL.md` and load via the AGENTS.md "Framework Skills" table reference. The adapter does not write framework skills into the Kiro skills surface. | User-authored under `.ai/workspace/skills/` | Referenced from `agents/*.json` `resources` via `skill://` |
| **S1** Pre-edit gate (opt-in) | `preToolUse` hook matching `fs_write` returns `exit 2` to block writes under `git-repositories/<repo>/` until that repo's `AGENTS.md` is read this session. Companion `postToolUse` tracker drops a session marker on AGENTS.md reads. | `hooks/pre-edit-gate.sh` + `pre-edit-gate.kiro.hook` + `pre-edit-gate-tracker.sh` + `pre-edit-gate-tracker.kiro.hook` | `.kiro/hooks/...` (opt-in copy) |
| **S2** Focused subagent | Native Kiro IDE subagent. JSON config (`agents/<name>.json`) restricts tools, pre-loads scoped resources, and sets per-agent UX. Markdown body (`agents/<name>.md`) holds the system prompt; the JSON points at it via `systemPromptFile`. | `agents/repo-worker.{json,md}`, `agents/dream-worker.{json,md}` | `.kiro/agents/...` |

## Platform-specific sources of truth

- `terminal.md` — Kiro terminal hang rules. Strict, non-negotiable. Referenced from `steering/nova.md` via `#[[file:...]]` live reference.
- `steering-discipline.md` — Strict rules preventing Kiro steering files from growing fat: no inlining of `.ai/` content, no preloading learnings, no casual `inclusion: always` additions, no hand-edits of regenerated steering. Referenced from `steering/nova.md` so it's always-on.
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

## Skills

Kiro loads skills via `skill://` URIs declared in agent `resources`. The adapter handles user skills only:

- **User skills** — adapter's chosen default location is `.ai/workspace/skills/<skill>/SKILL.md` (agentskills.io format, gitignored, machine-local). Both `repo-worker.json` and `dream-worker.json` pre-load `skill://.ai/workspace/skills/**/SKILL.md`.
- **Framework skills (`nova-*`)** — stay at `.ai/<name>/SKILL.md`. They load via the AGENTS.md "Framework Skills" table — that table is auto-injected as steering context every session, so the agent reasons against each skill's `description` to route. No `skill://` URI, no runtime copy.

Why no copy: regenerable adapter writes into a user-skill directory create a clobber risk and blur ownership. Framework skills stay framework-owned at their source path; user skills stay user-owned at theirs.

If you keep user skills somewhere other than `.ai/workspace/skills/`, update the `skill://` glob in the agent JSON configs accordingly.

## Subagents

Each subagent ships as a **paired** `.json` config + `.md` system prompt. The JSON enforces capabilities the markdown frontmatter cannot — tool restriction, path-scoped `fs_write`, pre-loaded resources via `file://` and `skill://` URIs, welcome message. The markdown holds the prompt body and is referenced from the JSON via `systemPromptFile`.

Reference: [Kiro agent config schema](https://kiro.dev/docs/agents) — `tools`, `toolsSettings`, `resources` (with `skill://` for progressive loading), `welcomeMessage`, `keyboardShortcut`, `mcpServers`.

### `agents/repo-worker.{json,md}`

Generic archetype for tasks scoped to one repo under `git-repositories/`. Pre-loads framework + workspace + repo-map + Kiro terminal rules via `file://` resources, plus all workspace skills via `skill://` (progressive). `fs_write` is path-scoped to `git-repositories/**` and `scripts/**` — cannot accidentally write workspace-level files. Reads the target repo's own `AGENTS.md` as its first action. Fresh context → zero rot.

Invoke via auto-selection, `/repo-worker`, or "use the repo-worker subagent to..." in chat.

### `agents/dream-worker.{json,md}`

Memory-consolidation archetype. Tools enforced to `read`, `grep`, `glob` via JSON config — no shell, no edit, no write. Pre-loads framework + workspace + repo map + dream procedure + skills. Reviews `.ai/workspace/learnings/`, `.ai/workspace/drift-log.md`, and per-repo `AGENTS.md` files; returns a structured Dream Report. User-triggered via `/dream-worker` or "use the dream-worker subagent". Full procedure at `.ai/dream/SKILL.md`.

### Adding new agent files

New subagents authored after the adapters procedure last ran will be missing from `.kiro/agents/` until the procedure is re-run. The README's "Regeneration" section names this — surface it to the user when shipping a new archetype.

## Regeneration

Run the adapters procedure (`.ai/adapters/SKILL.md`). It:

1. Copies `steering/*.md` → `.kiro/steering/`.
2. Copies `hooks/*.sh` → `.kiro/hooks/`, sets executable. **Skips opt-in scripts** (`pre-edit-gate*.sh`, `agent-spawn.sh`) unless the user requested them.
3. Copies default `hooks/*.kiro.hook` → `.kiro/hooks/`. **Skips opt-in hook configs** by the same rule (`pre-edit-gate*.kiro.hook`, `agent-spawn.kiro.hook`).
4. Copies `agents/*.md` AND `agents/*.json` → `.kiro/agents/`. The JSON config takes precedence over markdown frontmatter where both exist.
5. Renders per-repo steering from `templates/repo-steering.md` for each registered, cloned repo (C3).
6. Reports what changed.

Opt-in artifacts (S1 pre-edit gate, agentSpawn checklist) ship as separate file pairs. Install them by copying the matching `.sh` + `.kiro.hook` pair into `.kiro/hooks/` only when the friction trade-off is worth it (drift log shows the failure mode the hook prevents).

New agent files (`agents/<name>.{json,md}`) added after the procedure last ran require a re-run to appear under `.kiro/agents/`.

Runtime outputs (`.kiro/`) are gitignored. Sources under `.ai/adapters/kiro/` are committed.
