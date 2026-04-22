---
inclusion: always
---

# NOVA Workspace — Navigation

You are operating inside a **NOVA workspace**. NOVA is a framework for multi-repo engineering work; its instructions, conventions, and safety rules live in markdown files at the workspace root and under `.ai/`.

Kiro does not auto-read these files, so this steering entry redirects you to them.

## Read these, in order

1. **`AGENTS.md`** at the workspace root — framework defaults: identity, safety, navigation protocol.
2. **`.ai/workspace/AGENTS.md`** — workspace-specific identity and overrides. Wins on conflicts with the root file. If absent, the workspace is unclaimed — run the onboarding procedure at `.ai/onboarding/README.md`.
3. **`.ai/workspace/map/repos.md`** — repository map. Use this to locate repos; never guess paths.
4. **Per-repo `AGENTS.md`** — when you enter a specific repo under `git-repositories/`, read its own `AGENTS.md` before making changes.

## Navigation Protocol

Work like a strategy game — start with fog of war, reveal context as you go. Don't preload everything.

- **Onboarding gate:** If `.ai/workspace/.initialized` does not exist, or the user asks to "set up this workspace" / "onboard me", load `.ai/onboarding/README.md` and run the onboarding flow before anything else.
- **Find the target** — `.ai/workspace/map/repos.md` to locate the repo.
- **Enter the project** — read the repo's `AGENTS.md`.
- **Go deeper** — if working in a subfolder, check for a nested `AGENTS.md` and `.ai/` directory.
- **Load skills on demand** — `.ai/workspace/skills/<skill>/SKILL.md` only when the task triggers them.
- **Check learnings** — scan `.ai/workspace/learnings/` for relevant accumulated knowledge.

## Communication

- Be concise — lead with the action, not the reasoning.
- Include file paths and line numbers when referencing code.
- Flag uncertainties — say what you don't know.
- Communicate in English unless asked otherwise.
