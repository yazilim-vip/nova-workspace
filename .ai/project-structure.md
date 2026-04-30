# Project Structure

The NOVA convention for how a single project organizes its agent-facing content.

This is a framework convention, not a skill — the agent reads it when creating or validating a project, not on every session. Humans read it when they need to know the rules.

## Scope

A **project** is one repo, one logical code unit. It has its own `AGENTS.md`, optionally an `.ai/` directory, and optionally subfolder `AGENTS.md` files for submodules with distinct rules.

Cross-project concerns — safety rules, repo maps, infra conventions, and skills that apply to *every* repo — belong to the **workspace**, not the project. If you need to coordinate across multiple repos, that's a workspace (see `.ai/nova-skills/onboarding/`), not a "multi-repo project." No nested workspaces.

Project-specific skills are different — they belong inside the project. Same skill name (`deploy`, `test`, `migrate`) can mean different things across repos because scope is location-disambiguated. See § "Project Skills" below.

## AGENTS.md Hierarchy

Every project has `AGENTS.md` at its root. Subfolders with distinct concerns can have their own `AGENTS.md` that narrows scope.

```
project/
├── AGENTS.md                  # Project root: identity, tech stack, build/run, project rules
├── .ai/                       # Extended instructions (optional)
├── backend/
│   ├── AGENTS.md              # Backend-specific rules
│   └── .ai/
├── frontend/
│   └── AGENTS.md              # Frontend-specific rules
└── infra/
    └── AGENTS.md              # Infrastructure-specific rules
```

Each level inherits the parent's rules and adds its own. Subfolders never relax parent rules.

## `.ai/` Directory Structure

```
.ai/
├── skills/          # Project-specific skills — each skill can have assets/ for templates
└── learnings/       # Accumulated knowledge from past sessions
```

Only create subdirs the project actually needs.

## Key Rules

- `AGENTS.md` is the instruction file at every level — keep it lean, move details to `.ai/`
- `.ai/` is the single directory for all AI/agent content — no tool-specific files inside it
- No tool-specific files in `.ai/` — conventions must be tool-agnostic
- Fog-of-war applies to subfolders — each folder level is part of the navigation chain

## Project Skills

A project can ship its own skills — domain-specific procedures that only make sense inside that repo (`deploy`, `seed-data`, `migrate`, etc.). These live alongside the code, declared in the project's `AGENTS.md`, auto-loaded by the agent when it enters the repo (Navigation Protocol step 4).

**Format.** [agentskills.io](https://agentskills.io) — a `SKILL.md` file with YAML frontmatter (`name`, `description`).

**Location.** The repo's choice. `<repo>/.ai/skills/<name>/SKILL.md` is a common convention but not required. NOVA prescribes nothing here; pick what fits your project.

**Declaration.** Add a "Skills" section to the project's `AGENTS.md` listing each skill. Example:

```markdown
## Skills

| Skill | Path | What it does |
|-------|------|--------------|
| deploy | `.ai/skills/deploy/SKILL.md` | Builds the Helm chart and applies to the staging cluster. |
| seed-data | `.ai/skills/seed-data/SKILL.md` | Populates the local dev DB from `fixtures/`. |
```

The agent reads this table when it enters the repo and loads each skill on demand.

**Scope discipline.**
- Project skills should be specific to the project. If a skill is generic across repos, lift it to the workspace (see workspace `AGENTS.md` § "Skills").
- A project skill named `deploy` is unrelated to a different project's `deploy` — they're scope-isolated. The agent loads the right one based on which repo it's currently in.
- Keep skill descriptions agentic — describe what the skill *does*, not what trigger phrases activate it.

## Tool Adapters

Each AI tool has its own entrypoint filename. Adapters are thin files (1-2 lines) that redirect to `AGENTS.md`.

| Tool | File | Commit? |
|------|------|---------|
| Claude Code | `CLAUDE.md` | Yes — primary tool, needed at clone time |
| Kiro | `.kiro/steering/workspace.md` | No — local only, gitignored |
| Cursor | `.cursor/rules/workspace.mdc` | No — local only, gitignored |
| GitHub Copilot | `.github/copilot-instructions.md` | No — local only, gitignored |
| Windsurf | `.windsurfrules` | No — local only, gitignored |

**Rule:** Commit only the adapter for your team's primary tool. All others are local. Never put agent instructions inside adapter files — only the redirect line belongs there.

## Convention Adoption Protocol

When entering a project for the first time or when asked to validate:

1. Check if the project has an `AGENTS.md`
2. Validate it aligns with project conventions (this doc) and workspace conventions (the parent workspace)
3. If missing or non-compliant, offer to scaffold from the template below

## What Belongs in a Project AGENTS.md

- **Identity** — what the project is, tech stack
- **Module Map** — what's inside (for projects with multiple modules/submodules)
- **Build & Run** — how to build, test, run locally
- **Key Paths** — important files and directories
- **Project Rules** — rules specific to this project (not workspace rules)
- **Skills** — project-specific skills (see § "Project Skills" above). Optional; only if the project has any.
- **Dependencies** — related repos, external services

## What Does NOT Belong

- Workspace-level concerns (cross-project safety rules, repo map, framework skills)
- References to sibling projects (each project must be self-contained)
- Ephemeral task details
- Secrets or credentials
- Information derivable from the code itself

## Template

Starter `AGENTS.md` for a new project. Fill in the `{{placeholders}}`; delete sections you don't need.

```markdown
# {{Project Name}}

## Identity

{{Brief description of the project and its purpose.}}

**Tech Stack:** {{e.g. Kotlin + Spring Boot, React + Vite}}

## Module Map

| Module | Path | Purpose |
|--------|------|---------|
| {{name}} | {{path}} | {{what it does}} |

## Build & Run

\`\`\`bash
# Build
{{build command}}

# Test
{{test command}}

# Run
{{run command}}
\`\`\`

## Key Paths

| Path | Purpose |
|------|---------|
| {{path}} | {{what it is}} |

## Project Rules

{{Project-specific rules on top of workspace conventions. Delete this section if none.}}

## Skills

{{Project-specific skills, agentskills.io format. Delete this section if the project has no skills of its own.}}

| Skill | Path | What it does |
|-------|------|--------------|
| {{name}} | {{path/to/SKILL.md}} | {{one-line semantic description}} |

## Dependencies

| Dependency | Relationship |
|-----------|-------------|
| {{repo or service}} | {{how this project depends on it}} |
```

### Absolute minimum

If you want the smallest valid `AGENTS.md`:

```markdown
# <project name>

## Identity

<one-paragraph description of what the project is and its tech stack>

## Build & Run

\`\`\`bash
<build command>
<test command>
<run command>
\`\`\`

## Project Rules

<anything that would surprise a new contributor — constraints, conventions, gotchas>
```

Grow from there as the project earns complexity.
