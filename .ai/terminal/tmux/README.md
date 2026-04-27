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

**`Alt+<arrow>` and a few `Alt+<letter>` keys are the safe space.** Shell and Claude don't claim them; vim uses Alt rarely. The prerequisite is host-emulator "meta-as-alt" — already required by `.ai/terminal/SKILL.md`, so you're already paying that cost.

**macOS caveat.** On Mac, Option+letter has a built-in "type a special character" mapping (Option+H = `˙`, Option+V = `√`, Option+1 = `¡`, etc.). With meta-as-alt set in your terminal emulator, the modifier is intercepted before the character mapping fires — so the bindings work — *but* the letter combos still feel surprising if meta-as-alt isn't bulletproof. **Arrow-key bindings have no Option-character mapping at all**, which is why we use them for window navigation. The letter bindings below (`v/s/n/x/z`) are kept because their character mappings are rarely typed.

This section is **opt-in** — add only if you want it. Bindings live alongside (not instead of) the prefix bindings, so muscle memory for either keeps working.

| Bind | Action |
|------|--------|
| `Ctrl+h/j/k/l` | Pane focus across nvim/tmux boundaries (via `vim-tmux-navigator`) |
| `Alt+i/j/k/l` | Pane focus (tmux-only inverted-T: up / left / down / right) |
| `Alt+Left` / `Alt+Right` | Previous / next window |
| `Alt+1`…`Alt+9` | Jump to window N |
| `Alt+v` | Vertical split |
| `Alt+s` | Horizontal split |
| `Alt+n` | New window |
| `Alt+x` | Close pane (with confirm) |
| `Alt+z` | Toggle zoom |

Add to `~/.tmux.conf`:

```tmux
# One-shot (no-prefix) bindings — opt-in. Requires host-emulator meta-as-alt.
# Pane focus (inverted-T, tmux-only — Ctrl+h/j/k/l still crosses nvim via vim-tmux-navigator)
bind-key -n M-i select-pane -U
bind-key -n M-j select-pane -L
bind-key -n M-k select-pane -D
bind-key -n M-l select-pane -R
# Window navigation
bind-key -n M-Left  previous-window
bind-key -n M-Right next-window
bind-key -n M-1 select-window -t 1
bind-key -n M-2 select-window -t 2
bind-key -n M-3 select-window -t 3
bind-key -n M-4 select-window -t 4
bind-key -n M-5 select-window -t 5
bind-key -n M-6 select-window -t 6
bind-key -n M-7 select-window -t 7
bind-key -n M-8 select-window -t 8
bind-key -n M-9 select-window -t 9
# Pane management
bind-key -n M-v split-window -h -c "#{pane_current_path}"
bind-key -n M-s split-window -v -c "#{pane_current_path}"
bind-key -n M-n new-window -c "#{pane_current_path}"
bind-key -n M-x confirm-before -p "kill pane? (y/n)" kill-pane
bind-key -n M-z resize-pane -Z
```

**Why these picks:**
- `Alt+i/j/k/l` as an inverted-T for pane focus — independent of vim-tmux-navigator (which uses Ctrl). Use either set; they coexist. ijkl is the gamer-style layout (i=up, j=left, k=down, l=right), so it doesn't compete with the vim h/j/k/l muscle memory you already have on Ctrl.
- `Alt+Left`/`Alt+Right` for window switching — arrow keys have no Option-character mapping on macOS, so they work whether meta-as-alt is reliable or shaky.
- `Alt+v`/`Alt+s` mirror vim split commands and the existing `prefix + v/s` muscle memory.
- `Alt+1`…`Alt+9` matches the convention many tiling WMs and modern terminals use; works on Mac with meta-as-alt set.
- `Alt+x` is gated behind a confirm prompt because pane kill is destructive.

**Caveat for `Alt+j` / `Alt+k`:** some nvim configs (and VS Code) bind these to "move line up/down." If yours does, the tmux binding wins inside the terminal and you'll need to unbind the editor side or pick a different combo. `Alt+i` / `Alt+l` are generally free.

**Skip-list (don't bind these without research):**
- `Alt+h` — Option+H is intercepted in some Mac stacks (window managers, hide-app shortcuts). Use `Alt+j` for pane left instead.
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
