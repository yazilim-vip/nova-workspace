# Drift Log

Per-incident log. Whenever you notice the agent ignore the navigation protocol, miss a per-repo rule, forget the workspace identity, or otherwise require "check your instructions" — append one line here.

This is the measurement side of `.ai/enforcement.md`. Without it there's no signal for whether hook-based re-injection is actually reducing drift.

## Schema

```
YYYY-MM-DD | <platform> | <task context> | <what was missed> | <did the hook fire?>
```

- `<platform>`: claude, kiro, or other.
- `<task context>`: one short phrase — the kind of work you were doing.
- `<what was missed>`: the specific rule, file, or step the agent skipped.
- `<did the hook fire?>`: yes / no / unknown. Useful to tell "hooks aren't working" from "hooks are firing but the checklist isn't strong enough".

## Entries

<!-- Append one line per incident below. Keep it terse; analyze in batches monthly. -->

## How to use this

- **Weekly scan** — run `tail -20 .ai/workspace/learnings/drift-log.md` to see recent pain.
- **Monthly review** — look for patterns. Same rule missed 3+ times → strengthen the checklist, tighten a hook, or promote the rule to an auto-injected file.
- **After a hook change** — drift rate should drop. If it doesn't in ~1 week, the fix didn't work; revert or iterate.

## When to stop logging

Never. The point is to keep the enforcement layer honest against a moving target (new repos, new rules, new platforms). A log that stops updating is a sign the developer stopped caring about drift — not that drift stopped happening.
