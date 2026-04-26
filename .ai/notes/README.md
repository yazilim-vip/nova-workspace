# Notes

Framework procedure — read when the user asks to set up, capture into, or organize their personal knowledge vault. Not a skill.

## Why this exists

Engineers accumulate working memory the codebase can't hold: bug investigations with screenshots and logs, meeting notes, references, ideas, journals. Without a system this gets scattered across Slack drafts, sticky notes, and forgotten files. NOVA already has two committed knowledge stores — `.ai/workspace/learnings/` (cross-project agent knowledge) and per-project `AGENTS.md` (project conventions) — but neither is the right home for *personal* working memory. This procedure fills that gap.

## Core principle

**Committed conventions, gitignored content, agent-driven workflow.**

- The conventions in this file are committed; every NOVA workspace gets the same shape.
- The vault itself (`notes/` at workspace root) is gitignored — personal, machine-local.
- The agent owns capture, filing, search, and consolidation. The user asks; the agent acts.
- Obsidian is the human-facing surface for browse, `[[wikilink]]` navigation, backlinks, graph view, and attachment paste. It is not the workflow driver — the agent is.

This split means workspace push/pull keeps the methodology in sync across machines while content stays per-machine.

## Anti-duplication rule

If a rule applies to every NOVA agent, it belongs in root `AGENTS.md`. If it applies to every notes vault, it belongs here. Agent-specific shell-command JSON or CLI invocations live under `.ai/adapters/<agent>/` — never in this file.

## When to trigger

- "set up notes vault", "scaffold my second brain"
- Any agent capture verb the user uses (see § Agent capture vocabulary): "capture to inbox …", "log to daily …", "process inbox", "what do I know about …"
- "open today", "new bug ticket …"
- Editing under `notes/` at the workspace root
- "wire shell-command hotkeys for notes"

## Distinct from other knowledge stores

| Store | Audience | Content |
|---|---|---|
| `notes/` (this) | The user — agent acts on their behalf | Personal second brain: investigations, meeting notes, ideas, references, journal |
| `.ai/workspace/learnings/` | The agent — cross-project reuse | Workspace-wide infra knowledge agents apply automatically |
| Per-project `AGENTS.md` | The agent — project scope | Project conventions, architecture, gotchas |

If a piece of knowledge is reusable agent context, it does not belong in `notes/` — it belongs in `learnings/` or a project's `AGENTS.md`.

## Vault location

- Path: `notes/` at workspace root, gitignored.
- One vault per machine. No sync — each machine's vault is independent.
- Launch the agent from workspace root or from inside `notes/`. Both sit inside the workspace's git repo, so the workspace's adapter chain auto-loads.

## Folder layout

```
notes/
├── .obsidian/                      # vault config (gitignored, but lives in vault)
├── README.md                       # vault entry point — points back at this procedure
├── inbox/                          # quick captures, unprocessed
├── daily/                          # YYYY-MM-DD.md
├── projects/                       # active deadline-bound work
├── areas/                          # ongoing responsibilities
├── resources/                      # topics, references
│   └── templates/                  # reusable note templates
├── archive/                        # done/dormant — moved from above
└── maps/                           # MOCs (Maps of Content) — curated index notes
```

PARA semantics:

- **Projects** — has a deadline or finish line (bug tickets, feature work, investigations).
- **Areas** — ongoing without an end date (oncall rotation, repo X maintenance).
- **Resources** — topics of interest, references, not actionable.
- **Archive** — moved from any of the above when work is done or dormant.

## Naming

- Notes: kebab-case, descriptive — `bifrost-retry-policy.md`, **not** `2026-04-27-bifrost.md`. Date goes in frontmatter.
- Daily notes: `YYYY-MM-DD.md` in `daily/`.
- Attachment-heavy notes: promote to a folder named after the note. Folder contains the note as `<folder-name>.md` and attachments under `_assets/`.

## Frontmatter schema

The agent enforces this schema when filing notes from inbox or scaffolding from templates.

```yaml
---
type: note | daily | bug-ticket | meeting | reference | moc
status: open | active | done | archived       # optional, mostly for projects
created: YYYY-MM-DD
updated: YYYY-MM-DD                            # optional, agent maintains
tags: [topic/x, project/y, context/work]
links: ["[[other-note]]"]                      # optional, agent maintains
---
```

Tag conventions:

- `topic/<area>` — kubernetes, llm, observability
- `project/<repo-or-name>` — chart-ai, payment-vip, gym-tracker
- `context/<work|personal>` — keep contexts distinguishable even when vaults are physically separate (defense in depth)

## Promote-to-folder pattern (attachments)

Quick text-only notes stay flat `.md`. Anything with attachments — bug tickets, design docs, meeting notes with diagrams — gets promoted:

```
notes/projects/
├── chart-ai-migration.md            # flat — no attachments
└── bug-PAY-1234/                    # folder — has attachments
    ├── bug-PAY-1234.md              # the note (frontmatter + body)
    └── _assets/
        ├── error-screenshot.png
        ├── failed-request.json
        └── server.log
```

In the note body, reference attachments via:

- `![[error-screenshot.png]]` — image renders inline.
- `[[failed-request.json]]` — link, opens externally.

## Agent capture vocabulary

The agent recognizes the following intents from the user. Phrasing is flexible; intent is fixed. The agent's actual CLI invocation is platform-specific — this file documents the **behavior contract**, not commands.

| User intent | Agent behavior |
|---|---|
| "capture to inbox: <text>" | Create `notes/inbox/<auto-name>.md` with text + minimal frontmatter (`type: note`, today's `created`). |
| "log to daily: <text>" | Append `<text>` to today's `notes/daily/YYYY-MM-DD.md`. Create the file if missing. |
| "open today" | Open today's daily note (create if missing). |
| "process inbox" | Read all `notes/inbox/*.md`. For each, propose target folder (PARA), tags, and links to existing notes. Execute filing on confirmation. Merge near-duplicates rather than just moving them. |
| "what do I know about <topic>" | Search vault (frontmatter, body, links). Surface relevant note paths with a short summary. |
| "new bug ticket <id>" | Scaffold `notes/projects/bug-<id>/` from the bug-ticket template, ready for attachment paste. |
| "summarize <file or selection>" | Distill content into a note or appendable section in the active note. |

The agent **never silently overwrites** existing notes — edits with a visible diff or appends.

## Obsidian setup

### Required community plugins

| Plugin | Repo | Why |
|---|---|---|
| Terminal | `polyipseity/obsidian-terminal` | Agent CLI inside the vault — primary invocation surface while in Obsidian. |
| Shell commands | `taitava/obsidian-shellcommands` | Bind agent actions to hotkeys/palette with note context (`{{selection}}`, `{{file_path}}`, `{{vault_path}}`) as variables. |

Enable: Settings → Community plugins → turn off Restricted mode → install + enable both. Obsidian does not script community-plugin installs; this is a one-time manual step per machine.

### Skip these (agent-driven, not user-driven)

The plugin ecosystem is built around manual workflows the agent now handles. Avoid:

- **Daily Notes core plugin, Templater, QuickAdd, Periodic Notes, Tasks** — automation belongs to the agent. Manual templating tools add friction without value and create a second source of truth.
- **Copilot for Obsidian, Text Generator, Smart Connections** — these bypass the user's agent with direct LLM API calls. The point is to keep one agent driving, not run a parallel one.
- **Obsidian Sync** — vaults are intentionally per-machine.

### Vault settings

Pre-written into `notes/.obsidian/app.json` during scaffold; user can adjust later via Obsidian UI.

| Setting path | Value | Reason |
|---|---|---|
| Files & Links → Default location for new attachments | **In subfolder under current folder**, name `_assets` | Promote-to-folder pattern works automatically on paste/drop. |
| Files & Links → Use `[[Wikilinks]]` | **On** | Agent uses wikilinks; consistent linkage. |
| Files & Links → New link format | **Shortest path when possible** | Cleaner refs across nested folders. |
| Files & Links → Detect all file extensions | **On** | `.json`, `.log`, `.txt`, `.xml` show as linkable in graph. |
| Editor → Show frontmatter | **On** | Frontmatter is load-bearing; should be visible. |

### Terminal plugin config

- **Shell**: `/bin/zsh -l` — `-l` forces a login shell so `.zshrc` / `.zprofile` source and the agent CLI resolves on PATH.
- **Working directory**: vault root.
- **Why**: Obsidian launches with a minimal env. Without `-l`, your shell's PATH and tooling are not loaded, and the agent CLI fails to resolve.

### Shell commands plugin patterns

The plugin runs shell invocations bound to hotkeys/palette entries. The exact CLI is **agent-specific** — the agent generates the JSON for itself when the user asks ("wire the shell-command hotkeys"). Patterns are platform-agnostic:

| Pattern | Note context | Behavior |
|---|---|---|
| Capture selection to inbox | `{{selection}}` | New `notes/inbox/...` file with the selection as body. |
| Append selection to today's daily | `{{selection}}` | Append to `notes/daily/YYYY-MM-DD.md`. |
| Send selection to agent (in-place) | `{{selection}}` | Agent processes selection; output replaces selection or is appended below. |
| Process current note | `{{file_path}}` | Agent reads the file, applies a transform (summarize, file, extract action items). |
| Process inbox | none | Agent runs the inbox-processing flow. |

When asked to wire these up, the agent generates the matching JSON for `taitava/obsidian-shellcommands` using its own CLI and the user's preferred hotkeys.

## Templates

Stored under `notes/resources/templates/`. The agent uses these when scaffolding new notes.

- `bug-ticket.md` — investigation skeleton (context, reproduction, attachments, investigation log, resolution).
- `meeting.md` — attendees, agenda, decisions, action items.
- `daily.md` — daily note skeleton (optional — agent appends free-form to a bare file otherwise).

Concrete template bodies are written by the scaffold step and live in the vault, not in this procedure file.

## Anti-patterns

- **Don't paraphrase NOVA framework rules in notes.** Reference paths (`AGENTS.md`, `.ai/...`); never copy.
- **Don't store cross-project agent knowledge here.** That belongs in `.ai/workspace/learnings/` or a project's `AGENTS.md`.
- **Don't manually create note files for capture.** Use the agent capture vocabulary so frontmatter and naming stay consistent.
- **Don't commit `notes/`.** Gitignored for a reason — personal, machine-local.
- **Don't rely on Obsidian QoL plugins** (Daily Notes, Templater, Tasks) — those are agent responsibilities; using both creates two sources of truth.

## Scaffold (what the agent does when invoked)

1. Add `notes/` to workspace `.gitignore` if missing (preserve structure pattern: line near `scripts/`).
2. Create the directory tree per § Folder layout.
3. Write `notes/README.md` (vault-internal entry point) with a brief orientation pointing back at this file.
4. Write the three template files under `notes/resources/templates/` per § Templates.
5. Write `notes/.obsidian/app.json`, `core-plugins.json`, and `community-plugins.json` with the settings in § Obsidian setup. (Plugin code itself must be installed by the user via Obsidian UI; the JSON list is a reference.)
6. Print the manual checklist for the user:
   - Install community plugins (Terminal, Shell commands) via Obsidian UI.
   - Configure Terminal plugin: `/bin/zsh -l`, working dir = vault root.
   - Optionally ask the agent to "wire the shell-command hotkeys" for the catalog of patterns.

The agent does not assume the user wants Obsidian opened automatically — it leaves that to the user.

## Cross-references

- Root `AGENTS.md` — Framework Procedures table includes a row pointing here.
- `.ai/workspace/learnings/` — agent-consumed cross-project knowledge (different audience).
- `.ai/adapters/<agent>/` — where agent-specific shell-command JSON belongs if a workspace pre-bakes it (otherwise the agent generates on demand).
