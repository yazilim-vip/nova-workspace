#!/usr/bin/env bash
# NOVA — Claude session-start hook
# Prints the shared re-injection checklist to stdout so Claude Code appends it
# to session context on startup / resume / clear.
# Fails open: if checklist is missing or unreadable, exit 0 silently.

set -uo pipefail

checklist="${CLAUDE_PROJECT_DIR:-.}/.ai/adapters/_shared/checklist.md"

if [[ -r "$checklist" ]]; then
  cat "$checklist"
fi

exit 0
