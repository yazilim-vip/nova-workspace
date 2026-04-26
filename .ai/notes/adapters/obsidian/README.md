# Notes — Obsidian adapter

Obsidian-specific setup for the `notes/` vault contract (`.ai/notes/README.md`). This adapter owns: required Obsidian plugins, vault settings, terminal/shell-commands wiring, and the click-to-open Folder Notes UX.

> **Anti-duplication.** This file owns *what's specific to Obsidian*. The vault layout (PARA, frontmatter schema, folder-notes convention, capture vocabulary) lives in `.ai/notes/README.md` — never restated here.

## Why Obsidian

- Backlinks + graph view over the vault's `[[wikilink]]` corpus.
- Inline image rendering for `![[screenshot.png]]` embeds.
- Plugin surface for terminal access and hotkey-bound capture.
- Click-to-open behavior for the contract's folder-notes layout (via the Folder Notes plugin).

The vault works without Obsidian — this adapter is opt-in.

## Activation

User-triggered. Phrases:

- "set up Obsidian for my notes", "wire Obsidian to my vault"
- "wire shell-command hotkeys" (when an Obsidian vault is already in use)

The agent reads this file and runs the scaffold below.

## Required community plugins

| Plugin | Repo | Why |
|---|---|---|
| Terminal | `polyipseity/obsidian-terminal` | Agent CLI inside the vault — primary invocation surface while in Obsidian. |
| Shell commands | `taitava/obsidian-shellcommands` | Bind agent actions to hotkeys/palette with note context (`{{selection}}`, `{{file_path}}`, `{{vault_path}}`) as variables. |
| Folder Notes | `xpgo/obsidian-folder-note-plugin` | Implements click-to-open for the contract's folder-notes convention (`<folder>/<folder>.md`). Without it the layout still works, you just don't get the click affordance. |

Enable: Settings → Community plugins → turn off Restricted mode → install + enable. Obsidian does not script community-plugin installs; this is a one-time manual step per machine.

## Skip these (agent-driven, not user-driven)

The plugin ecosystem is built around manual workflows the agent now handles. Avoid:

- **Daily Notes core plugin, Templater, QuickAdd, Periodic Notes, Tasks** — automation belongs to the agent. Manual templating tools add friction without value and create a second source of truth.
- **Copilot for Obsidian, Text Generator, Smart Connections** — these bypass the user's agent with direct LLM API calls. The point is to keep one agent driving, not run a parallel one.
- **Obsidian Sync** — vaults are intentionally per-machine.

## Vault settings

Pre-written into `notes/.obsidian/app.json` during scaffold; user can adjust later via Obsidian UI.

| Setting path | Value | Reason |
|---|---|---|
| Files & Links → Default location for new attachments | **In subfolder under current folder**, name `_assets` | Folder-notes pattern works automatically on paste/drop. |
| Files & Links → Use `[[Wikilinks]]` | **On** | Agent uses wikilinks; consistent linkage. |
| Files & Links → New link format | **Shortest path when possible** | Cleaner refs across nested folders. |
| Files & Links → Detect all file extensions | **On** | `.json`, `.log`, `.txt`, `.xml` show as linkable in graph. |
| Editor → Show frontmatter | **On** | Frontmatter is load-bearing; should be visible. |

## Folder Notes plugin config

| Setting path | Value | Reason |
|---|---|---|
| Folder note name | `{{folder_name}}` | Matches the contract's `<folder>/<folder>.md` convention. |
| Hide folder note in file explorer | **On** (preference) | Click the folder, the note opens; no duplicate entry. |
| Open folder note on folder click | **On** | The whole point of the plugin. |

## Terminal plugin config

- **Shell**: `/bin/zsh -l` — `-l` forces a login shell so `.zshrc` / `.zprofile` source and the agent CLI resolves on PATH.
- **Working directory**: vault root.
- **Why**: Obsidian launches with a minimal env. Without `-l`, your shell's PATH and tooling are not loaded, and the agent CLI fails to resolve.

## Shell commands plugin patterns

The plugin runs shell invocations bound to hotkeys/palette entries. The exact CLI is **agent-specific** — the agent generates the JSON for itself when the user asks ("wire the shell-command hotkeys"). Patterns are coding-agent-agnostic:

| Pattern | Note context | Behavior |
|---|---|---|
| Capture selection to inbox | `{{selection}}` | New `notes/inbox/...` file with the selection as body. |
| Append selection to today's daily | `{{selection}}` | Append to `notes/daily/YYYY-MM-DD.md`. |
| Send selection to agent (in-place) | `{{selection}}` | Agent processes selection; output replaces selection or is appended below. |
| Process current note | `{{file_path}}` | Agent reads the file, applies a transform (summarize, file, extract action items). |
| Process inbox | none | Agent runs the inbox-processing flow. |

When asked to wire these up, the agent generates the matching JSON for `taitava/obsidian-shellcommands` using its own CLI and the user's preferred hotkeys.

## Obsidian-flavored extensions to the contract's link syntax

The contract (`.ai/notes/README.md` § Frontmatter schema) uses plain `[[wikilink]]`. Obsidian additionally supports — and the agent may emit when filing into an Obsidian vault:

- `[[note|alias]]` — display alias for the link.
- `![[note]]` — transclude/embed another note inline.
- `![[image.png]]` — render image inline.
- `[[note#heading]]` — link to a heading.
- `[[note#^block-id]]` — link to a block.

These are still markdown — degrade gracefully in viewers that don't render them.

## Scaffold (what the agent does for this adapter)

1. Verify `notes/` exists per the contract's scaffold (run that first if not).
2. Create `notes/.obsidian/` with:
   - `app.json` — vault settings table above.
   - `community-plugins.json` — `["polyipseity-obsidian-terminal", "shellcommands", "obsidian-folder-note-plugin"]`.
   - `core-plugins.json` — disable Daily Notes, Templates, Templater (they conflict with agent ownership).
3. Print the manual checklist for the user:
   - Install the three community plugins via Obsidian UI (Restricted mode → off).
   - Configure Terminal plugin: `/bin/zsh -l`, working dir = vault root.
   - Configure Folder Notes plugin per § Folder Notes plugin config.
   - Optionally ask the agent to "wire the shell-command hotkeys" for the catalog of patterns.

The agent does not assume the user wants Obsidian opened automatically — it leaves that to the user.

## Anti-patterns (Obsidian-specific)

- **Don't enable Obsidian Sync** — vaults are intentionally per-machine.
- **Don't install Templater / QuickAdd / Periodic Notes** — duplicates agent capture vocabulary, creates a second source of truth.
- **Don't install Smart Connections / Copilot / Text Generator** — runs a parallel LLM bypassing the user's agent.

## Cross-references

- `.ai/notes/README.md` — vault contract (PARA, frontmatter, folder notes, capture vocabulary). This adapter implements its viewer-specific surface.
- `.ai/notes/adapters/README.md` — viewer adapter index.
- [Obsidian Folder Notes plugin (xpgo)](https://github.com/xpgo/obsidian-folder-note-plugin)
- [polyipseity/obsidian-terminal](https://github.com/polyipseity/obsidian-terminal)
- [taitava/obsidian-shellcommands](https://github.com/Taitava/obsidian-shellcommands)
