# Hook: pre-edit-gate (Claude)

**Purpose.** Implements **S1** (pre-edit gate) for Claude Code. Blocks `Edit` / `Write` / `MultiEdit` on files under `git-repositories/<repo>/` until that repo's `AGENTS.md` has been read at least once in the current session. Converts Navigation Protocol step 4 from "should have read it" into "can't write until you have."

**Mechanism.** Claude Code's `PreToolUse` hook receives a JSON envelope on stdin including `tool_name` and `tool_input.file_path`. Exit 2 blocks the tool call; STDERR is returned to the LLM as the rejection reason. Exit 0 allows. Exit 1 / other → allow (fail open) so a hook bug never permanently bricks edits.

**Session state.** Tracked via a per-session marker file under `.claude/.nova/pre-edit-gate/<session_id>/`. `CLAUDE_SESSION_ID` (when present) keys the marker; otherwise a date-bucketed id, which is coarse but still narrows the gate's reach.

**Companion.** `pre-edit-gate-tracker.md` — `PostToolUse` hook matching `Read` that drops a marker when an `AGENTS.md` under `git-repositories/<repo>/` is read.

**Runtime path.** `.claude/hooks/pre-edit-gate.sh`

**Mode.** Default-ON for Claude (Kiro keeps it opt-in because Kiro's `KIRO_SESSION_ID` is less reliable). The `settings-snippet.json` registers it under `PreToolUse`. To disable: remove the `PreToolUse`+`PostToolUse` blocks from `.claude/settings.local.json` (the rest of the hook chain stays intact).

**Escape hatches.**
1. **Read the AGENTS.md.** Any `Read` tool call on `<repo_root>/AGENTS.md` clears the gate via the companion tracker — re-issue the same edit.
2. **Manual marker.** For one trivial mechanical edit:
   ```bash
   mkdir -p .claude/.nova/pre-edit-gate/<session_id> && touch .claude/.nova/pre-edit-gate/<session_id>/<repo_root_with_slashes_as_underscores>
   ```
3. **Per-session disable.** Comment out the `PreToolUse` block in `.claude/settings.local.json`.

**Generation.** Source of truth — adapters procedure extracts the bash block below to `<runtime>` with `chmod +x`. Edit this file, never the runtime copy.

**Failure mode.** Fail open. Empty stdin, missing `tool_name`, missing `file_path`, repo without `AGENTS.md` → exit 0 (allow).

```bash
#!/usr/bin/env bash
set -uo pipefail

input="$(cat 2>/dev/null || true)"
if [[ -z "$input" ]]; then
  exit 0
fi

tool_name="$(printf '%s' "$input" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')"

case "$tool_name" in
  Edit|Write|MultiEdit) ;;
  *) exit 0 ;;
esac

target_path="$(printf '%s' "$input" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')"
if [[ -z "$target_path" ]]; then
  exit 0
fi

project_dir="${CLAUDE_PROJECT_DIR:-.}"

# Normalize to absolute path under project_dir for consistent ancestor walking.
abs_target=""
case "$target_path" in
  /*) abs_target="$target_path" ;;
  *)  abs_target="$project_dir/$target_path" ;;
esac

# Only gate paths inside <project>/git-repositories/.
case "$abs_target" in
  "$project_dir"/git-repositories/*) ;;
  *) exit 0 ;;
esac

# Walk up from target's parent to find the repo root: first ancestor under
# git-repositories/ containing an AGENTS.md.
repo_root=""
ancestor="$(dirname "$abs_target")"
while [[ "$ancestor" == "$project_dir/git-repositories/"* ]]; do
  if [[ -f "$ancestor/AGENTS.md" ]]; then
    repo_root="$ancestor"
    break
  fi
  ancestor="$(dirname "$ancestor")"
done

# No AGENTS.md anywhere up the tree → repo isn't NOVA-conformant. Don't gate
# (avoid false positives on third-party clones).
if [[ -z "$repo_root" ]]; then
  exit 0
fi

session_id="${CLAUDE_SESSION_ID:-session-$(date +%Y%m%d)}"
marker_dir="$project_dir/.claude/.nova/pre-edit-gate/$session_id"
marker_file="$marker_dir/$(printf '%s' "${repo_root#$project_dir/}" | tr '/' '_')"

if [[ -f "$marker_file" ]]; then
  exit 0
fi

cat >&2 <<MSG
NOVA pre-edit gate blocked this $tool_name.

Target:    $abs_target
Repo root: $repo_root

Reason: NOVA Navigation Protocol step 4 requires reading the target repo's
AGENTS.md before editing files under it. That hasn't happened in this session.

What to do:
  1. Read $repo_root/AGENTS.md.
  2. Re-issue the same edit (the companion read-tracker hook clears the gate
     when AGENTS.md is read).

To bypass for one trivial mechanical edit, touch the marker:
  mkdir -p "$marker_dir" && touch "$marker_file"

To disable the gate entirely for this session, remove the PreToolUse +
PostToolUse blocks from .claude/settings.local.json (the rest of the hook
chain stays intact).
MSG

exit 2
```
