# Notes — Obsidian adapter

Obsidian-specific setup for the `notes/` vault contract (`.ai/personal-knowledge-management/README.md`). This adapter owns: required Obsidian plugins, vault settings, the **every-note-is-a-folder-note** rule that activates when Obsidian is in use, terminal/shell-commands wiring, and Obsidian-specific link extensions.

> **Anti-duplication.** This file owns *what's specific to Obsidian*. The vault layout (PARA, frontmatter schema, folder-notes layout convention, capture vocabulary) lives in `.ai/personal-knowledge-management/README.md` — never restated here.

## Why Obsidian

- Backlinks + graph view over the vault's `[[wikilink]]` corpus.
- Inline image rendering for `![[screenshot.png]]` embeds.
- Plugin surface for terminal access and hotkey-bound capture.
- Notion-style folder-as-note UX via the Folder Notes plugin (clicking a folder opens its note).

The vault works without Obsidian — this adapter is opt-in.

## Activation

User-triggered. Phrases:

- "set up Obsidian for my notes", "wire Obsidian to my vault"
- "wire shell-command hotkeys" (when an Obsidian vault is already in use)

The agent reads this file and runs the scaffold below.

## Strong rule: every note is a folder note

When this adapter is active it **overrides** the contract's "flat by default, promote to folder when needed" stance. The contract is permissive because folder notes work in any markdown viewer; the Obsidian adapter is strict because the cost of always-folder is near-zero with the Folder Notes plugin and the payoff is that **attachment paste always lands in the right place**.

### The rule

Every note the agent creates inside an Obsidian-adapter vault is a folder note:

```
notes/inbox/
└── 2026-04-27-bifrost-retry-thoughts/        # the inbox capture
    └── 2026-04-27-bifrost-retry-thoughts.md  # the note itself
```

```
notes/projects/chart-ai/
├── chart-ai.md                # project hub
├── _assets/                   # any attachment dropped while editing chart-ai.md
├── migration-q2/              # sub-investigation — also a folder note
│   ├── migration-q2.md
│   └── _assets/
└── retry-policy-spike/
    ├── retry-policy-spike.md
    └── _assets/
```

```
notes/daily/
└── 2026-04-27/                # daily note is also a folder note
    ├── 2026-04-27.md
    └── _assets/               # screenshots/clippings pasted into today's note
```

### Why

- **Attachment paste is folder-relative.** With Obsidian's `Default location for new attachments → In subfolder under current folder, name _assets`, a paste/drop always lands in the *current note's folder*. If notes are flat, every paste lands in the parent folder, polluting it; if every note is a folder, every paste lands inside that note's own `_assets/`.
- **No promote-to-folder migration step.** There is no "this note grew an attachment, now I have to move it into a folder and update its links" — the structure was always there.
- **Folder Notes plugin makes it transparent.** Clicking the folder opens the note; the file explorer is no more cluttered than before. Auto-create on folder creation means new folders get their note for free.
- **Sub-notes nest naturally.** A spike under a project becomes `projects/<proj>/<spike>/<spike>.md` — no separate filing decision.

### Agent capture vocabulary, Obsidian variant

The contract's capture verbs (`.ai/personal-knowledge-management/README.md` § Agent capture vocabulary) get this scaffold shape when the Obsidian adapter is active:

| User intent | Path created |
|---|---|
| "capture to inbox: <text>" | `notes/inbox/<auto-name>/<auto-name>.md` |
| "log to daily: <text>" | `notes/daily/YYYY-MM-DD/YYYY-MM-DD.md` (folder created if missing) |
| "open today" | Open `notes/daily/YYYY-MM-DD/YYYY-MM-DD.md` |
| "new bug ticket <id>" | `notes/projects/bug-<id>/bug-<id>.md` (already folder-shaped in the contract) |
| "process inbox" → file an item | Move the inbox folder into its target PARA folder, preserving the folder-note structure |

### Filing and renames

- **Renames sync both ways.** Obsidian's Folder Notes plugin keeps the folder name and folder-note name in lockstep when either is renamed. Don't rename one without the other in shell — use Obsidian or the plugin's command.
- **Moving a note moves its folder.** Filing from inbox = `git mv` (or shell `mv`) the *folder*, not the `.md`.
- **Wikilink updates.** Obsidian rewrites `[[wikilink]]` references when notes move via its UI. Shell `mv` does not — prefer Obsidian's "Move file" command, or run `process inbox` and let the agent batch updates.

## Required community plugins

| Plugin | Repo | Plugin ID | Why |
|---|---|---|---|
| Folder Notes | [`LostPaul/obsidian-folder-notes`](https://github.com/LostPaul/obsidian-folder-notes) | `folder-notes` | Implements the every-note-is-a-folder-note UX. The plugin's own folder-note name template is `{{folder_name}}` — same as our convention. |
| Terminal | [`polyipseity/obsidian-terminal`](https://github.com/polyipseity/obsidian-terminal) | `terminal` | Agent CLI inside the vault — primary invocation surface while in Obsidian. |
| Shell commands | [`taitava/obsidian-shellcommands`](https://github.com/Taitava/obsidian-shellcommands) | `shellcommands` | Bind agent actions to hotkeys/palette with note context (`{{selection}}`, `{{file_path}}`, `{{vault_path}}`). |

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
| Files & Links → Default location for new attachments | **In subfolder under current folder**, subfolder name `_assets` | Required for the every-note-is-a-folder-note rule to work — paste lands inside the active note's folder. |
| Files & Links → Use `[[Wikilinks]]` | **On** | Contract's link syntax is wikilink. |
| Files & Links → New link format | **Shortest path when possible** | Cleaner refs across nested folders. |
| Files & Links → Detect all file extensions | **On** | `.json`, `.log`, `.txt`, `.xml` show as linkable in graph. |
| Editor → Show frontmatter | **On** | Frontmatter is load-bearing; should be visible. |

## Folder Notes plugin config (`LostPaul/obsidian-folder-notes`)

These are the settings under Settings → Community plugins → Folder notes that make the every-note-is-a-folder-note rule seamless. Names match the plugin's own labels.

| Setting | Value | Reason |
|---|---|---|
| Folder note name template | `{{folder_name}}` | Matches the contract's `<folder>/<folder>.md` convention. **Default** — leave alone. |
| Storage location | **Inside the folder** | The folder note must live inside the linked folder, not in its parent — keeps `_assets/` a sibling of the note inside that folder. |
| Open folder note in a new tab by default | **Off** (preference) | Avoids tab proliferation; folder note replaces current tab. |
| Confirm folder note deletion | **On** | Prevents accidental loss when deleting a folder. |
| Supported file types | `md` | Plain markdown only — keeps the vault portable. |
| Front matter title plugin integration | **Off** unless the user already runs Front Matter Title | Avoids forcing a second plugin. |
| Auto-create folder note when creating new folder | **On** | New folder = new folder note, automatically. Reinforces the rule. |
| Sync folder name when renaming the folder note | **On** | Renaming the note renames the folder; keeps them in lockstep. |

## Terminal plugin config

- **Shell**: `/bin/zsh -l` — `-l` forces a login shell so `.zshrc` / `.zprofile` source and the agent CLI resolves on PATH.
- **Working directory**: vault root.
- **Why**: Obsidian launches with a minimal env. Without `-l`, your shell's PATH and tooling are not loaded, and the agent CLI fails to resolve.

## Shell commands plugin patterns

The plugin runs shell invocations bound to hotkeys/palette entries. The exact CLI is **agent-specific** — the agent generates the JSON for itself when the user asks ("wire the shell-command hotkeys"). Patterns are coding-agent-agnostic:

| Pattern | Note context | Behavior |
|---|---|---|
| Capture selection to inbox | `{{selection}}` | New folder note under `notes/inbox/<auto-name>/<auto-name>.md` with the selection as body. |
| Append selection to today's daily | `{{selection}}` | Append to today's `notes/daily/YYYY-MM-DD/YYYY-MM-DD.md` (create the daily folder note if missing). |
| Send selection to agent (in-place) | `{{selection}}` | Agent processes selection; output replaces selection or is appended below. |
| Process current note | `{{file_path}}` | Agent reads the file, applies a transform (summarize, file, extract action items). |
| Process inbox | none | Agent runs the inbox-processing flow over inbox folder notes. |

When asked to wire these up, the agent generates the matching JSON for `taitava/obsidian-shellcommands` using its own CLI and the user's preferred hotkeys.

## Obsidian-flavored extensions to the contract's link syntax

The contract (`.ai/personal-knowledge-management/README.md` § Frontmatter schema) uses plain `[[wikilink]]`. Obsidian additionally supports — and the agent may emit when filing into an Obsidian vault:

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
   - `community-plugins.json` — `["folder-notes", "terminal", "shellcommands"]`.
   - `core-plugins.json` — disable Daily Notes, Templates, Templater (they conflict with agent ownership).
3. Convert any pre-existing flat notes in the vault to folder notes (move `note.md` → `note/note.md`). Skip notes already in folder-note shape.
4. Print the manual checklist for the user:
   - Install the three community plugins via Obsidian UI (Restricted mode → off).
   - Configure Terminal plugin: `/bin/zsh -l`, working dir = vault root.
   - Configure Folder Notes plugin per § Folder Notes plugin config — most defaults are correct; verify "Storage location" is **Inside the folder** and "Auto-create folder note when creating new folder" is **On**.
   - Optionally ask the agent to "wire the shell-command hotkeys" for the catalog of patterns.

The agent does not assume the user wants Obsidian opened automatically — it leaves that to the user.

## Anti-patterns (Obsidian-specific)

- **Don't enable Obsidian Sync** — vaults are intentionally per-machine.
- **Don't install Templater / QuickAdd / Periodic Notes** — duplicates agent capture vocabulary, creates a second source of truth.
- **Don't install Smart Connections / Copilot / Text Generator** — runs a parallel LLM bypassing the user's agent.
- **Don't create flat notes in an Obsidian-adapter vault.** Even quick captures get a folder. The plugin auto-creates them; there's no friction reason not to.
- **Don't change the Folder Notes "Storage location" to "Outside the folder".** It breaks the every-note-is-a-folder-note rule by putting the note in the parent — `_assets/` ends up unrelated to the note.

## Cross-references

- `.ai/personal-knowledge-management/README.md` — vault contract (PARA, frontmatter, folder-notes layout, capture vocabulary). This adapter overrides the contract's "flat by default" preference.
- `.ai/personal-knowledge-management/adapters/README.md` — viewer adapter index.
- [LostPaul/obsidian-folder-notes](https://github.com/LostPaul/obsidian-folder-notes) — Folder Notes plugin repo.
- [Folder Notes plugin docs](https://lostpaul.github.io/obsidian-folder-notes/) — settings reference.
- [polyipseity/obsidian-terminal](https://github.com/polyipseity/obsidian-terminal)
- [taitava/obsidian-shellcommands](https://github.com/Taitava/obsidian-shellcommands)
