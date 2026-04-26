# Notes

Framework procedure — read when the user asks to set up, capture into, or organize their personal knowledge vault. Not a skill.

## Why this exists

Engineers accumulate working memory the codebase can't hold: bug investigations with screenshots and logs, meeting notes, references, ideas, journals. Without a system this gets scattered across Slack drafts, sticky notes, and forgotten files. NOVA already has two committed knowledge stores — `.ai/workspace/learnings/` (cross-project agent knowledge) and per-project `AGENTS.md` (project conventions) — but neither is the right home for *personal* working memory. This procedure fills that gap.

## Core principle

**Committed conventions, gitignored content, agent-driven workflow, viewer-agnostic.**

- The conventions in this file are committed; every NOVA workspace gets the same shape.
- The vault itself (`notes/` at workspace root) is gitignored — personal, machine-local.
- The agent owns capture, filing, search, and consolidation. The user asks; the agent acts.
- The vault is plain markdown + YAML frontmatter — readable in any editor. **Viewer choice is opt-in** and lives under `.ai/personal-knowledge-management/adapters/<viewer>/`. See § Viewers below.

This split means workspace push/pull keeps the methodology in sync across machines while content stays per-machine, and switching viewers (or using none) doesn't break the contract.

## Anti-duplication rule

If a rule applies to every NOVA agent, it belongs in root `AGENTS.md`. If it applies to every notes vault, it belongs here. Viewer-specific config (Obsidian plugins, Foam settings, etc.) lives under `.ai/personal-knowledge-management/adapters/<viewer>/` — never in this file. Agent-specific shell-command JSON or CLI invocations live under `.ai/adapters/<agent>/`.

## When to trigger

- "set up notes vault", "scaffold my second brain"
- Any agent capture verb the user uses (see § Agent capture vocabulary): "capture to inbox …", "log to daily …", "process inbox", "what do I know about …"
- "open today", "new bug ticket …"
- Editing under `notes/` at the workspace root

For viewer setup ("set up Obsidian for my notes", "wire shell-command hotkeys"), the agent reads the matching adapter under `.ai/personal-knowledge-management/adapters/<viewer>/`.

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
├── README.md                       # vault entry point — points back at this procedure
├── inbox/                          # quick captures, unprocessed
├── daily/                          # YYYY-MM-DD.md
├── projects/                       # active deadline-bound work
├── areas/                          # ongoing responsibilities
├── resources/                      # topics, references
│   └── templates/                  # reusable note templates
└── archive/                        # done/dormant — moved from above
```

Viewer-specific config directories (e.g. `.obsidian/` for Obsidian) live inside `notes/` but are scaffolded by the matching viewer adapter, not by this procedure.

PARA semantics:

- **Projects** — has a deadline or finish line (bug tickets, feature work, investigations).
- **Areas** — ongoing without an end date (oncall rotation, repo X maintenance).
- **Resources** — topics of interest, references, not actionable.
- **Archive** — moved from any of the above when work is done or dormant.

## Naming

- Notes: kebab-case, descriptive — `bifrost-retry-policy.md`, **not** `2026-04-27-bifrost.md`. Date goes in frontmatter.
- Daily notes: `YYYY-MM-DD.md` in `daily/`.
- Folder notes: see § Folder notes below.

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

`[[wikilink]]` syntax is plain markdown extension — universally supported by Obsidian, Foam, Logseq, and most modern markdown viewers. The contract uses it; viewer adapters may layer extra link forms (`[[note|alias]]`, `![[embed]]`) on top.

Tag conventions:

- `topic/<area>` — kubernetes, llm, observability
- `project/<repo-or-name>` — chart-ai, payment-vip, gym-tracker
- `context/<work|personal>` — keep contexts distinguishable even when vaults are physically separate (defense in depth)

## Folder notes

Any folder may *be* a note. Convention:

```
notes/projects/chart-ai/
├── chart-ai.md                # the folder's own note (frontmatter + body)
├── _assets/                   # attachments
├── migration-q2.md            # sub-notes
└── retry-policy-spike.md
```

The folder-note file is named after its containing folder (`<folder>/<folder>.md`). This is plain markdown — works in any editor. Some viewers (Obsidian's Folder Notes plugin) add a click-to-open UX on top; the file layout itself is universal.

Use folder notes for:

- **Project hubs** — `projects/chart-ai/chart-ai.md` is the project overview, sub-investigations are siblings.
- **Area runbooks** — `areas/oncall/oncall.md` is the running runbook, dated entries below.
- **Topic MOCs** — `resources/llm/llm.md` is the topic map, refs and notes nested under it.
- **Attachment-heavy notes** — `projects/bug-PAY-1234/bug-PAY-1234.md` with screenshots/logs under `_assets/`.

Quick text-only notes stay flat `.md`. Promote to folder when a note grows attachments or sub-notes.

In the note body, reference attachments via:

- `![[error-screenshot.png]]` — image renders inline (in viewers that support embeds).
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

## Viewers

Viewer support is opt-in and isolated under `.ai/personal-knowledge-management/adapters/<viewer>/`, mirroring the per-platform pattern of `.ai/adapters/<coding-agent>/`. The vault itself is plain markdown and works without any viewer.

| Viewer | Adapter | Status |
|--------|---------|--------|
| Obsidian | `.ai/personal-knowledge-management/adapters/obsidian/` | supported |

To set up a viewer the user says "set up Obsidian for my notes" (or the equivalent for another viewer). The agent reads the matching adapter and scaffolds viewer-specific config (e.g. `notes/.obsidian/`). The viewer's installable software (Obsidian itself, plugins) is a one-time manual install per machine.

To use no viewer at all, skip this section. The vault is fully usable with `nvim`, VS Code, `bat`, `grep`, or any markdown tool.

See `.ai/personal-knowledge-management/adapters/README.md` for the index.

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
- **Don't put viewer-specific rules in this file.** They go under `.ai/personal-knowledge-management/adapters/<viewer>/`.

## Scaffold (what the agent does when invoked)

1. Add `notes/` to workspace `.gitignore` if missing.
2. Create the directory tree per § Folder layout.
3. Write `notes/README.md` (vault-internal entry point) with a brief orientation pointing back at this file.
4. Write the three template files under `notes/resources/templates/` per § Templates.
5. Ask the user whether they want a viewer (Obsidian, Foam, etc.) or none. If yes, run the matching adapter's scaffold. If no, stop here.
6. Print a brief "you're done" message including the agent's capture vocabulary so the user knows how to start using it.

## Cross-references

- Root `AGENTS.md` — Framework Procedures table includes a row pointing here.
- `.ai/personal-knowledge-management/adapters/README.md` — viewer adapter index.
- `.ai/workspace/learnings/` — agent-consumed cross-project knowledge (different audience).
- `.ai/adapters/<agent>/` — where agent-specific shell-command JSON belongs if a workspace pre-bakes it (otherwise the agent generates on demand).
