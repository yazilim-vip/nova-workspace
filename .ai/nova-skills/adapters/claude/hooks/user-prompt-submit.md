# Hook: user-prompt-submit (Claude)

**Purpose.** Refreshes **C4** mid-session — re-mirrors `.ai/workspace/skills/` → `.claude/skills/` so edits to a workspace skill land in the loader on the next prompt without `/clear` (Claude may still need a session reset to pick up updated `description` fields, depending on caching).

C2 (per-turn re-injection) was removed on 2026-04-30 (subtraction pass) along with the shared checklist and task-pointers files. The mid-session re-mirror is the only reason this hook still exists; if you don't edit skills mid-session, you can drop the hook entirely from `settings.local.json`.

**Runtime path.** `.claude/hooks/user-prompt-submit.sh`

**Mode.** Default — installed by every Claude adapter run.

**Generation.** Source of truth. Adapters procedure extracts the bash block below to runtime path with `chmod +x`.

**Failure mode.** Fail open. Never exits 2 — any sub-step error is swallowed via `|| true`. Claude Code treats exit 2 as blocking and ignores stdout, so the hook stays at exit 0.

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
