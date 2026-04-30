# Hook: agent-spawn (Kiro)

**Purpose.** **C1** reinforcement. Fires when an agent (main or subagent) initializes; prints the shared checklist + a one-line pointer to `AGENTS.md` to STDOUT, which Kiro injects into agent context.

Redundant with `inclusion: always` steering (the primary C1 path) but cheap insurance against steering misload.

**Runtime path.** `.kiro/hooks/agent-spawn.sh`

**Mode.** Opt-in. Default Kiro adapter flow does not install this. Enable when the drift log shows session-start blind spots that the steering broadcast didn't catch. Companion `.kiro.hook` JSON: `agent-spawn.kiro.hook`.

**Generation.** Source of truth. The adapters procedure extracts the bash block below to the runtime path with `chmod +x` only when the user opts in.

**Failure mode.** Fail open — missing checklist → silent exit 0.

```bash
#!/usr/bin/env bash
set -uo pipefail

checklist=".ai/adapters/_shared/checklist.md"

if [[ -r "$checklist" ]]; then
  echo "NOVA workspace — agent spawn (read AGENTS.md if you have not):"
  cat "$checklist"
fi

exit 0
```
