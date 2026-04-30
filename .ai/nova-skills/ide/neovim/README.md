# IDE — Neovim

Procedure — read when the user asks to set up Neovim as a terminal-native IDE wired to Claude Code over MCP. Peer of `.ai/nova-skills/ide/intellij/`.

## What this generates

Nothing inside the workspace. Configs live in the developer's home directory (`~/.config/nvim/init.lua` and friends). This procedure is the install recipe; runtime artifacts are per-developer.

## The stack

| Layer | Tool | Notes |
|-------|------|-------|
| Editor | Neovim 0.12+ | Built-in `vim.pack` package manager (no lazy.nvim). Config: `~/.config/nvim/init.lua`. |
| Claude bridge | [`coder/claudecode.nvim`](https://github.com/coder/claudecode.nvim) | WebSocket MCP — same protocol as the VS Code extension. Selection→context, accept/reject diffs. |
| Terminal provider | [`folke/snacks.nvim`](https://github.com/folke/snacks.nvim) | Required by `claudecode.nvim` for the in-editor Claude split. |
| File picker | `fzf-lua` (in nvim) + `yazi` (popup) | `<leader><leader>` files · `<leader>/` grep. |
| Git | `lazygit` | Standalone TUI; runs in its own pane (or `:LazyGit` if wired). |
| Highlight/diff | `bat` + `git-delta` | |

## Brew prerequisites

```bash
brew install neovim lazygit fzf fd ripgrep \
             bat git-delta yazi zoxide tree-sitter
```

## Install steps

```bash
# 1. Drop ~/.config/nvim/init.lua in place (see reference snippet in this directory).
# 2. First nvim launch will auto-fetch vim.pack plugins.
# 3. Run :checkhealth after first launch.
# 4. Inside nvim: <leader>cc to launch Claude Code in a snacks split.
```

## Keybindings cheat sheet

Leader = Space.

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
| `Ctrl+h/j/k/l` | Move between nvim splits (and tmux panes via vim-tmux-navigator if tmux is layered on top) |

## Gotchas

- **`claudecode.nvim` WebSocket binds to localhost.** Over SSH, port-forward if Claude runs remotely and nvim runs locally.
- **`snacks.nvim` is required**, not optional — `claudecode.nvim` uses it for the editor-split terminal provider. Skipping it breaks `<leader>cc`.

## Why not LazyVim / Helix

- **LazyVim** — solid distro, but Neovim 0.12's built-in `vim.pack` is enough for this use case and avoids a heavy plugin layer.
- **Helix** — beautiful and config-free, but no plugin system, so `claudecode.nvim`'s MCP bridge does not exist for Helix. Claude would only run in an adjacent pane with no editor integration.

## Composes with

- `.ai/nova-skills/terminal/tmux/README.md` — multiplexer layer. Optional. If present, `vim-tmux-navigator` makes `Ctrl+h/j/k/l` cross nvim/tmux pane boundaries.
- `.ai/nova-skills/terminal/SKILL.md` § "Terminal emulator requirements (for Claude Code)" — host-emulator settings (`Shift+Enter`, meta-as-alt). Required regardless of multiplexer.

## References

- [Claude Code — Configure your terminal](https://code.claude.com/docs/en/terminal-config)
- [`coder/claudecode.nvim`](https://github.com/coder/claudecode.nvim)
- [`folke/snacks.nvim`](https://github.com/folke/snacks.nvim)
