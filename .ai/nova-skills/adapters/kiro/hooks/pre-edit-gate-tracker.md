# Hook: pre-edit-gate-tracker (Kiro)

**Purpose.** Companion to `pre-edit-gate.md`. Fires on `postToolUse` for read-class tools (`read`, `fs_read`); when the read target is a `git-repositories/<repo>/AGENTS.md`, drops a session marker so the pre-edit gate allows subsequent `fs_write` under that repo this session.

Always exits 0 — this hook never blocks.

**Runtime path.** `.kiro/hooks/pre-edit-gate-tracker.sh`

**Mode.** Opt-in — installed only when `pre-edit-gate.md` is installed. Default Kiro adapter flow does not install either. Companion `.kiro.hook` JSON: `pre-edit-gate-tracker.kiro.hook`.

**Generation.** Source of truth. The adapters procedure extracts the bash block below to the runtime path with `chmod +x` only when the user opts in.

```bash
#!/usr/bin/env bash
set -uo pipefail

input="$(cat 2>/dev/null || true)"
if [[ -z "$input" ]]; then
  exit 0
fi

tool_name="$(printf '%s' "$input" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')"

case "$tool_name" in
  read|fs_read) ;;
  *) exit 0 ;;
esac

target_path="$(printf '%s' "$input" | grep -o '"path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')"
if [[ -z "$target_path" ]]; then
  exit 0
fi

# Normalize absolute → relative under workspace.
case "$target_path" in
  */git-repositories/*)
    target_path="${target_path#*/git-repositories/}"
    target_path="git-repositories/$target_path"
    ;;
esac

# Only AGENTS.md reads inside git-repositories count.
case "$target_path" in
  git-repositories/*/AGENTS.md|git-repositories/*/*/AGENTS.md|git-repositories/*/*/*/AGENTS.md|git-repositories/*/*/*/*/AGENTS.md|git-repositories/*/*/*/*/*/AGENTS.md|git-repositories/*/*/*/*/*/*/AGENTS.md) ;;
  *) exit 0 ;;
esac

repo_root="$(dirname "$target_path")"

session_id="${KIRO_SESSION_ID:-session-$(date +%Y%m%d)}"
marker_dir=".kiro/.nova/pre-edit-gate/$session_id"
marker_file="$marker_dir/$(printf '%s' "$repo_root" | tr '/' '_')"

mkdir -p "$marker_dir" 2>/dev/null
touch "$marker_file" 2>/dev/null

exit 0
```
