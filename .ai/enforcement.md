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

Every adapter MUST implement these three.

### C1 — Session-start broadcast

On session start (or its platform equivalent), the agent's context MUST include:
- The workspace identity line ("You are operating in the NOVA workspace").
- The Navigation Protocol checklist from `AGENTS.md`.
- A pointer to any platform-specific strict rules (e.g. Kiro's `terminal.md`).

**Rationale.** Counters cold-start blind spots and ensures the rulebook is at position 0 of context while attention is strongest.

### C2 — Per-turn re-injection

On every user prompt, a short (≤5 line) checklist MUST be injected into context.

**Rationale.** Counters context rot. A one-shot injection at session start decays as the conversation grows — the middle of long contexts gets the weakest attention, so the mid-session user prompts run on a cold rulebook. Per-turn re-injection keeps the rulebook warm at the end of context where attention is strong again.

**Implementation note.** Keep the checklist short. Long re-injection consumes attention budget without proportional return; the point is to refresh attention, not to re-explain the rules.

### C3 — Scoped rule activation

When the agent operates on a file under `git-repositories/<repo>/`, that repo's `AGENTS.md` MUST become part of context without requiring agent-initiated discovery.

**Rationale.** Lazy discovery fails — an agent under context pressure will not reliably walk the `repos.md` → per-repo `AGENTS.md` chain when it matters. Scope-activated rules remove the agent from the loop.

## Capabilities — SHOULD

Adapters SHOULD implement these when the platform supports them cleanly. They raise the floor but add friction; ship them opt-in if friction is measurable.

### S1 — Pre-edit gate

Block `Edit` / `Write` actions on files under `git-repositories/<repo>/` until that repo's `AGENTS.md` has been read in the current session.

**Rationale.** Makes C3 enforceable rather than informational. Turns "should have read it" into "can't write until you've read it."

**Friction warning.** False positives block valid work. Ship as opt-in (separate settings snippet) and document the escape hatch.

### S2 — Focused subagent

Provide a subagent template that pre-loads scoped rules (workspace identity + nav protocol + repo map) into a fresh context window. Caller names the target repo at invocation; subagent's first action is to read that repo's `AGENTS.md`.

**Rationale.** Rot is a function of context length. A fresh context for a focused task sidesteps the problem entirely — the chain is pre-walked at subagent-definition time, not at agent runtime.

**Status.** Shipped as a single generic `repo-worker` archetype on both platforms. Sources: `.ai/adapters/claude/agents/repo-worker.md`, `.ai/adapters/kiro/agents/repo-worker.md`. Add more archetypes (frontend-repo, backend-repo) only when a concrete pattern repeats enough to justify maintenance.

## Adapter mapping table — template

Each adapter's README fills this in for its platform.

| Capability | Mechanism | Source file | Generated output |
|------------|-----------|-------------|------------------|
| C1. Session-start broadcast | *(platform-native session-start mechanism)* | `.ai/adapters/<platform>/...` | *(runtime path)* |
| C2. Per-turn re-injection | *(platform-native per-turn hook)* | `.ai/adapters/<platform>/hooks/...` | *(runtime path)* |
| C3. Scoped rule activation | *(platform-native scope mechanism)* | *(generator or template)* | *(runtime path)* |
| S1. Pre-edit gate | *(optional)* | | |
| S2. Focused subagent | *(optional)* | | |

## Shared assets

- `.ai/adapters/_shared/checklist.md` — the ≤5 line re-injection content. Both platforms' per-turn hooks `cat` this file. Single source of truth.
- `_shared/` is not a platform directory — the adapters procedure MUST skip it when enumerating platforms.

## Measurement

Enforcement without measurement is faith, not engineering. NOVA measures via `.ai/workspace/learnings/drift-log.md` — a per-incident log. Whenever the agent drifts (misses a rule, skips a nav step, requires "check your instructions"), append one line. Seed template: `.ai/onboarding/assets/learnings/drift-log.md`.

Use the log to:
- Spot same-rule-missed-3+-times patterns → strengthen the checklist or tighten a hook.
- After a hook change, verify drift drops within ~1 week. If not, the fix was wrong.
- Distinguish "hooks aren't firing" from "hooks fire but the content is too weak" — the `<did the hook fire?>` column.

The log is local-only (per-developer, under `.ai/workspace/`). Sharing drift patterns across a team is a fork-level decision — NOVA stays out of it.

## When this contract changes

Adding a capability: update this file, then each adapter's README and implementation. Until every adapter implements it, the new capability is aspirational — do not rely on it.

Removing a capability: rare; requires equivalent replacement. Do not silently drop.

Reference: this file is pointed at from `.ai/adapters/README.md`.
