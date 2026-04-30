# Hook: session-start (Claude)

**Purpose.** Implements **C4** (user-skill surfacing) for Claude Code. Mirrors `.ai/workspace/skills/` → `.claude/skills/` so Claude's native skill loader sees workspace user skills at trigger time. `rsync --delete` preferred; `cp -R` fallback. The destination is owned by the mirror — hand-authored Claude-only skills must live at `~/.claude/skills/`.

C1 (session-start broadcast) is satisfied by the `@` imports in `.claude/CLAUDE.md` — no hook-level broadcast is needed. The previous shared-checklist printing was removed on 2026-04-30 (subtraction pass) along with the checklist file itself.

**Runtime path.** `.claude/hooks/session-start.sh`

**Mode.** Default — installed by every Claude adapter run.

**Generation.** This file is the source of truth. The adapters procedure (`.ai/adapters/SKILL.md` step 5) extracts the single fenced ` ```bash ``` ` block below, writes it to the runtime path, and `chmod +x`. Edit this file — never the runtime copy.

**Failure mode.** Fail open. Missing skills source → exit 0 silently.

```bash
#!/usr/bin/env bash
set -uo pipefail

project_dir="${CLAUDE_PROJECT_DIR:-.}"
src_skills="${project_dir}/.ai/workspace/skills"
dst_skills="${project_dir}/.claude/skills"

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
