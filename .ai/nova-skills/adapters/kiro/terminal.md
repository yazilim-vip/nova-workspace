# Kiro — Terminal Rules (Strict, Non-Negotiable)

Referenced from `.kiro/steering/nova.md`. Kiro's shell integration hangs the CLI on specific command shapes and shell customizations. These rules exist because users have hit those hangs repeatedly. Obey them — do not paraphrase, do not shortcut.

Related issues: [Kiro#4756](https://github.com/kirodotdev/Kiro/issues/4756) (heredoc hang), [Kiro#2814](https://github.com/kirodotdev/Kiro/issues/2814) (terminal stuck), [Kiro#1428](https://github.com/kirodotdev/Kiro/issues/1428), [troubleshooting](https://kiro.dev/docs/troubleshooting/).

## Rules

### 1. Never use heredocs in executed commands.
`cat <<'EOF' | somecmd ... EOF` hangs zsh on a continuation prompt. For multi-line file content, use the file-write tool — not `cat <<EOF > file`. The only exception is `git commit -m "$(cat <<'EOF' ... EOF)"` for commit message bodies.

### 2. For multi-step shell logic, write a script to `scripts/` and execute the file.
The workspace root has a gitignored `scripts/` directory (see `AGENTS.md` — Scratch Space section). Name it by purpose and date (`2026-04-22-<purpose>.sh`), make it executable, then invoke it as a single command. This keeps the executed call to one line and makes the work reviewable.

### 3. One command per execution.
Do not chain non-trivial steps with `&&`, `;`, or `|`. Trivial pairs like `mkdir foo && cd foo` are fine. Multi-step logic → Rule 2.

### 4. Long-running commands — hand off to the user.
Before running anything that doesn't terminate on its own (dev servers, `tail -f`, watchers, `docker logs -f`, interactive REPLs), tell the user what to run and ask them to run it in their own terminal. Do not fire-and-forget a non-terminating command through Kiro — it will hang the chat.

### 5. Prefer direct file tools over shell text manipulation.
Reading, writing, and editing files — use the IDE's file tools, not `cat`, `sed`, `awk`, `echo >`, or `tee`. Shell text manipulation is where multi-line hazards cluster.

### 6. If the terminal hangs, stop and surface it.
Don't retry the same command. Tell the user the terminal appears stuck, name the likely cause (heredoc / multi-line / long-running / shell theme), and suggest they press Enter or restart the CLI session. On retry, switch to Rule 2.

## When the cause is shell customization, not command shape

If commands hang regardless of shape — including `git status` or `ls` — the cause is likely a shell theme breaking terminal integration. Flag it to the user:

- Powerlevel10k → add `typeset -g POWERLEVEL9K_TERM_SHELL_INTEGRATION=true` to `~/.p10k.zsh`.
- Oh My Posh / bash-it → conditionally disable when inside Kiro.
- See Kiro's [troubleshooting guide](https://kiro.dev/docs/troubleshooting/) for the current list.

This is a user-environment fix — not something the agent can patch from inside a session.
