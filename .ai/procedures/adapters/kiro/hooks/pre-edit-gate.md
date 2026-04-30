# Hook: pre-edit-gate (Kiro)

**Purpose.** Implements **S1** (pre-edit gate) for Kiro. Blocks `fs_write` on files under `git-repositories/<repo>/` until that repo's `AGENTS.md` has been read at least once in the current Kiro session — turning Navigation Protocol step 4 from "should have read it" into "can't write until you have."

**Mechanism.** Kiro fires a `preToolUse` hook with the tool name + `tool_input` (JSON) on STDIN. Exit 2 blocks the tool call; STDERR is returned to the LLM as the rejection reason. Exit 0 allows the call. Exit 1 / other → allow (fail open) so a hook bug never permanently bricks edits.

**Session state.** Tracked via a per-session marker file. `KIRO_SESSION_ID` (when present) keys the marker; otherwise the script falls back to a date-bucketed id, which is coarse but still narrows the gate's reach.

**Companion.** `pre-edit-gate-tracker.md` records AGENTS.md reads and clears the gate.

**Escape hatch.** For false positives: read the repo's AGENTS.md (any read tool call counts via the companion read-tracker), then retry. Or disable the hook by toggling `enabled=false` in the `.kiro.hook` JSON. To bypass intentionally for a single trivial mechanical edit:

```bash
mkdir -p .kiro/.nova/pre-edit-gate/<session_id>
touch    .kiro/.nova/pre-edit-gate/<session_id>/<repo_root_with_underscores>
```

**Runtime path.** `.kiro/hooks/pre-edit-gate.sh`

**Mode.** Opt-in. Default Kiro adapter flow does **not** install this. Enable when the drift log shows repeated "skipped step 4" incidents that the per-turn checklist isn't catching. Companion `.kiro.hook` JSON: `pre-edit-gate.kiro.hook`.

**Generation.** Source of truth. The adapters procedure extracts the bash block below to the runtime path with `chmod +x` *only when the user opts in*. Edit this file — never the runtime copy.

```bash
#!/usr/bin/env bash
set -uo pipefail

# Read tool input from STDIN (Kiro contract). On any read failure → fail open.
input="$(cat 2>/dev/null || true)"
if [[ -z "$input" ]]; then
  exit 0
fi

# Extract tool name + target path. grep+sed instead of jq — keeps the hook
# dependency-free; tool_input shape is documented by Kiro.
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
# Depth varies (repos.md uses <platform>/<group-path>/<repo-name>) — walk up
# from target_path; first ancestor under git-repositories/ that contains
# AGENTS.md is the repo root.
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

session_id="${KIRO_SESSION_ID:-session-$(date +%Y%m%d)}"
marker_dir=".kiro/.nova/pre-edit-gate/$session_id"
marker_file="$marker_dir/$(printf '%s' "$repo_root" | tr '/' '_')"

if [[ -f "$marker_file" ]]; then
  exit 0
fi

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
```
