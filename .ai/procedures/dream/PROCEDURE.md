---
name: dream
description: Reviews accumulated workspace memory (learnings, drift-log, per-repo AGENTS.md files) and proposes consolidations — dedupes, promotes patterns to higher tiers, archives stale entries. Read-only; user approves before any apply. Use for periodic memory tidying when the workspace feels cluttered or learnings are piling up.
---

# Dream

Framework procedure — periodic memory consolidation. Reviews accumulated learnings/drift/AGENTS.md and returns a structured Dream Report. Read-only; user approves before any apply.

## Why this exists

NOVA accumulates knowledge in growable files — `.ai/workspace/learnings/`, `.ai/workspace/drift-log.md`, per-repo `AGENTS.md` bodies. Without periodic consolidation they become write-only junk drawers: duplicates pile up, rules that outgrew their scope stay put, stale entries keep consuming attention budget at load time.

Dreaming is the consolidation pass. Inspired by sleep-time compute research ([Letta, 2025](https://www.letta.com/blog/sleep-time-compute)) and Claude Code's in-development Auto-Dream feature — agents use idle time to review accumulated memory and reorganize it. NOVA's take: user-triggered, propose-don't-commit, transparent diffs.

## Core principle — **STRICT**

**Propose. Never commit. Never delete.** Every output from a dream pass is a proposal the user explicitly approves. Silent rewrites of rules are worse than silent duplication of rules — they break trust in the framework. Approval is per-proposal, not bulk.

Archival is how "deletion" happens: move the superseded content to `.ai/workspace/learnings/_archive/<YYYY-MM-DD>.md`, never `rm`. If the dream pass was wrong, the user can restore.

## What dreaming reviews

Five categories. The dream-worker enumerates what falls into each. Missing categories are allowed — not every pass yields proposals.

### 1. Dedupe learnings

Two or more entries under `.ai/workspace/learnings/` that describe the same rule, pattern, or preference. Propose a merge: keep the strongest phrasing, fold in any extra detail, reference the unified entry.

### 2. Promote patterns

A learning appears ≥3 times across sessions, or a drift-log entry repeats ≥3 times. That's a signal the knowledge belongs one tier up:
- Repeat learnings in a single repo → propose moving to that repo's `AGENTS.md`.
- Repeat across repos → propose moving to `.ai/workspace/AGENTS.md`.
- Repeat drift patterns → propose tightening a hook, strengthening a steering rule, or adding a new enforcement row to `.ai/enforcement.md`.

### 3. Demote stale knowledge

Learnings or rules that reference:
- Archived repos (check against `.ai/workspace/map/repos.md`).
- Removed tools, deprecated dependencies, retired processes.
- Dates >180 days past that describe a one-time event.

Propose moving to `_archive/` with a note on why.

### 4. Compact drift-log

Drift-log entries older than 30 days. Propose a monthly summary block (patterns + counts), then archive the raw entries. This keeps the active log focused on recent signals without losing historical pattern data.

### 5. Audit framework drift

Files that haven't changed in ≥90 days:
- Per-repo `AGENTS.md` — still accurate? Flag for review (don't propose edits; the repo owner decides).
- `.ai/enforcement.md` — any SHOULD capability that stayed aspirational long enough to drop?
- `.ai/procedures/adapters/<platform>/` — any rule that's platform-specific but applies to all platforms now?

Dream-worker does NOT guess at edits here — it flags for human review only.

## Invocation

- **Claude Code**: `/dream` (slash command) or explicitly "use the dream-worker subagent to run a dream pass."
- **Kiro**: `/dream-worker` or "use the dream-worker subagent..."
- **Direct**: ask the main agent to run the procedure — same result, more context-heavy than delegating.

All three paths produce the same Dream Report; the subagent route keeps the consolidation work out of the main conversation.

## Dream report format

Dream-worker returns a structured markdown report. No edits to any file — only proposals.

```
# Dream Report — <YYYY-MM-DD>

## Scanned
- <path> (N entries, size)
- ...

## Proposals

### [DEDUPE-1] <short title>
- Files: <paths + line refs>
- Signal: <what was noticed>
- Proposed action: <exact change — paths + edit description>

### [PROMOTE-1] ...

### [DEMOTE-1] ...

### [COMPACT-1] ...

### [AUDIT-1] ...

## Nothing to do
- <category>: <why no proposal>

## Summary
N proposals (breakdown by category). No changes applied. Approve by number.
```

Each proposal is self-contained — file paths, line numbers, and the exact change. The user reads the report, tells the parent agent which proposals to apply (e.g. *"apply DEDUPE-1 and PROMOTE-2, skip the rest"*), and the parent agent does the edits with normal tool calls.

## Approval flow

1. User invokes `/dream`.
2. Dream-worker runs in fresh context, returns Dream Report.
3. User reviews proposals, approves individually.
4. Parent agent applies approved proposals — same way it applies any other edit, with diffs visible and permissions respected.
5. (Optional) User commits the resulting changes.

No auto-apply. No bulk approval. No silent archival.

## What this procedure does NOT do

- **Auto-memory rewriting.** Dream-worker has read-only tools by design. It cannot write, edit, or delete.
- **Scheduled dreaming.** MVP is user-triggered only. Cadence tuning (weekly, session-end, etc.) waits for evidence that dreaming produces useful output often enough to warrant automation.
- **Memory tiers (Core/Recall/Archival).** NOVA already has working tiers — rules files, learnings, repo AGENTS.md. Adding another layer is a refactor, not a feature.
- **Cross-workspace dreaming.** Pass scope is this workspace only.

## When to dream

- "Learnings folder is getting messy."
- "Drift log has a bunch of old entries."
- "Workspace feels stale."
- Periodic (~monthly) by user habit.

Not a replacement for reading the files yourself — it's the first pass that surfaces what's worth your attention.

## References

- `.ai/procedures/adapters/claude/agents/dream-worker.md` — Claude subagent implementation.
- `.ai/procedures/adapters/kiro/agents/dream-worker.md` — Kiro subagent implementation.
- `.ai/procedures/adapters/claude/commands/dream.md` — `/dream` slash command wiring.
- `.ai/enforcement.md` — capability contract; dream pass proposes additions when patterns emerge.
- `.ai/workspace/learnings/drift-log.md` — measurement log; dream pass reads and proposes compactions.
