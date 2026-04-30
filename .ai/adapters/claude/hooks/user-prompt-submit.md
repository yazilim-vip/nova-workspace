# Hook: user-prompt-submit (Claude)

**Purpose.** Implements **C2** (per-turn re-injection), refreshes **C4** mid-session, and adds task-aware pointers from `.ai/adapters/_shared/task-pointers.md`.

1. Prints the shared re-injection checklist (counters mid-session attention rot).
2. Re-mirrors `.ai/workspace/skills/` → `.claude/skills/` so edits to a workspace skill land in the loader on the next prompt without `/clear` (Claude may still need a session reset to pick up updated `description` fields, depending on caching).
3. Captures the user prompt from stdin (Claude Code passes a JSON envelope with the prompt) and matches it against the keyword→pointer table in `.ai/adapters/_shared/task-pointers.md`. Any matches are emitted as "Consider:" lines under the static checklist — turning the static C2 reminder into just-in-time, task-relevant context.

The pointer matching is best-effort: stdin is grep'd raw (no JSON parsing) so failure modes are silent. False positives from the JSON envelope are negligible because the patterns are workspace-specific keywords. If `task-pointers.md` is missing or stdin is empty, the hook falls back to plain checklist behavior.

**Runtime path.** `.claude/hooks/user-prompt-submit.sh`

**Mode.** Default — installed by every Claude adapter run.

**Generation.** Source of truth. Adapters procedure extracts the bash block below to runtime path with `chmod +x`.

**Failure mode.** Fail open. Never exits 2 — any sub-step error is swallowed via `|| true`. Claude Code treats exit 2 as blocking and ignores stdout, so the hook stays at exit 0.

```bash
#!/usr/bin/env bash
set -uo pipefail

project_dir="${CLAUDE_PROJECT_DIR:-.}"
checklist="${project_dir}/.ai/adapters/_shared/checklist.md"
pointers="${project_dir}/.ai/adapters/_shared/task-pointers.md"
src_skills="${project_dir}/.ai/workspace/skills"
dst_skills="${project_dir}/.claude/skills"

# Capture stdin (Claude Code passes a JSON envelope with `prompt`). Read once
# even if we don't end up using it for pointer matching — once stdin is
# consumed it's gone.
stdin_payload=""
if [[ ! -t 0 ]]; then
  stdin_payload=$(cat 2>/dev/null || true)
fi

if [[ -r "$checklist" ]]; then
  cat "$checklist"
fi

if [[ -d "$src_skills" ]]; then
  mkdir -p "$dst_skills"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete --exclude='.DS_Store' "$src_skills/" "$dst_skills/" >/dev/null 2>&1 || true
  else
    find "$dst_skills" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
    cp -R "$src_skills/." "$dst_skills/" 2>/dev/null || true
    find "$dst_skills" -name '.DS_Store' -delete 2>/dev/null || true
  fi
fi

if [[ -n "$stdin_payload" && -r "$pointers" ]]; then
  matches=""
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    case "$line" in *' => '*) ;; *) continue ;; esac
    pattern="${line%% => *}"
    pointer="${line#* => }"
    pattern="${pattern# }"; pattern="${pattern% }"
    pointer="${pointer# }"; pointer="${pointer% }"
    [[ -z "$pattern" || -z "$pointer" ]] && continue
    if printf '%s' "$stdin_payload" | grep -qiE -- "$pattern" 2>/dev/null; then
      matches+="- $pointer"$'\n'
    fi
  done < <(awk '/^<!-- begin-pointers -->$/{f=1; next} /^<!-- end-pointers -->$/{f=0} f' "$pointers" 2>/dev/null)
  if [[ -n "$matches" ]]; then
    echo
    echo "Task-relevant pointers (consider before acting):"
    printf '%s' "$matches"
  fi
fi

exit 0
```
