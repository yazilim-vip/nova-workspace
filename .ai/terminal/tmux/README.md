# Terminal — tmux

Stack: **Ghostty + tmux + Neovim (`vim.pack`) + Claude Code CLI**, with `claudecode.nvim` as the MCP bridge.

Configs live as plain files in their native locations. No dotfiles repo, no Stow. Treat this README as the install recipe; if a machine needs the same setup, follow the steps below.

## The stack

| Layer | Tool | Notes |
|-------|------|-------|
| Terminal host | Ghostty | Wired for `shift+enter=text:\x1b\r` and `macos-option-as-alt`. Config: `~/.config/ghostty/config`. |
| Multiplexer | tmux 3.4+ | Prefix `Ctrl+Space`. `allow-passthrough on`, `extended-keys on`, `terminal-features 'xterm*:extkeys'`. Config: `~/.tmux.conf`. |
| Editor | Neovim 0.12+ | Built-in `vim.pack` package manager (no lazy.nvim). Config: `~/.config/nvim/init.lua`. |
| Claude bridge | [`coder/claudecode.nvim`](https://github.com/coder/claudecode.nvim) | WebSocket MCP — same protocol as VS Code extension. Selection→context, accept/reject diffs. |
| Terminal provider | [`folke/snacks.nvim`](https://github.com/folke/snacks.nvim) | Required by `claudecode.nvim` for in-editor Claude split. |
| File picker | `fzf-lua` (in nvim) + `yazi` (popup) | `<leader><leader>` files · `<leader>/` grep · `prefix+y` for yazi popup. |
| Git | `lazygit` | Standalone TUI; runs in its own pane. |
| Highlight/diff | `bat` + `git-delta` | |
| tmux plugins (TPM) | `tmux-sensible`, `vim-tmux-navigator`, `tmux-resurrect`, `tmux-continuum`, `tmux-yank`, `tmux-sessionx` | |

## Brew prerequisites

```bash
brew install tmux neovim lazygit fzf fd ripgrep \
             bat git-delta yazi zoxide tree-sitter
```

## Install steps

```bash
# 1. Drop ~/.tmux.conf and ~/.config/nvim/init.lua in place (see reference snippets in this directory).

# 2. Install tmux plugin manager.
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# 3. Start tmux, then press: prefix + I (Ctrl+Space, capital I) to install plugins.

# 4. First nvim launch will auto-fetch vim.pack plugins. Run :checkhealth after.

# 5. Inside nvim: <leader>cc to launch Claude Code in a snacks split.
```

## Keybindings cheat sheet

### tmux (prefix = Ctrl+Space)

| Bind | Action |
|------|--------|
| `prefix + v` / `s` | Vertical / horizontal split |
| `prefix + h/j/k/l` | Pane focus |
| `prefix + C-c` | New window: nvim \| claude / lazygit (pre-built layout) |
| `prefix + y` | Yazi popup |
| `prefix + o` | Sessionx fuzzy session switcher |
| `prefix + I` | Install TPM plugins (after editing `.tmux.conf`) |
| `prefix + C-s` / `C-r` | Resurrect save / restore |
| `Shift+Enter` | Newline in Claude (extkeys passthrough) |

### Neovim (leader = Space)

| Bind | Action |
|------|--------|
| `<leader><leader>` | Find files (fzf-lua) |
| `<leader>/` | Live grep (fzf-lua) |
| `<leader>fb` | Find buffer |
| `gd` / `gr` / `K` | LSP go-to definition / references / hover |
| `<leader>rn` / `<leader>ca` | LSP rename / code action |
| `-` | Open parent directory (oil.nvim) |
| `<leader>cc` | Toggle Claude Code |
| `<leader>cf` | Focus Claude pane |
| `<leader>cs` | Send visual selection to Claude |
| `<leader>cb` | Add current buffer to Claude context |
| `<leader>cy` / `<leader>cn` | Accept / deny Claude's proposed diff |
| `Ctrl+h/j/k/l` | Move between nvim splits AND tmux panes (vim-tmux-navigator) |

## Gotchas

- **Run `/terminal-setup` outside tmux.** It writes host-terminal config (Ghostty), not tmux. Inside tmux it does nothing useful.
- **`escape-time 10`, never `0`.** Zero breaks Claude's TUI render loop.
- **Without `allow-passthrough on`**, Claude's notification bell + progress indicators silently disappear.
- **Without `extended-keys on` + `terminal-features 'xterm*:extkeys'`**, Shift+Enter is interpreted as plain Enter in Claude.
- **Don't remap tmux prefix to `Ctrl+J`** — that's Claude's hard-coded newline.
- **Nested tmux** (SSH-in-tmux-in-tmux) breaks Claude Agent Teams auto-split.
- **`claudecode.nvim` WebSocket binds to localhost.** Over SSH, port-forward if Claude runs remotely and nvim runs locally.

## Why not LazyVim / Helix

- **LazyVim** — solid distro, but Neovim 0.12's built-in `vim.pack` is enough for this use case and avoids a heavy plugin layer.
- **Helix** — beautiful and config-free, but no plugin system, so `claudecode.nvim`'s MCP bridge does not exist for Helix. Claude would only run in an adjacent tmux pane with no editor integration.

## References

- [Claude Code — Configure your terminal](https://code.claude.com/docs/en/terminal-config)
- [`coder/claudecode.nvim`](https://github.com/coder/claudecode.nvim)
- [`tmux-plugins/tpm`](https://github.com/tmux-plugins/tpm)
- [`omerxx/tmux-sessionx`](https://github.com/omerxx/tmux-sessionx)
