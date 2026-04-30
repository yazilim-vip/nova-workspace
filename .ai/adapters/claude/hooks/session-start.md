# Hook: session-start (Claude)

**Purpose.** Implements **C1** (session-start broadcast) and **C4** (user-skill surfacing) for Claude Code.

1. Prints the shared re-injection checklist to STDOUT — Claude Code appends it to session context on `startup` / `resume` / `clear`.
2. Mirrors `.ai/workspace/skills/` → `.claude/skills/` so Claude's native skill loader sees workspace user skills at trigger time. `rsync --delete` preferred; `cp -R` fallback. The destination is owned by the mirror — hand-authored Claude-only skills must live at `~/.claude/skills/`.

**Runtime path.** `.claude/hooks/session-start.sh`

**Mode.** Default — installed by every Claude adapter run.

**Generation.** This file is the source of truth. The adapters procedure (`.ai/adapters/SKILL.md` step 5) extracts the single fenced ` ```bash ``` ` block below, writes it to the runtime path, and `chmod +x`. Edit this file — never the runtime copy.

**Failure mode.** Fail open. Any sub-step that errors must not block the session. Missing checklist or missing skills source → exit 0 silently.

```bash
#!/usr/bin/env bash
set -uo pipefail

project_dir="${CLAUDE_PROJECT_DIR:-.}"
checklist="${project_dir}/.ai/adapters/_shared/checklist.md"
src_skills="${project_dir}/.ai/workspace/skills"
dst_skills="${project_dir}/.claude/skills"

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

exit 0
```
