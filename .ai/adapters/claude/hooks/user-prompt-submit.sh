#!/usr/bin/env bash
# NOVA — Claude user-prompt-submit hook
# Prints the shared re-injection checklist to stdout. Claude Code appends it
# to context on every user prompt. Counters mid-session context rot.
# Fails open: if checklist is missing or unreadable, exit 0 silently.

set -uo pipefail

checklist="${CLAUDE_PROJECT_DIR:-.}/.ai/adapters/_shared/checklist.md"

if [[ -r "$checklist" ]]; then
  cat "$checklist"
fi

exit 0
