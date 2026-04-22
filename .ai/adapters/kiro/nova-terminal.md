---
inclusion: always
---

# NOVA Workspace — Kiro Terminal Hazards (Strict)

Kiro's shell integration has known failure modes that hang the terminal indefinitely and force the user to kill the session. These rules are **non-negotiable**. When a task needs a shell command that trips any of them, use the workaround — don't shortcut.

## Known hazards

1. **Heredocs piped to commands** — `cat <<'EOF' | somecmd ... EOF` leaves zsh waiting on a continuation prompt. Terminal hangs. (Reported: [kirodotdev/Kiro#4756](https://github.com/kirodotdev/Kiro/issues/4756).)
2. **Complex multi-line inline commands** — anything with embedded newlines, `\` line continuations, or compound block syntax (`if ... then ... fi`, `for ... do ... done` inline) often loses stdout integration and Kiro waits forever on completion.
3. **Long-running commands** — dev servers, watchers, tailing logs (`npm run dev`, `tail -f`, `kubectl logs -f`) don't return, and Kiro cannot detect completion.
4. **Chained commands in one call** — `cmd1 && cmd2 && cmd3` where earlier output is large, or second command reads from prior state, can drop output and stall.
5. **Shell customizations** — Powerlevel10k, Oh My Posh, bash-it themes break terminal integration and cause "Working..." hangs regardless of the command. (Not something the agent can fix — flag it to the user if symptoms match.)

## Rules — what to do instead

### Rule 1: Never use heredocs in executed commands.
If you need multi-line content written to a file, use the file-write tool (not `cat <<EOF > file`). The only exception is `git commit -m "$(cat <<'EOF' ... EOF)"` — commit messages specifically. For any other multi-line payload, write the file directly.

### Rule 2: For multi-step shell logic, write a script to `scripts/` and execute it.
The workspace root has a gitignored `scripts/` directory for exactly this. Name it by purpose and date (`2026-04-22-<purpose>.sh`), make it executable, then run it as a single command. This keeps the executed command to one line and makes the work reviewable and debuggable.

```
# Instead of: a 6-line inline command chain
# Do this:
#   1. write scripts/2026-04-22-sync-users.sh via file-write tool
#   2. execute: bash scripts/2026-04-22-sync-users.sh
```

### Rule 3: One command per execution.
Don't chain with `&&`, `;`, or `|` across steps unless the entire chain is trivial (e.g. `mkdir foo && cd foo`). If the task needs multiple non-trivial steps, either run them as separate tool calls, or script them (Rule 2).

### Rule 4: Long-running commands — warn first, then hand off.
Before running anything that doesn't terminate on its own (dev servers, `tail -f`, watchers, `docker logs -f`, interactive REPLs), tell the user what you're about to start and ask them to run it themselves in their own terminal. Do not fire-and-forget a non-terminating command through Kiro's terminal — it will hang the chat.

### Rule 5: Prefer direct file tools over shell text manipulation.
Reading, writing, and editing files — use the IDE's file tools, not `cat`, `sed`, `awk`, `echo >`, or `tee`. Shell text manipulation is where multi-line hazards cluster.

### Rule 6: If the terminal hangs, stop and surface it.
Don't retry the same command. Tell the user the terminal appears stuck, name the likely cause (heredoc / multi-line / long-running), and suggest they press Enter in the terminal or restart the CLI session. Switch to Rule 2 (script file) on retry.

## When symptoms point at shell customization (not command shape)

If commands hang regardless of how simple they are — including `git status` or `ls` — the cause is likely a shell theme breaking terminal integration. Flag this to the user with these candidates:

- Powerlevel10k → add `typeset -g POWERLEVEL9K_TERM_SHELL_INTEGRATION=true` to `~/.p10k.zsh`
- Oh My Posh / bash-it → conditionally disable when running inside Kiro
- See Kiro's [troubleshooting guide](https://kiro.dev/docs/troubleshooting/) for the current list

This is a user-environment fix — not something the agent can patch from inside a session.
