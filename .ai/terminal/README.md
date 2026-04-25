# Terminal

Framework procedure — read when the user asks to set up a terminal-native development stack (multiplexer + editor + Claude Code integration). Not a skill.

## Why this exists

Claude Code is most powerful when it lives inside the terminal alongside an editor that speaks its MCP protocol. The setup spans four moving parts (terminal host, multiplexer, editor, Claude bridge plugins) and one classic trap: each layer has its own keystroke quirks that silently break Claude's TUI if misconfigured. This procedure owns that mapping, one subdirectory per multiplexer.

## Core principle

**Committed procedure, per-dev artifacts** — same model as `.ai/ide/` and `.ai/adapters/`:

- The procedure docs + reference snippets live under `.ai/terminal/<multiplexer>/` — tracked, team-shared.
- The actual configs live in the developer's personal **dotfiles repo** (managed by GNU Stow or equivalent), not in this workspace. Configs are per-developer; the recipe is shared.

This procedure does not generate a directory at the workspace root the way `.ai/ide/intellij/` does for `.idea/`. The artifact lives in the user's home directory by design.

## Anti-duplication rule

If a rule applies to every NOVA agent, it belongs in `AGENTS.md`. If it applies to every terminal procedure, it belongs here. Multiplexer-specific rules (Zellij keybind quirks, tmux passthrough escape codes) live in that multiplexer's subdirectory — never copied up.

## Supported multiplexers

| Multiplexer | Subdirectory | Status |
|-------------|--------------|--------|
| tmux        | `.ai/terminal/tmux/` | supported |

More multiplexers get added as they're supported.

## When to trigger

- "set up tmux", "set up my terminal", "I want a terminal IDE"
- "integrate Claude Code with neovim/tmux"
- "what should my .tmux.conf look like for Claude Code"
- "Shift+Enter doesn't work in Claude inside tmux"
- "Claude TUI looks broken in my terminal"

## Procedure entry points

Each multiplexer subdir has its own `README.md` describing the stack, install steps, and gotchas. Read the one for the multiplexer you're targeting.
