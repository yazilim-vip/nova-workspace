# Personal-knowledge-management — agent doctrine (shared)

Always-on agent rules for recognizing PKM (notes vault) intent and routing it through the contract. Loaded by every NOVA agent adapter — Claude (`@`-imported), Kiro (`#[[file:...]]`), and any future adapter — so behavior stays consistent across hosts.

> **Anti-duplication.** This file owns *how the agent recognizes and routes PKM intent*. Vault layout, frontmatter, capture-verb behavior, and viewer-specific rules live in `.ai/procedures/personal-knowledge-management/` — never restated here.

## Why this is always-on

The user types **"set up notes vault"** *before* any vault or declaration exists. The agent must recognize the trigger from a cold session, so PKM doctrine cannot be gated on a vault-presence flag. The doctrine is small enough that always-on costs nothing.

## Trigger recognition

The agent **must** recognize the following as PKM intent and act per § Required first action below. Phrasing is flexible; intent is fixed.

| User input shape | Intent |
|---|---|
| "set up notes vault", "scaffold my second brain", "set up Obsidian for my notes" | PKM setup |
| "capture to inbox …", "log to daily …", "open today", "process inbox" | PKM capture/triage |
| "what do I know about …", "search my notes for …" | PKM search |
| "new bug ticket …", "scaffold a meeting note", "summarize this into a note" | PKM scaffold |
| Any edit invocation where the target path starts with `notes/` (workspace root) | PKM edit |

These are the only triggers that route work through the PKM contract. Do not file content into `notes/` for any other reason — see § Safety guards below.

## Required first action on any PKM trigger

Before taking any other action:

1. **Read the contract:** `.ai/procedures/personal-knowledge-management/PROCEDURE.md`. It owns vault layout (PARA), naming, frontmatter schema, folder-notes layout, capture vocabulary behaviors. Do not infer these — read them.
2. **Detect viewer:** check whether `notes/.obsidian/` exists at the workspace root (`Bash` `test -d notes/.obsidian` or equivalent). If yes, also read `.ai/procedures/personal-knowledge-management/adapters/obsidian/README.md` — its **strong rule "every note is a folder note"** overrides the contract's flat-by-default preference.
3. **Detect vault presence:** if the trigger is a capture/scaffold verb but `notes/` does not exist yet, do **not** start writing — surface this to the user and offer to scaffold per the contract first.
4. **Check workspace AGENTS.md:** workspace overrides may add or restrict viewers; respect declared viewers.

The first action is always *read first, write second*. Cold sessions especially.

## Path discipline

| Surface | Allowed actions |
|---|---|
| `notes/` at workspace root | Read, Edit, Write — but **only** when invoked by a PKM trigger above. |
| `.ai/procedures/personal-knowledge-management/` | Read for context. Edit only when the user asks to evolve the contract or an adapter — that's a framework change, not PKM use. |
| Anywhere else | **Never** write personal-vault-style content (daily logs, inbox captures, bug tickets, meeting notes) outside `notes/`. If the user wants notes attached to a code repo, that's a different category — point them at that repo's docs/issues, not the PKM vault. |

## Safety guards (non-negotiable)

- **`notes/` is gitignored.** Never include it in `git add`, `git commit`, or PR diffs. If a tool surfaces a `notes/` path in a diff, it's a bug — flag it.
- **Never proactively create or edit notes.** The vault is the user's working memory. Acting without an explicit PKM trigger is intrusion. Reading is fine; writing requires an invitation.
- **Never silently overwrite an existing note.** Per contract § Agent capture vocabulary, edits show a visible diff or append; full overwrite requires confirmation.
- **Never sync the vault.** Per the Obsidian adapter, vaults are intentionally per-machine. Don't propose Obsidian Sync, rsync to a remote, or any other replication mechanism.
- **Don't paraphrase NOVA rules into notes.** The vault is for personal working memory, not framework documentation. If the user is taking notes about NOVA, reference paths (`.ai/...`) instead of copying rule text.

## Routing summary (one-liner per trigger class)

| Trigger | Read | Then |
|---|---|---|
| Setup ("set up notes vault") | contract + matching viewer adapter (if user named one) | Run the contract's § Scaffold + viewer adapter's § Scaffold (in that order) |
| Capture ("capture to inbox") | contract (+ Obsidian adapter if `notes/.obsidian/` exists) | File per contract § Agent capture vocabulary, with viewer-adapter path-shape override applied |
| Search ("what do I know about") | contract | Search frontmatter + body; surface paths with short summaries |
| Scaffold ("new bug ticket") | contract | Use the matching template under `notes/resources/templates/`, applying viewer-adapter folder shape |
| Edit (path under `notes/`) | contract | Apply contract conventions (frontmatter present, naming, folder-note shape if applicable) |

## Cross-references

- `.ai/procedures/personal-knowledge-management/PROCEDURE.md` — vault contract.
- `.ai/procedures/personal-knowledge-management/adapters/<viewer>/README.md` — viewer-specific overrides.
- `AGENTS.md` § Framework Procedures — table row for `personal-knowledge-management`.
