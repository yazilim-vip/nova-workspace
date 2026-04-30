---
name: nova-terminal
description: Configures the terminal layer of a Claude-Code-friendly dev stack — terminal multiplexer (tmux et al.) and host-emulator settings (Shift+Enter passthrough, meta-as-alt). Use when the user is bootstrapping their terminal setup for NOVA work, or when terminal-side bugs prevent Claude from working correctly (e.g. Shift+Enter typing literal escape sequences). Editor layer (Neovim, IntelliJ) lives under `.ai/nova-skills/ide/`, not here.
---

# nova-terminal

Configures the terminal layer for Claude Code: host-emulator settings (Shift+Enter, Option-as-Alt) and an optional multiplexer (tmux). Editor configuration is `nova-ide`'s job — defer to `.ai/nova-skills/ide/SKILL.md`.

## Instructions

When invoked, work the procedure in order. Skip steps that are already in place.

### 1. Identify the target

Ask one question if it isn't already obvious from the user's prompt:

- **Host-emulator only** (no multiplexer): just steps 2 and 5.
- **Multiplexer setup** (typically tmux): steps 2 → 3 → 5.
- **Full stack** (host emulator + tmux + Neovim): steps 2 → 3 → 4 → 5.

Multiplexer is optional — Claude works fine without one. The host-emulator settings are required regardless.

### 2. Configure the host emulator

These apply whether or not a multiplexer is used. Read § "Host-emulator requirements" below for the table of required settings and the per-emulator config snippets.

For each requirement, check the user's emulator config and add the missing settings. If the user is on an emulator not listed in § "Tested emulators," ask them to look up the equivalent two settings (Shift+Enter binding, Option-as-Alt) in the emulator's docs. After applying changes, ask the user to fully restart the emulator — most emulators don't reload these settings live.

### 3. Set up the multiplexer

Currently only tmux is supported. Hand off to the multiplexer's subdirectory README — it owns prefix, plugins, keybindings, opt-in extras, and gotchas. Do not duplicate that content here.

- tmux → read `.ai/nova-skills/terminal/tmux/README.md` and follow its install steps.

The tmux README also includes an **opt-in one-shot bindings block** (Alt+i/j/k/l for pane focus, Alt+Left/Right for window navigation, Alt+v/s for splits, etc.) — surface this option to the user; don't apply it without their explicit yes.

### 4. Set up the editor

Out of scope for this skill. Hand off to `nova-ide` (specifically `.ai/nova-skills/ide/neovim/README.md` for the most common Claude-friendly editor stack).

### 5. Verify each layer

- **Host emulator**: ask the user to open a fresh terminal window outside any multiplexer and run `claude`, then press Shift+Enter inside Claude's prompt. It must produce a newline, not submit. If it submits, the emulator setting didn't take — re-check or restart.
- **Multiplexer**: ask the user to start a tmux session, hit the prefix, and confirm a basic action (e.g. `prefix + v` for vertical split). If `escape-time` was missed, the TUI render flickers — flag and fix.
- **Editor**: defer to `nova-ide`'s verification.

## Host-emulator requirements (for Claude Code)

Claude Code needs the host emulator to support a few non-default behaviors:

| Requirement | Why |
|-------------|-----|
| `Shift+Enter` sends `ESC \r` (i.e. `\x1b\r`), not plain `\r` | So Claude's prompt accepts a multiline newline instead of submitting on `Enter`. |
| Option-as-Alt on macOS | So `Alt`-prefixed bindings (inside Claude, inside nvim, inside tmux) work. |
| Modern xterm-compatible terminfo | So `extkeys` passthrough actually negotiates with tmux. |

### Tested emulators

- **Ghostty** — set in `~/.config/ghostty/config`:
  ```
  keybind = shift+enter=text:\x1b\r
  macos-option-as-alt = true
  ```
- iTerm2, Wezterm, Alacritty, Kitty all support equivalent settings; consult their docs. NOVA does not prescribe a choice. If you set Claude up under a new emulator, capture the equivalent settings as a PR to this section.

## Supported multiplexers

| Multiplexer | Subdirectory | Status |
|-------------|--------------|--------|
| tmux        | `.ai/nova-skills/terminal/tmux/` | supported |

## Full stack recipe (tmux + Neovim + Ghostty)

The most common stack in this workspace. Three independently-installable layers, each swappable:

1. **Host emulator** — § "Host-emulator requirements" (above).
2. **Multiplexer** — `.ai/nova-skills/terminal/tmux/README.md` (includes the opt-in one-shot bindings block: Alt+i/j/k/l pane focus, Alt+Left/Right windows, etc.).
3. **Editor** — `.ai/nova-skills/ide/neovim/README.md` (`claudecode.nvim` MCP bridge).

Substitution menu:
- nvim without tmux — skip layer 2.
- tmux without nvim — skip layer 3 (any editor works; nvim integrates best via the MCP bridge).
- Another emulator — replace Ghostty's settings with the equivalent Shift+Enter binding and Option-as-Alt.

## Anti-duplication

- Multiplexer-specific rules live under `.ai/nova-skills/terminal/<multiplexer>/` — never copied into this file.
- Editor-specific rules live under `.ai/nova-skills/ide/<editor>/` — never duplicated here.
- Configs themselves (`~/.tmux.conf`, the emulator's config file) live in the developer's home directory, not in this workspace. This skill produces a procedure and reference snippets, not generated config files.
