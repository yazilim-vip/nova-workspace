# Enforcement Contract

Platform-agnostic contract that every NOVA adapter must satisfy. Names **what** to enforce; each adapter picks its platform-native mechanism for **how**.

## Why this file exists

NOVA's rules live in prose — `AGENTS.md`, `.ai/workspace/`, per-repo `AGENTS.md`. Prose is probabilistic: agents can ignore it, drift from it, and attention to it decays in long conversations. Research and field experience both show the pattern:

- Context rot is real — models attend strongly to the start and end of context, weakly to the middle. Instructions at the top of a long session lose weight ([Chroma, 2025](https://research.trychroma.com/context-rot)).
- LLM compliance with instructions is probabilistic, not deterministic — prose must be paired with deterministic harness constraints for reliable behavior ([Anthropic context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)).
- Hooks and auto-injection convert prose suggestions into guaranteed actions. That's the job of an adapter.

This contract is the single source of truth for the enforcement layer. Each adapter's README maps these capabilities to its native mechanism.

## Anti-duplication still applies

Adapters are pointers — not copies. Hooks and auto-injected steering MUST reference files under `AGENTS.md` or `.ai/`. They MUST NOT inline rule text. If an adapter ends up with a hook that paraphrases a safety rule, that's a duplication violation — fix the hook, do not keep the duplication.

## Capabilities — MUST

Every adapter MUST implement these.

### C1 — Session-start broadcast

On session start (or its platform equivalent), the agent's context MUST include:
- The workspace identity line ("You are operating in the NOVA workspace").
- The framework rulebook (`AGENTS.md` and `.ai/workspace/AGENTS.md` content).
- A pointer to any platform-specific strict rules (e.g. Kiro's `terminal.md`).

**Rationale.** Counters cold-start blind spots and ensures the rulebook is at position 0 of context while attention is strongest. Implemented via the host's native always-on mechanism — Claude `@` imports in `.claude/CLAUDE.md`, Kiro `inclusion: always` steering in `.kiro/steering/nova.md`. No hook-level broadcast is required (and was removed on 2026-04-30 — see § Removed capabilities).

### C3 — Scoped rule activation

When the agent operates on a file under `git-repositories/<repo>/`, that repo's `AGENTS.md` MUST become part of context without requiring agent-initiated discovery.

**Rationale.** Lazy discovery fails — an agent under context pressure will not reliably walk the `repos.md` → per-repo `AGENTS.md` chain when it matters. Scope-activated rules remove the agent from the loop.

### C4 — User-skill surfacing

Workspace user skills authored under `.ai/workspace/skills/<name>/SKILL.md` MUST be discoverable to the platform's native skill loader at trigger time, without requiring the agent to walk `.ai/workspace/skills/` itself. Each adapter picks its mechanism — direct URI reference, mirror script, or whatever the platform supports natively.

**Rationale.** The Navigation Protocol's "load skills on trigger" step is probabilistic — under context pressure, the agent will not reliably reason against an `AGENTS.md` skills table to choose a skill. Native skill loaders surface skills via the host's own attention mechanism (e.g. tool registration, descriptions in the system prompt) and fire reliably. If a skill isn't in the native registry, it effectively doesn't exist at trigger time. Field-observed failure mode: users repeatedly nudging the agent ("check the X skill", "why didn't you use Y") because authored skills never reached the loader.

**Implementation note.** Mirror destinations are owned by the NOVA adapter — hand-authored platform-specific skills must live in the platform's user-scoped location (e.g. `~/.claude/skills/` for Claude Code), not in the workspace-local mirror destination, to avoid clobber on regeneration. The shared mirror script lives at `.ai/procedures/adapters/_shared/sync-skills.sh` and is called from each adapter's session-start hook (and optionally per-turn hook for mid-session edit pickup).

## Capabilities — SHOULD

Adapters SHOULD implement these when the platform supports them cleanly. They raise the floor but add friction; ship them opt-in if friction is measurable.

### S1 — Pre-edit gate

Block `Edit` / `Write` actions on files under `git-repositories/<repo>/` until that repo's `AGENTS.md` has been read in the current session.

**Rationale.** Makes C3 enforceable rather than informational. Turns "should have read it" into "can't write until you've read it."

**Friction warning.** False positives block valid work. Ship behavior depends on session-id reliability:
- **Claude:** ship default-ON. `CLAUDE_SESSION_ID` is reliable, the companion `PostToolUse` tracker auto-clears on AGENTS.md reads, and disabling is one block-removal in `settings.local.json`.
- **Kiro:** ship opt-in. `KIRO_SESSION_ID` may be missing in some flows, falling back to date-bucketed ids that misfire across day boundaries.

Both implementations document escape hatches (read AGENTS.md to auto-clear, manual marker `touch`, or disable the hook). The status across adapters: **Claude — default-ON. Kiro — opt-in.**

### S2 — Focused subagent

Provide a subagent template that pre-loads scoped rules (workspace identity + nav protocol + repo map) into a fresh context window. Caller names the target repo at invocation; subagent's first action is to read that repo's `AGENTS.md`.

**Rationale.** Rot is a function of context length. A fresh context for a focused task sidesteps the problem entirely — the chain is pre-walked at subagent-definition time, not at agent runtime.

**Status.** Shipped as a single generic `repo-worker` archetype on both platforms. Sources: `.ai/procedures/adapters/claude/agents/repo-worker.md`, `.ai/procedures/adapters/kiro/agents/repo-worker.md`. Add more archetypes (frontend-repo, backend-repo) only when a concrete pattern repeats enough to justify maintenance.

## Adapter mapping table — template

Each adapter's README fills this in for its platform.

| Capability | Mechanism | Source file | Generated output |
|------------|-----------|-------------|------------------|
| C1. Session-start broadcast | *(platform-native always-on / session-start mechanism)* | `.ai/procedures/adapters/<platform>/...` | *(runtime path)* |
| C3. Scoped rule activation | *(platform-native scope mechanism)* | *(generator or template)* | *(runtime path)* |
| C4. User-skill surfacing | *(platform-native skill loader bridge)* | *(hook or URI reference)* | *(runtime path)* |
| S1. Pre-edit gate | *(optional)* | | |
| S2. Focused subagent | *(optional)* | | |

## Removed capabilities

### C2 — Per-turn re-injection (removed 2026-04-30)

Was: "On every user prompt, a short checklist MUST be injected into context." Implemented via per-turn hooks that `cat` a shared `.ai/procedures/adapters/_shared/checklist.md` and emit task-pointer matches.

Removed because empirical use showed the per-turn injection added cognitive load and felt like nagging without measurably reducing drift. The rules loaded by C1 at session start were sufficient. Both the checklist and task-pointer source files were deleted; per-turn hooks were either removed (Kiro) or stripped to C4-only mid-session refresh (Claude).

If you want this back: restore `.ai/procedures/adapters/_shared/checklist.md` with terse content, restore the hook-level `cat` of that file in each adapter's per-turn hook, and re-add the C2 capability to this contract.

## Shared assets

- `_shared/` holds cross-adapter content (e.g. `personal-knowledge-management.md`). The adapters procedure MUST skip it when enumerating platforms.

## No committed shell scripts under `.ai/`

Hook sources live as markdown (`<name>.md`) under `.ai/procedures/adapters/<platform>/hooks/` — each containing a single fenced ` ```bash ``` ` code block plus prose explaining purpose, runtime path, and mode. The adapters procedure extracts the bash and writes the runtime `.sh` (gitignored, machine-local). Rationale: keeps the framework documentation-shaped — every committed file is human-reviewable prose; runtime executables are generated artifacts that don't pollute review or grep with build noise. C4 sync logic is inlined per-platform into the relevant hook source rather than living as a separate shared script — duplication is bounded (one platform, two hooks) and outweighs the cost of a build-time include mechanism.

## Measurement

Enforcement without measurement is faith, not engineering. NOVA measures via `.ai/workspace/learnings/drift-log.md` — a per-incident log. Whenever the agent drifts (misses a rule, skips a nav step, requires "check your instructions"), append one line. Seed template: `.ai/procedures/onboarding/assets/learnings/drift-log.md`.

Use the log to:
- Spot same-rule-missed-3+-times patterns → strengthen the checklist or tighten a hook.
- After a hook change, verify drift drops within ~1 week. If not, the fix was wrong.
- Distinguish "hooks aren't firing" from "hooks fire but the content is too weak" — the `<did the hook fire?>` column.

The log is local-only (per-developer, under `.ai/workspace/`). Sharing drift patterns across a team is a fork-level decision — NOVA stays out of it.

## When this contract changes

Adding a capability: update this file, then each adapter's README and implementation. Until every adapter implements it, the new capability is aspirational — do not rely on it.

Removing a capability: rare; requires equivalent replacement. Do not silently drop.

Reference: this file is pointed at from `.ai/procedures/adapters/PROCEDURE.md`.
