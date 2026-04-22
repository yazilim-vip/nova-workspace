# Adapters

Framework procedure — read when the user asks to set up, generate, or refresh a non-Claude agent adapter (Kiro, Cursor, Windsurf, Copilot, etc.). Not a skill.

## Why adapters exist

Claude Code auto-reads `AGENTS.md` at the workspace root. Other agents don't — each has its own steering/rules convention and won't pick up NOVA's navigation protocol on its own. Adapters bridge that gap: thin, platform-specific files that tell the host agent to read `AGENTS.md`, `.ai/workspace/AGENTS.md`, and follow NOVA's Navigation Protocol.

## Principle

- **Templates live in-framework** under `.ai/adapters/<platform>/` — committed, reviewable, evolves with NOVA.
- **Generated adapter files live in the user's workspace** under the platform's own convention (e.g. `.kiro/steering/`) — gitignored, per-developer, regenerable.
- **Adapters are shims, not replacements.** They point the host agent at NOVA's real instructions; they don't duplicate them.

## Supported platforms

| Platform | Template dir | Output dir | Inclusion mechanism |
|----------|--------------|-----------|---------------------|
| Kiro | `.ai/adapters/kiro/` | `.kiro/steering/` | YAML front matter (`inclusion: always`) |

### Kiro — terminal hazards

Kiro has known terminal integration bugs that hang the CLI session on heredocs, complex multi-line commands, long-running processes, and certain shell themes. The `nova-terminal.md` steering entry encodes strict rules to keep the agent out of those traps (write scripts to `scripts/` instead of inline multi-line; one command per execution; never fire-and-forget non-terminating processes). Treat it as non-negotiable — it exists because users hit these hangs repeatedly.

More platforms get added here as they're supported.

## When to Trigger

- "set up kiro adapter", "generate kiro steering", "make nova work in kiro"
- User mentions their IDE isn't reading `AGENTS.md`
- Optional: during onboarding, if the user names a non-Claude agent as their primary tool

## Procedure

1. **Confirm the platform.** Ask which IDE/agent the user wants to adapt for. Only supported platforms from the table above.
2. **Check the output directory.**
   - If it doesn't exist, create it.
   - If it already has files, list them and ask before overwriting. Don't clobber existing user customizations silently.
3. **Copy templates.** For each file in `.ai/adapters/<platform>/`, write a matching file to the platform's output directory. Preserve file names unless the platform requires renaming.
4. **Verify `.gitignore`.** The platform's output directory must be gitignored at the workspace root. If it's not, add it and tell the user.
5. **Report.** Tell the user what was generated, where, and how to test it (restart the agent, open a chat, confirm it references NOVA).

## Rules

- **Never commit generated adapter files.** They're machine-local — the framework regenerates them on demand.
- **Never modify the user's existing steering/rules files without asking.** If they've hand-written something, surface it first.
- **Keep templates thin.** An adapter's job is to redirect to `AGENTS.md` + `.ai/workspace/AGENTS.md`. If content starts duplicating NOVA's core instructions, that's a smell — fix the host agent's reading behavior instead.
- **When NOVA's navigation protocol changes, update the templates.** Adapter files reference the same protocol; they drift if ignored.
