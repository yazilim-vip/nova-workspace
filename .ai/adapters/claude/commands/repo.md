---
name: repo
description: Run a focused task in a single repo via the repo-worker subagent. Pre-walks the navigation chain (workspace AGENTS.md → repos.md → repo's own AGENTS.md) in fresh context, sidestepping main-context rot. Usage — /repo <repo-name> <task description>
disable-model-invocation: true
---

Spawn the `repo-worker` subagent on a task scoped to one repo. The subagent runs in a fresh context window with framework + workspace + repo-map pre-loaded; its first action is to read the target repo's own `AGENTS.md`.

User-supplied content: $ARGUMENTS

Steps:

1. **Parse** `$ARGUMENTS`:
   - First whitespace-separated token = `<repo-name>`.
   - Remainder = `<task>`.
   If `$ARGUMENTS` is empty or has only one token, tell me the usage and stop.
2. **Resolve** `<repo-name>` against `.ai/workspace/map/repos.md`. If not found there, also check `.ai/workspace/map/repos-extended.md` (workshops / education / playground / archived). If still no match, list the closest candidates from both files and stop — don't guess.
3. **Invoke** the Agent tool with `subagent_type: "repo-worker"` and a self-contained prompt:
   ```
   Work on this task in the <repo-name> repo:
   <task>

   Resolved path: git-repositories/<resolved-relative-path>

   First action: read <resolved-path>/AGENTS.md before doing anything else.
   ```
   Do not delegate "decide what to do" to the subagent — the task description must be concrete. If `<task>` is too vague, ask me to sharpen it before spawning.
4. **Surface** the subagent's result to me verbatim. If the subagent reports a blocker (missing AGENTS.md, ambiguous path, etc.), don't paper over it — tell me.

Use this slash command whenever main context is getting long, the task is clearly bounded to one repo, and you want a fresh-context worker for the actual work. For cross-repo tasks or anything that needs the main session's history, stay in main and read the per-repo AGENTS.md manually.
