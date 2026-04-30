# Hook: prompt-submit (Kiro)

**Purpose.** Implements **C2** (per-turn re-injection) for Kiro. Three jobs:

1. Print the shared re-injection checklist (Kiro appends it to agent context when `runCommand` exits 0).
2. Match the user prompt against the keyword→pointer table in `.ai/adapters/_shared/task-pointers.md` and emit any matches as "Consider:" lines under the static checklist — same just-in-time retrieval pattern as Claude's `user-prompt-submit` hook.
3. (No mirror step.) **C4** is satisfied natively on Kiro via `skill://` URIs in agent JSON `resources` — Kiro reads `.ai/workspace/skills/` directly, so no sync is needed.

Kiro sets `USER_PROMPT` as an env var for shell-command actions on `promptSubmit` — that's the prompt source for matching (Claude reads stdin instead). If the env var is empty, the hook falls back to plain checklist behavior.

**Runtime path.** `.kiro/hooks/prompt-submit.sh`

**Mode.** Default — installed by every Kiro adapter run.

**Generation.** Source of truth. The adapters procedure extracts the bash block below to the runtime path with `chmod +x`. Edit this file — never the runtime copy.

**Failure mode.** Fail open. Missing checklist or pointer table → silent exit 0.

```bash
#!/usr/bin/env bash
set -uo pipefail

# Kiro runs hooks from the workspace root by default.
checklist=".ai/adapters/_shared/checklist.md"
pointers=".ai/adapters/_shared/task-pointers.md"

if [[ -r "$checklist" ]]; then
  cat "$checklist"
fi

prompt="${USER_PROMPT:-}"
if [[ -n "$prompt" && -r "$pointers" ]]; then
  matches=""
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    case "$line" in *' => '*) ;; *) continue ;; esac
    pattern="${line%% => *}"
    pointer="${line#* => }"
    pattern="${pattern# }"; pattern="${pattern% }"
    pointer="${pointer# }"; pointer="${pointer% }"
    [[ -z "$pattern" || -z "$pointer" ]] && continue
    if printf '%s' "$prompt" | grep -qiE -- "$pattern" 2>/dev/null; then
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
