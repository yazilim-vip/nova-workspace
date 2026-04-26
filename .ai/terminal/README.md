# Terminal

Framework procedure — read when the user asks to set up the terminal layer of a Claude-Code-friendly dev stack: terminal multiplexer (tmux et al.) and the host-emulator settings Claude requires.

The editor layer (Neovim, IntelliJ, etc.) lives under `.ai/ide/`, not here.

## Why this exists

Claude Code's TUI breaks in subtle ways if the terminal layers below it aren't configured right — `Shift+Enter` collapses to plain `Enter`, the notification bell vanishes, the render loop flickers. This procedure owns those settings, separated by layer:

- **Terminal emulator** (Ghostty, iTerm2, Alacritty, Wezterm…) — must satisfy a small list of capabilities Claude depends on. See "Terminal emulator requirements" below.
- **Multiplexer** (tmux, etc.) — must pass those capabilities through to the inner terminal. One subdirectory per multiplexer.

## Core principle

**Committed procedure, per-dev artifacts** — same model as `.ai/ide/` and `.ai/adapters/`:

- The procedure docs + reference snippets live under `.ai/terminal/<multiplexer>/` — tracked, team-shared.
- The actual configs live in the developer's home directory (`~/.tmux.conf`, the terminal app's own config) — per-developer, not in this workspace.

This procedure does not generate a directory at the workspace root the way `.ai/ide/intellij/` does for `.idea/`.

## Anti-duplication rule

If a rule applies to every NOVA agent, it belongs in `AGENTS.md`. If it applies to every terminal procedure, it belongs here. Multiplexer-specific rules live in that multiplexer's subdirectory — never copied up. Editor-specific rules live under `.ai/ide/<editor>/` — never duplicated here.

## Terminal emulator requirements (for Claude Code)

Claude Code needs the host emulator to support a few non-default behaviors. These apply whether or not you use a multiplexer.

| Requirement | Why |
|-------------|-----|
| `Shift+Enter` sends the byte sequence `ESC \r` (i.e. `\x1b\r`), not plain `\r` | So Claude's prompt accepts a multiline newline instead of submitting on `Enter`. |
| Meta key reachable via Option (macOS) | So `Alt`-prefixed bindings inside Claude (and inside nvim if you use it) work. On macOS this means treating Option as Alt rather than as a compose key. |
| Modern xterm-compatible terminfo | So `extkeys` passthrough actually negotiates with tmux. |

### Tested emulators

- **Ghostty** — tested. Set in `~/.config/ghostty/config`:
  ```
  keybind = shift+enter=text:\x1b\r
  macos-option-as-alt = true
  ```
- Other modern emulators (iTerm2, Wezterm, Alacritty, Kitty) work; consult their docs for the equivalent two settings. NOVA does not prescribe which to use.

If you set Claude up under a new emulator, capture the equivalent settings as a PR to this section.

## Supported multiplexers

| Multiplexer | Subdirectory | Status |
|-------------|--------------|--------|
| tmux        | `.ai/terminal/tmux/` | supported |

More multiplexers get added as they're supported. Multiplexer is optional — Claude works fine without one.

## When to trigger

- "set up tmux", "set up my terminal", "I want a terminal IDE"
- "what should my .tmux.conf look like for Claude Code"
- "Shift+Enter doesn't work in Claude inside tmux"
- "Claude TUI looks broken in my terminal"

For editor setup ("set up neovim", "integrate claudecode.nvim"), see `.ai/ide/README.md`.

## Full stack recipe (tmux + Neovim + Ghostty)

This is the recipe most people in this workspace use. Three independently-installable docs, read in this order:

1. `.ai/terminal/README.md` § "Terminal emulator requirements" *(this file — host-emulator settings)*
2. `.ai/terminal/tmux/README.md` *(multiplexer)*
3. `.ai/ide/neovim/README.md` *(editor with `claudecode.nvim` MCP bridge)*

Each layer is independently swappable: nvim without tmux, tmux without nvim, or another emulator in place of Ghostty.

## Procedure entry points

Each multiplexer subdir has its own `README.md` describing the stack, install steps, and gotchas. Read the one for the multiplexer you're targeting — or skip the multiplexer entirely if you don't want one.
