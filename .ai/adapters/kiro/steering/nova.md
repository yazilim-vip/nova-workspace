---
inclusion: always
---

# NOVA Workspace — Read the Instructions (Do Not Duplicate)

You are operating inside a **NOVA workspace**. All identity, safety, navigation, and convention rules live in markdown files at the workspace root and under `.ai/`. **This steering file is a pointer, not a copy.** You must read the referenced files directly — do not paraphrase them from memory, do not assume their contents, do not duplicate their rules into responses, commits, or other files.

## MUST read before any action

Every new task, every new session, read these **in order**, from disk:

1. `AGENTS.md` — framework defaults: identity, safety rules, navigation protocol.
2. `.ai/workspace/AGENTS.md` — workspace-specific identity and overrides (wins on conflicts). If missing, run `.ai/onboarding/README.md`.
3. `.ai/workspace/map/repos.md` — repository map. Never guess repo paths.
4. `.ai/adapters/kiro/terminal.md` — Kiro-specific terminal rules. **These are strict and non-negotiable.** Read before running any shell command.

When entering a specific repo under `git-repositories/`, also read that repo's `AGENTS.md`.

## Anti-duplication rule (strict)

- **Do not reproduce** safety rules, navigation steps, or other NOVA content inside Kiro chat responses, generated code comments, or new files. Reference the source path (`AGENTS.md:<line>`, `.ai/adapters/kiro/terminal.md:<line>`) instead.
- **Do not create new steering files** under `.kiro/steering/` unless you're extending an explicitly platform-specific concern that has no home in `.ai/`. If a rule belongs to NOVA, it goes in `.ai/` — and this steering file points at it.
- **If you feel the urge to copy a rule here for "reliability,"** that's a smell. The fix is to re-read the source file, not to duplicate it.

## Load order summary

`AGENTS.md` → `.ai/workspace/AGENTS.md` → `.ai/workspace/map/repos.md` → `.ai/adapters/kiro/terminal.md` → per-repo `AGENTS.md` on entry → skills / learnings on demand.

Read on task entry. Do not preload everything. Do not guess. Do not duplicate.
