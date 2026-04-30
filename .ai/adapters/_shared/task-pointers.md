# Task-relevant pointers

Per-turn hooks (Claude `user-prompt-submit`, Kiro `prompt-submit`) parse the lines between `<!-- begin-pointers -->` and `<!-- end-pointers -->`. Each line: `<extended-regex> => <pointer text>`.

The separator is the literal three-character string ` => ` (space-arrow-space). Parser splits at the **first** occurrence; everything before is the pattern, everything after is the pointer. This lets patterns contain pipe alternation (`a|b|c`) without conflicting with the splitter.

The pattern is matched case-insensitively against the user's prompt (raw stdin envelope, no JSON parsing — keywords are workspace-specific so false positives from JSON metadata are negligible). When a pattern matches, the pointer is emitted as a "Consider:" line in the per-turn re-injection. This is a **just-in-time retrieval** layer — turns the static checklist into task-relevant context.

## Authoring rules

- **Pattern format.** POSIX extended regex. Avoid `\b` (not portable across BSD/GNU `grep`). For boundary-sensitive short keywords use `(^|[^a-zA-Z])(kw)([^a-zA-Z]|$)` instead.
- **Separator.** Exactly ` => ` (space-arrow-space). Patterns and pointers must not contain that exact 4-char substring; if you need to match `=>` inside a regex, separate the words: `=[ ]*>`.
- **Pointer text.** Free prose. Convention: `` `<path>` (one-line description) ``.
- **Update when:** a new workspace skill is added, a new repo enters `repos.md` and you find yourself naming it often, or the drift log shows the agent missing a specific skill despite the keyword being present in the prompt.
- **Don't over-add.** Every pointer adds tokens to every turn it fires. Aim for high-precision triggers — a keyword that fires only when the relevant skill is genuinely useful.

## Patterns

<!-- begin-pointers -->
<!-- Patterns intentionally empty. The "Consider:" lines emitted by per-turn pointer matching were felt as nagging ("read this skill, why didn't you use that skill") and added per-turn token noise. Skills with strong descriptions auto-route in Claude Code without needing pointer hints; if the skill description is the bug, fix it once at the source. Cut on 2026-04-30 alongside the checklist silence. To re-enable just-in-time hints, add lines back here using the schema in the file header. -->
<!-- end-pointers -->
