# IDE

Framework procedure — read when the user asks to set up an IDE's project config (generate `.idea/` modules, register cloned repos as IDE modules, create run configurations). Not a skill.

## Why this exists

Each IDE carries its own project-config format — IntelliJ's `.idea/`, VS Code's `.code-workspace`, etc. Mapping a NOVA workspace (the `git-repositories/` tree + `.ai/workspace/map/repos.md`) into that format is deterministic but tedious. This procedure owns the mapping, one subdirectory per IDE.

## Core principle

**Committed procedure, per-dev artifacts** — same model as `.ai/adapters/`:

- The procedure docs + templates live under `.ai/ide/<platform>/` — tracked, team-shared.
- The generated output (`.idea/`, `.vscode/`, etc.) is gitignored and per-developer — regenerable anytime from the committed templates.

Templates describe the intended shape. The running agent fills placeholders by scanning `git-repositories/` and enriching from `repos.md`.

## Anti-duplication rule

If a rule applies to every NOVA agent, it belongs in `AGENTS.md`. If it applies to every IDE procedure, it belongs here. IDE-specific rules live in that IDE's subdirectory — never copied up.

## Supported platforms

| Platform | Subdirectory | Output | What it generates |
|----------|-------------|--------|-------------------|
| IntelliJ IDEA | `.ai/ide/intellij/` | `.idea/` at workspace root | `modules.xml`, `.iml` per repo, `vcs.xml`, `misc.xml`, `encodings.xml`, `runConfigurations/` |
| Neovim | `.ai/ide/neovim/` | _(none — configs live in `~/.config/nvim/`)_ | Install recipe for `vim.pack` + `claudecode.nvim` + `snacks.nvim` + fzf-lua/yazi/lazygit. Composes with `.ai/terminal/tmux/`. |

More platforms get added to the table as they're supported.

## When to trigger

- "set up intellij", "generate idea config", "create intellij modules for my repos"
- "add <repo> as an intellij module", "register my repos in intellij"
- "create a run configuration for <module>", "add a spring boot run config for chart-ai"
- "set up neovim", "set up nvim with claude", "integrate claudecode.nvim", "set up my editor"
- User opens the workspace in IntelliJ and asks why the repos aren't showing in the Project tool window

## Procedure entry points

Each platform subdir has its own `README.md` describing the flow, templates, and safety rules. Read the one for the IDE you're targeting.
