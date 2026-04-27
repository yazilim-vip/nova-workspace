---
name: nova-terminal
description: Configures the terminal layer of a Claude-Code-friendly dev stack — terminal multiplexer (tmux et al.) and host-emulator settings (Shift+Enter passthrough, meta-as-alt). Use when the user is bootstrapping their terminal setup for NOVA work, or when terminal-side bugs prevent Claude from working correctly (e.g. Shift+Enter typing literal escape sequences). Editor layer (Neovim, IntelliJ) lives under `.ai/ide/`, not here.
---

# Terminal

Framework skill — terminal multiplexer + host-emulator setup for a Claude-Code-friendly dev stack. The editor layer (Neovim, IntelliJ, etc.) lives under `.ai/ide/`, not here.

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

More multiplexers get added as they're supported. A multiplexer is optional — Claude works fine without one. Editor setup (Neovim, IntelliJ) belongs to `.ai/ide/SKILL.md`, not here.

## Full stack recipe (tmux + Neovim + Ghostty)

The most common stack in this workspace. Three independently-installable layers, each swappable:

1. `.ai/terminal/SKILL.md` § "Terminal emulator requirements" *(this file — host-emulator settings)*
2. `.ai/terminal/tmux/README.md` *(multiplexer; includes an opt-in one-shot bindings block — Alt+i/j/k/l pane focus, Alt+Left/Right windows, etc. — for users who want single-key actions instead of prefix combos)*
3. `.ai/ide/neovim/README.md` *(editor with `claudecode.nvim` MCP bridge)*

Substitution menu:
- nvim without tmux — skip layer 2.
- tmux without nvim — skip layer 3 (any editor works; nvim just integrates best).
- Another emulator (iTerm2, Wezterm, Alacritty, Kitty…) — replace Ghostty's settings with the equivalent two: `Shift+Enter` → `\x1b\r`, and Option-as-Alt on macOS.

## Procedure entry points

Each multiplexer subdir's `README.md` is the install recipe — required settings, plugins, keybinding cheat sheets, gotchas, and any opt-in extras. Read the one for the multiplexer you're targeting, or skip the multiplexer entirely if you don't want one. The host-emulator requirements above (Shift+Enter, Option-as-Alt) apply regardless.
