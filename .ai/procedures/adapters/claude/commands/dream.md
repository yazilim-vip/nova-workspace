---
name: dream
description: Run a NOVA dream pass — review accumulated workspace memory and propose consolidations. Delegates to the dream-worker subagent; returns a structured Dream Report for the user to approve.
disable-model-invocation: true
---

Run a NOVA dream pass per `.ai/procedures/dream/PROCEDURE.md`.

Delegate to the `dream-worker` subagent. The subagent runs read-only in a fresh context, reviews `.ai/workspace/learnings/`, `.ai/workspace/drift-log.md`, and per-repo `AGENTS.md` files, and returns a structured Dream Report of proposed consolidations.

Do not apply any proposals automatically. Present the report to me verbatim; I will approve by number. Once I approve specific proposals, apply them with normal tool calls — one edit per approved proposal, visible diffs.

If the dream-worker finds nothing worth proposing, tell me so plainly. An empty report is a valid outcome — it means the workspace is clean.
