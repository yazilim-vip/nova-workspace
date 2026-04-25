#!/usr/bin/env bash
# NOVA — Kiro agent-spawn hook (C1 reinforcement)
#
# Fires when an agent (main or subagent) initializes. Prints the shared
# checklist + a one-line pointer to AGENTS.md to STDOUT, which Kiro injects
# into agent context.
#
# Redundant with `inclusion: always` steering (which is the primary C1 path)
# but cheap insurance against steering misload. Fails open: missing checklist
# = silent exit 0.
#
# Opt-in. Default adapters flow does not install this. Enable when the drift
# log shows session-start blind spots that the steering broadcast didn't catch.

set -uo pipefail

checklist=".ai/adapters/_shared/checklist.md"

if [[ -r "$checklist" ]]; then
  echo "NOVA workspace — agent spawn (read AGENTS.md if you have not):"
  cat "$checklist"
fi

exit 0
