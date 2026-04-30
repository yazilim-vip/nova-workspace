# Claude Agent Generation — Procedure

Markdown procedure followed by the host agent (or by `agent-author`) to translate canonical NOVA agent specs into native Claude Code subagent files. No script — the agent reads this file and executes the steps with native tools (Read, Glob, Write).

> **Spec contract:** `.ai/agent-spec.md` is the authority for the AGENT.md schema and platform translation table. This file describes the *procedure* only. Do not duplicate the schema or the translation table here.

## When to run

- During the adapters procedure (`.ai/adapters/SKILL.md`) — regenerates all Claude agents from current specs.
- On demand when a single spec is added or edited — re-run for that one file.
- Invoked by `agent-author` when it scaffolds a new agent.

## Inputs

Discover all canonical specs by globbing the workspace from its root:

- `.ai/workspace/agents/*/AGENT.md` — workspace user agents
- `.ai/*/AGENT.md` — framework agents (when migrated; skip during early-migration window)
- `git-repositories/*/.ai/agents/*/AGENT.md` — project agents (when registered)

## Output

- Location: `.claude/agents/<name>.md`
- One file per spec.
- Filename = the spec's frontmatter `name` (kebab-case).

## Generation marker

Every generated file MUST contain this exact line on its own, immediately after the frontmatter:

```
<!-- nova-generated: agent-gen -->
```

This marker is how the cleanup pass distinguishes generated files from hand-authored Claude-only subagents (e.g. `repo-worker.md`, `dream-worker.md`). Hand-authored files do NOT carry the marker and MUST NOT be touched.

## Procedure

For each discovered AGENT.md spec, do the following — in order:

### 1. Read and parse the spec

Read the file. Split the YAML frontmatter (between the leading `---` and the next `---`) from the body (everything after).

### 2. Validate

- `name` is required (or infer from the parent folder name if absent — folder name wins where they conflict, since folder is canonical).
- `description` is required and non-empty. If missing, abort this spec and log the error; do not write a partial file.

### 3. Translate fields per `.ai/agent-spec.md` § "Platform translation"

The spec file is the source of truth for the mapping. Apply the Claude column. Highlights:

- `tools: [read, edit, ...]` (neutral, lowercase) → Claude frontmatter `tools: Read, Edit, ...` (capitalized, comma-separated).
- `model:` passes through (`sonnet`, `opus`, `haiku`, `inherit`).
- `resources:` becomes `@`-imports placed in the body, NOT a frontmatter field — Claude has no native `resources` array. Path translation:
  - `file://<path>` → `@../../<path>` (relative to runtime location `.claude/agents/<n>.md`, which is two directory levels below the workspace root).
  - `skill://<path>` → an HTML comment hint in the body: `<!-- nova: load skill via Read at runtime: <path> -->`. Claude has no native skill URI; the agent reads the skill file when it needs it.
- `welcome`, `keyboard_shortcut` — Claude has no surface for these; ignore silently.
- `mcp_servers` — Claude reads MCP config from `settings.json`, not per-agent. Out of scope here; the adapters procedure handles MCP merging elsewhere.
- `write_scope` — Claude has no per-agent fs_write whitelist. The agent's body should respect the scope, but it isn't enforced. Note this in the agent's body if the spec requested it.
- `overrides.claude` — merge into the Claude frontmatter (overrides any field set above).
- `overrides.kiro` — ignore.

### 4. Render the output file

Construct the output in this exact order:

1. `---` opening fence.
2. Frontmatter lines: `name`, `description`, `tools` (only if any), `model`. Plus any merged-in `overrides.claude` fields.
3. `---` closing fence.
4. Blank line.
5. The generation marker comment (exact string above).
6. Blank line.
7. The translated `@`-imports (from `resources`), one per line. Skip if no resources.
8. Blank line if imports were written.
9. The body verbatim from the spec, trailing whitespace trimmed.
10. Trailing newline.

### 5. Write to `.claude/agents/<name>.md`

Overwrite if the file exists AND already carries the generation marker.

If a file at that path exists WITHOUT the marker, abort with an error — that's a hand-authored file and must not be clobbered. The user must rename or remove it before this spec can be generated.

## Cleanup pass (after all specs are written)

List every file under `.claude/agents/`. For each:

- If it carries the generation marker AND its `<name>.md` filename is NOT in the set of just-generated names, delete it. (The backing spec was removed; the runtime file should follow.)
- If it does NOT carry the marker, leave it alone — hand-authored.

## Reporting

After the run, surface to the user:

- Count and list of files generated.
- Count and list of files removed by cleanup.
- Any specs skipped due to validation errors (with the spec path and reason).

## Anti-patterns

- **Don't reproduce the translation table here.** It lives in `.ai/agent-spec.md`. If a translation rule is unclear, fix the spec, not this procedure.
- **Don't touch files without the generation marker.** Hand-authored Claude subagents (`repo-worker`, `dream-worker`) are owned by the Claude adapter sources at `.ai/adapters/claude/agents/` and copied as-is by the adapters procedure. They are out of scope for this generator.
- **Don't write a script wrapper.** This file is the procedure. The host agent executes it directly with native tools. No `agent-gen.py`, `agent-gen.sh`, or build step.
- **Don't paraphrase the spec.** Reference fields by their spec name; if the user's request pushes toward inventing a field, update `.ai/agent-spec.md` first.
