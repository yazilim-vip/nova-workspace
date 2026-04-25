#!/usr/bin/env bash
# NOVA — Kiro pre-edit gate read tracker (companion to pre-edit-gate.sh)
#
# Fires on `postToolUse` for read-class tools. When the read target is a
# git-repositories/<repo>/AGENTS.md, drop a marker so the pre-edit-gate
# allows subsequent fs_write under that repo this session.
#
# Always exits 0 — this hook never blocks.

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
