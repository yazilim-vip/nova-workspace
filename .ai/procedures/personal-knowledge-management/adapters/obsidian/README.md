# Notes — Obsidian adapter

Obsidian-specific setup for the `notes/` vault contract (`.ai/procedures/personal-knowledge-management/PROCEDURE.md`). This adapter owns: required Obsidian plugins, vault settings, the **every-note-is-a-folder-note** rule that activates when Obsidian is in use, in-Obsidian terminal wiring, and Obsidian-specific link extensions.

> **Anti-duplication.** This file owns *what's specific to Obsidian*. The vault layout (PARA, frontmatter schema, folder-notes layout convention, capture vocabulary) lives in `.ai/procedures/personal-knowledge-management/PROCEDURE.md` — never restated here.

## Why Obsidian

- Backlinks + graph view over the vault's `[[wikilink]]` corpus.
- Inline image rendering for `![[screenshot.png]]` embeds.
- Plugin surface for terminal access and hotkey-bound capture.
- Notion-style folder-as-note UX via the Folder Notes plugin (clicking a folder opens its note).

The vault works without Obsidian — this adapter is opt-in.

## Activation

User-triggered. Phrases:

- "set up Obsidian for my notes", "wire Obsidian to my vault"

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

The contract's capture verbs (`.ai/procedures/personal-knowledge-management/PROCEDURE.md` § Agent capture vocabulary) get this scaffold shape when the Obsidian adapter is active:

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

You install these manually, once per machine — Obsidian does not script community-plugin installs.

### One-time prep

1. Open Obsidian with the `notes/` vault.
2. Settings → Community plugins → click **Turn on community plugins** (this disables Restricted mode for this vault).

### Install each plugin

For each plugin in the table below: Settings → Community plugins → **Browse** → search the **exact display name** → click the matching tile (verify **author** matches) → **Install** → **Enable**.

The fastest path is the deeplink — clicking it from any browser opens the plugin's listing inside your active Obsidian vault, ready to install:

| # | Plugin (display name) | Author (as shown in Obsidian) | Plugin id | Deeplink | Why we need it |
|---|---|---|---|---|---|
| 1 | **Folder notes** | **Lost Paul** | `folder-notes` | [obsidian://show-plugin?id=folder-notes](obsidian://show-plugin?id=folder-notes) | Implements the every-note-is-a-folder-note UX. Default folder-note name template `{{folder_name}}` matches our `<folder>/<folder>.md` convention. |
| 2 | **Terminal** | **polyipseity** | `terminal` | [obsidian://show-plugin?id=terminal](obsidian://show-plugin?id=terminal) | Agent CLI inside the vault — invocation surface while working in Obsidian. Open a terminal pane (ribbon icon or command palette) and run agent commands directly. |

### Disambiguation — Folder notes search returns multiple results

Searching "folder notes" in Obsidian's Community plugins browser returns **three** plugins. Install only the **first** one in this list; the others are older or related:

| Tile you'll see | Author | Action |
|---|---|---|
| **Folder notes** | Lost Paul | ✅ **Install this one.** |
| Folder Note Plugin | xpgo | ❌ Skip. Older plugin; we previously referenced this and migrated. |
| Alx Folder Note | aidenlx | ❌ Skip. Different lineage; requires the `folder-note-core` plugin. |

### Verify each installed correctly

After install + enable, the plugin appears under Settings → Community plugins → **Installed plugins** with a toggle that's switched **on**. The Folder notes plugin also adds a "Folder notes" entry to the settings sidebar. Terminal adds a ribbon icon (the terminal glyph) and a `terminal` command to the command palette.

If a plugin appears installed but disabled, toggle it on. If it doesn't appear at all, the install failed — try **Browse → search → Install** again.

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

Settings → Community plugins → Terminal:

- **Shell**: `/bin/zsh -l` — `-l` forces a login shell so `.zshrc` / `.zprofile` source and the agent CLI resolves on PATH.
- **Working directory**: vault root.
- **Why**: Obsidian launches with a minimal env. Without `-l`, your shell's PATH and tooling are not loaded, and the agent CLI fails to resolve.

Invoke the agent by opening a Terminal pane (ribbon icon, or command palette → "Terminal: Open in panel") and typing the agent CLI directly. Capture verbs (`capture to inbox`, `log to daily`, `process inbox`, etc.) are passed in as agent input — see contract § Agent capture vocabulary.

## Obsidian-flavored extensions to the contract's link syntax

The contract (`.ai/procedures/personal-knowledge-management/PROCEDURE.md` § Frontmatter schema) uses plain `[[wikilink]]`. Obsidian additionally supports — and the agent may emit when filing into an Obsidian vault:

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
   - `community-plugins.json` — `["folder-notes", "terminal"]`.
   - `core-plugins.json` — disable Daily Notes, Templates, Templater (they conflict with agent ownership).
3. Convert any pre-existing flat notes in the vault to folder notes (move `note.md` → `note/note.md`). Skip notes already in folder-note shape.
4. Print the manual checklist for the user (per § Required community plugins):
   - Install **Folder notes** (Lost Paul) and **Terminal** (polyipseity) via the deeplinks in the table.
   - Configure Terminal plugin: `/bin/zsh -l`, working dir = vault root.
   - Configure Folder notes plugin per § Folder Notes plugin config — most defaults are correct; verify "Storage location" is **Inside the folder** and "Auto-create folder note when creating new folder" is **On**.

The agent does not assume the user wants Obsidian opened automatically — it leaves that to the user.

## Anti-patterns (Obsidian-specific)

- **Don't enable Obsidian Sync** — vaults are intentionally per-machine.
- **Don't install Templater / QuickAdd / Periodic Notes** — duplicates agent capture vocabulary, creates a second source of truth.
- **Don't install Smart Connections / Copilot / Text Generator** — runs a parallel LLM bypassing the user's agent.
- **Don't create flat notes in an Obsidian-adapter vault.** Even quick captures get a folder. The plugin auto-creates them; there's no friction reason not to.
- **Don't change the Folder Notes "Storage location" to "Outside the folder".** It breaks the every-note-is-a-folder-note rule by putting the note in the parent — `_assets/` ends up unrelated to the note.

## Cross-references

- `.ai/procedures/personal-knowledge-management/PROCEDURE.md` — vault contract (PARA, frontmatter, folder-notes layout, capture vocabulary). This adapter overrides the contract's "flat by default" preference.
- `.ai/procedures/personal-knowledge-management/adapters/README.md` — viewer adapter index.
- [LostPaul/obsidian-folder-notes](https://github.com/LostPaul/obsidian-folder-notes) — Folder Notes plugin repo.
- [Folder Notes plugin docs](https://lostpaul.github.io/obsidian-folder-notes/) — settings reference.
- [polyipseity/obsidian-terminal](https://github.com/polyipseity/obsidian-terminal) — Terminal plugin repo.
