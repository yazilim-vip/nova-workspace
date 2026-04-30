---
name: drift
description: Append a drift incident to .ai/workspace/learnings/drift-log.md. Wraps the workspace `drift` skill — Claude-specific shortcut for it. Usage — /drift <freeform description of what went wrong>
disable-model-invocation: true
---

Invoke the `drift` skill with the user-supplied content as input. The full procedure lives at `.ai/workspace/skills/drift/SKILL.md` (mirrored to `.claude/skills/drift/SKILL.md` by the C4 hook) — read schema from `.ai/workspace/learnings/drift-log.md`, parse freeform input into the structured fields, append one line under `## Entries`, confirm by quoting back.

User-supplied content: $ARGUMENTS

If `$ARGUMENTS` is empty, the skill prompts briefly for the task context + what was missed before appending. Don't append a blank entry.

This command is a thin wrapper so users can type `/drift <stuff>` instead of "use the drift skill on: <stuff>". The skill is the single source of truth — same procedure runs on Kiro via the `skill://` mechanism.
