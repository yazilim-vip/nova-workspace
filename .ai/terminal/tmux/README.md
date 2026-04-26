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

## Gotchas

- **Run Claude's `/terminal-setup` outside tmux.** It writes host-emulator config (the terminal app's own settings file), not tmux's. Inside tmux it does nothing useful.
- **Nested tmux** (SSH-in-tmux-in-tmux) breaks Claude Agent Teams auto-split. Use one tmux layer at a time.
- **`vim-tmux-navigator` requires the matching nvim plugin** to make `Ctrl+h/j/k/l` cross editor/multiplexer boundaries — see `.ai/ide/neovim/`.

## Composes with

- `.ai/ide/neovim/README.md` — editor layer. Optional but recommended; gives you Claude-in-editor via `claudecode.nvim`.
- `.ai/terminal/README.md` § "Terminal emulator requirements (for Claude Code)" — host-emulator settings (`Shift+Enter` passthrough, meta-as-alt). **Required regardless of whether you use tmux**, since they're enforced by the outer terminal app, not by tmux.

## References

- [Claude Code — Configure your terminal](https://code.claude.com/docs/en/terminal-config)
- [`tmux-plugins/tpm`](https://github.com/tmux-plugins/tpm)
- [`omerxx/tmux-sessionx`](https://github.com/omerxx/tmux-sessionx)
- [`christoomey/vim-tmux-navigator`](https://github.com/christoomey/vim-tmux-navigator)
