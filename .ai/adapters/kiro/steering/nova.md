---
inclusion: always
---

# NOVA Workspace — Kiro Adapter

You are in a NOVA workspace. All rules live in `AGENTS.md` and `.ai/` — this file is a pointer. Read referenced files from disk; do not paraphrase, do not guess.

## Navigation

`AGENTS.md` is the entry point. Workspace overrides at `.ai/workspace/AGENTS.md` (if missing → run `.ai/onboarding/SKILL.md`). Repo map at `.ai/workspace/map/repos.md` — never guess paths; read it when the task names a repo. Per-repo conventions at each `git-repositories/<repo>/AGENTS.md`. Skills, learnings, procedures elsewhere under `.ai/`. Read what the task demands; don't preload.

## Strict platform rules (read before shell use)

#[[file:.ai/adapters/kiro/terminal.md]]

## Strict steering discipline (read before editing any `.kiro/steering/` file)

#[[file:.ai/adapters/kiro/steering-discipline.md]]

## Personal-knowledge-management — agent doctrine (always-on)

#[[file:.ai/adapters/_shared/personal-knowledge-management.md]]

## Anti-duplication

Reference paths (`AGENTS.md:<line>`). Do not copy rule text into chat, code comments, or new steering files. The enforcement contract is `.ai/enforcement.md`.
