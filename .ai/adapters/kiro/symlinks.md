# Kiro — Symlinks Rule (Strict, Non-Negotiable)

Referenced from `.kiro/steering/nova.md`. Kiro does not resolve symlinked files for skills, configs, steering, or any adapter-managed path. This rule exists because the user has hit this repeatedly. Obey it — do not paraphrase, do not shortcut.

## Rule

**Never propose symlinks as a NOVA wiring mechanism.**

This applies to:
- Skill mirroring (e.g. linking `.claude/skills/` → `.ai/workspace/skills/`).
- Steering / config / adapter wiring under `.kiro/`, `.claude/`, or any host folder.
- Any cross-platform mechanism that *might* later be reused by the Kiro adapter.

If the same mechanism could plausibly run under Kiro, treat symlinks as off the table from the start — even for a Claude-only proposal — to keep the design portable.

## Use one of these instead

1. **Real file copies** refreshed by a session-start / pre-turn hook (current C4 mirror approach).
2. **URI-based references** (Kiro's existing `skill://` pattern — canonical-path, no copy).
3. **Loader / agent indirection** that reads from the canonical `.ai/workspace/...` path on demand (e.g. a `skill-runner` meta-agent).

## Why

Kiro's file resolver does not follow symlinks for managed paths. A symlinked skill or config file appears missing to Kiro's loader. The user has corrected this rule multiple times; recommending symlinks again is a repeat miss.
