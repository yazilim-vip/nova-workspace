# Hook: pre-edit-gate-tracker (Claude)

**Purpose.** Companion to `pre-edit-gate.md`. Fires on `PostToolUse` for `Read`; when the read target is a `git-repositories/<repo>/AGENTS.md`, drops a session marker so the pre-edit gate allows subsequent `Edit` / `Write` / `MultiEdit` under that repo this session.

Always exits 0 — this hook never blocks.

**Runtime path.** `.claude/hooks/pre-edit-gate-tracker.sh`

**Mode.** Default-ON for Claude — installed alongside `pre-edit-gate.md`. To disable, remove both the `PreToolUse` and `PostToolUse` blocks from `.claude/settings.local.json` (removing only one half leaves the gate active without a way to clear it — never do that).

**Generation.** Source of truth. Adapters procedure extracts the bash block below to runtime path, `chmod +x`.

```bash
#!/usr/bin/env bash
set -uo pipefail

input="$(cat 2>/dev/null || true)"
if [[ -z "$input" ]]; then
  exit 0
fi

tool_name="$(printf '%s' "$input" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')"

case "$tool_name" in
  Read) ;;
  *) exit 0 ;;
esac

target_path="$(printf '%s' "$input" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')"
if [[ -z "$target_path" ]]; then
  exit 0
fi

project_dir="${CLAUDE_PROJECT_DIR:-.}"

abs_target=""
case "$target_path" in
  /*) abs_target="$target_path" ;;
  *)  abs_target="$project_dir/$target_path" ;;
esac

case "$abs_target" in
  "$project_dir"/git-repositories/*) ;;
  *) exit 0 ;;
esac

# Only AGENTS.md reads count.
case "$abs_target" in
  */AGENTS.md) ;;
  *) exit 0 ;;
esac

repo_root="$(dirname "$abs_target")"

session_id="${CLAUDE_SESSION_ID:-session-$(date +%Y%m%d)}"
marker_dir="$project_dir/.claude/.nova/pre-edit-gate/$session_id"
marker_file="$marker_dir/$(printf '%s' "${repo_root#$project_dir/}" | tr '/' '_')"

mkdir -p "$marker_dir" 2>/dev/null
touch "$marker_file" 2>/dev/null

exit 0
```
