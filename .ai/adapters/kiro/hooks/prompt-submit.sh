#!/usr/bin/env bash
# NOVA — Kiro prompt-submit hook
# Prints the shared re-injection checklist to stdout. Kiro appends it
# to agent context on every user prompt (when the hook's runCommand exits 0).
# Fails open: if checklist is missing or unreadable, exit 0 silently.
#
# Kiro sets USER_PROMPT as an env var for shell actions on promptSubmit —
# we don't use it here, but it's available for future gating logic.

set -uo pipefail

# Kiro runs hooks from the workspace root by default.
checklist=".ai/adapters/_shared/checklist.md"

if [[ -r "$checklist" ]]; then
  cat "$checklist"
fi

exit 0
