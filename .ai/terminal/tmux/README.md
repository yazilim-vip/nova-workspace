# Terminal — tmux

Multiplexer layer. Owns tmux-only configuration: prefix, key passthrough, plugins, gotchas. The editor and terminal-emulator layers live elsewhere — see "Composes with" at the bottom.

Configs live as plain files in their native location (`~/.tmux.conf`). No dotfiles repo, no Stow. Treat this README as the install recipe; if a machine needs the same setup, follow the steps below.

## Required tmux settings

| Setting | Value | Why |
|---------|-------|-----|
| `prefix` | `Ctrl+Space` | Free key, doesn't collide with shell or Claude. **Don't use `Ctrl+J`** — that's Claude's hard-coded newline. |
| `escape-time` | `10` | **Never `0`.** Zero breaks Claude's TUI render loop. |
| `allow-passthrough` | `on` | Without it, Claude's notification bell + progress indicators silently disappear. |
| `extended-keys` | `on` | Required (with `terminal-features` below) so `Shift+Enter` from the host emulator reaches Claude as a newline instead of being collapsed to `Enter`. |
| `terminal-features` | `'xterm*:extkeys'` | Same purpose — declares the extended-keys capability to the inner terminal. |

tmux 3.4+ required.

## Plugins (TPM)

```
tmux-sensible
vim-tmux-navigator       # Ctrl+h/j/k/l crosses nvim splits and tmux panes
tmux-resurrect           # save/restore session state
tmux-continuum           # auto-save resurrect on a timer
tmux-yank                # OSC52 clipboard
omerxx/tmux-sessionx     # fuzzy session switcher
```

Install TPM, then `prefix + I` to fetch:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# in tmux: Ctrl+Space, then Shift+I
```

## Keybindings cheat sheet

Prefix = `Ctrl+Space`.

| Bind | Action |
|------|--------|
| `prefix + v` / `s` | Vertical / horizontal split |
| `prefix + h/j/k/l` | Pane focus |
| `prefix + C-c` | New window with pre-built layout (e.g. nvim \| claude / lazygit) |
| `prefix + y` | Yazi popup |
| `prefix + o` | Sessionx fuzzy session switcher |
| `prefix + I` | Install TPM plugins (after editing `.tmux.conf`) |
| `prefix + C-s` / `C-r` | Resurrect save / restore |

## Optional: one-shot bindings (no prefix)

Two-key prefix combos (`Ctrl+Space` then `v`) are tmux's default for safety — single-key bindings can collide with shell, editor, or app keys. But for high-frequency actions, a one-shot bind is faster. The trick is picking a modifier that's free across the stack.

**`Alt+<key>` is the safe space.** Shell and Claude don't claim Alt-prefixed keys; vim uses Alt rarely (and you can rebind around it). The prerequisite is host-emulator "meta-as-alt" — already required by `.ai/terminal/SKILL.md`, so you're already paying that cost.

This section is **opt-in** — add only if you want it. Bindings live alongside (not instead of) the prefix bindings, so muscle memory for either keeps working.

| Bind | Action |
|------|--------|
| `Ctrl+h/j/k/l` | Pane focus (already prefix-less via `vim-tmux-navigator`) |
| `Alt+h/l` | Previous / next window |
| `Alt+1`…`Alt+9` | Jump to window N |
| `Alt+v` | Vertical split |
| `Alt+s` | Horizontal split |
| `Alt+n` | New window |
| `Alt+x` | Close pane (with confirm) |
| `Alt+z` | Toggle zoom |

Add to `~/.tmux.conf`:

```tmux
# One-shot (no-prefix) bindings — opt-in. Requires host-emulator meta-as-alt.
bind-key -n M-h previous-window
bind-key -n M-l next-window
bind-key -n M-1 select-window -t 1
bind-key -n M-2 select-window -t 2
bind-key -n M-3 select-window -t 3
bind-key -n M-4 select-window -t 4
bind-key -n M-5 select-window -t 5
bind-key -n M-6 select-window -t 6
bind-key -n M-7 select-window -t 7
bind-key -n M-8 select-window -t 8
bind-key -n M-9 select-window -t 9
bind-key -n M-v split-window -h -c "#{pane_current_path}"
bind-key -n M-s split-window -v -c "#{pane_current_path}"
bind-key -n M-n new-window -c "#{pane_current_path}"
bind-key -n M-x confirm-before -p "kill pane? (y/n)" kill-pane
bind-key -n M-z resize-pane -Z
```

**Why these picks:**
- `Alt+h/l` mirrors vim-style horizontal motion at the window level (Alt+j/k are intentionally *not* taken — they'd collide with vim-tmux-navigator's pane logic in some terminal apps).
- `Alt+v`/`Alt+s` mirror vim split commands and the existing `prefix + v/s` muscle memory.
- `Alt+1`…`Alt+9` matches the convention many tiling WMs and modern terminals use, so it transfers across tools.
- `Alt+x` is gated behind a confirm prompt because pane kill is destructive.

**Skip-list (don't bind these without research):**
- `Alt+f`, `Alt+b`, `Alt+d`, `Alt+.` — readline word-motion / yank-last-arg in zsh & bash. Binding them in tmux breaks shell editing.
- `Alt+Enter` — some terminals send this as toggle-fullscreen.
- `Alt+,`, `Alt+;` — vim default `g,`/`g;` analogues if you remap.

## Gotchas

- **Run Claude's `/terminal-setup` outside tmux.** It writes host-emulator config (the terminal app's own settings file), not tmux's. Inside tmux it does nothing useful.
- **Nested tmux** (SSH-in-tmux-in-tmux) breaks Claude Agent Teams auto-split. Use one tmux layer at a time.
- **`vim-tmux-navigator` requires the matching nvim plugin** to make `Ctrl+h/j/k/l` cross editor/multiplexer boundaries — see `.ai/ide/neovim/`.

## Composes with

- `.ai/ide/neovim/README.md` — editor layer. Optional but recommended; gives you Claude-in-editor via `claudecode.nvim`.
- `.ai/terminal/SKILL.md` § "Terminal emulator requirements (for Claude Code)" — host-emulator settings (`Shift+Enter` passthrough, meta-as-alt). **Required regardless of whether you use tmux**, since they're enforced by the outer terminal app, not by tmux.

## References

- [Claude Code — Configure your terminal](https://code.claude.com/docs/en/terminal-config)
- [`tmux-plugins/tpm`](https://github.com/tmux-plugins/tpm)
- [`omerxx/tmux-sessionx`](https://github.com/omerxx/tmux-sessionx)
- [`christoomey/vim-tmux-navigator`](https://github.com/christoomey/vim-tmux-navigator)
