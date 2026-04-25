#!/usr/bin/env bash
# NOVA — Kiro pre-edit gate (S1)
#
# Blocks fs_write on files under git-repositories/<repo>/ until that repo's
# AGENTS.md has been read at least once in the current Kiro session.
#
# Mechanism: Kiro fires a `preToolUse` hook with the tool name + tool_input
# (JSON) on STDIN. Exit 2 blocks the tool call; STDERR is returned to the LLM
# as the rejection reason. Exit 0 allows the call. Exit 1 / other → allow
# (fail open) so a hook bug never permanently bricks edits.
#
# Session state is tracked via a per-session marker file. KIRO_SESSION_ID
# (when present) keys the marker; otherwise we fall back to a date-bucketed
# id, which is coarse but still narrows the gate's reach.
#
# Opt-in only — install by copying this file + pre-edit-gate.kiro.hook into
# .kiro/hooks/. Default adapters flow does NOT install this.
#
# Escape hatch for false positives: read the repo's AGENTS.md (any read tool
# call counts via the companion read-tracker, see pre-edit-gate.kiro.hook
# matcher), then retry. Or disable the hook by toggling enabled=false in the
# .kiro.hook JSON.

set -uo pipefail

# Read tool input from STDIN (Kiro contract). On any read failure → fail open.
input="$(cat 2>/dev/null || true)"
if [[ -z "$input" ]]; then
  exit 0
fi

# Extract tool name + target path. We use grep+sed instead of jq to keep the
# hook dependency-free; tool_input shape is documented by Kiro.
tool_name="$(printf '%s' "$input" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')"

# Only gate fs_write (and its alias `write`). Other tools → allow.
case "$tool_name" in
  fs_write|write) ;;
  *) exit 0 ;;
esac

target_path="$(printf '%s' "$input" | grep -o '"path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')"
if [[ -z "$target_path" ]]; then
  exit 0
fi

# Only gate paths under git-repositories/<repo>/.
case "$target_path" in
  git-repositories/*) ;;
  */git-repositories/*)
    target_path="${target_path#*/git-repositories/}"
    target_path="git-repositories/$target_path"
    ;;
  *) exit 0 ;;
esac

# Determine the repo root: git-repositories/<platform>/<...>/<repo>.
# We can't infer the depth from the path alone — repos.md uses a
# <platform>/<group-path>/<repo-name> convention with variable depth.
# Strategy: walk up from target_path, looking for an AGENTS.md inside the
# git-repositories tree. The first ancestor under git-repositories/ that
# contains AGENTS.md is the repo root.
repo_root=""
ancestor="$(dirname "$target_path")"
while [[ "$ancestor" == git-repositories/* ]]; do
  if [[ -f "$ancestor/AGENTS.md" ]]; then
    repo_root="$ancestor"
    break
  fi
  ancestor="$(dirname "$ancestor")"
done

# No AGENTS.md anywhere up the tree → repo isn't NOVA-conformant.
# Don't gate (avoid false positives on third-party clones).
if [[ -z "$repo_root" ]]; then
  exit 0
fi

# Build the session marker path.
session_id="${KIRO_SESSION_ID:-session-$(date +%Y%m%d)}"
marker_dir=".kiro/.nova/pre-edit-gate/$session_id"
marker_file="$marker_dir/$(printf '%s' "$repo_root" | tr '/' '_')"

if [[ -f "$marker_file" ]]; then
  # Repo's AGENTS.md was acknowledged this session — allow.
  exit 0
fi

# Block. STDERR goes back to the LLM verbatim.
cat >&2 <<MSG
NOVA pre-edit gate blocked this fs_write.

Target:    $target_path
Repo root: $repo_root

Reason: NOVA Navigation Protocol step 4 requires reading the target repo's
AGENTS.md before editing files under it. That hasn't happened in this session.

What to do:
  1. Read $repo_root/AGENTS.md.
  2. Re-issue the same write.

The companion read-tracker hook records the read and clears this gate.
To bypass intentionally (e.g. trivial mechanical edit), touch the marker:
  mkdir -p $marker_dir && touch $marker_file
MSG

exit 2
