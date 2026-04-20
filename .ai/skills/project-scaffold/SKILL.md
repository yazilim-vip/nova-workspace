---
name: project-scaffold
description: Scaffold and validate project structure using the AGENTS.md hierarchy and .ai/ directory conventions. Use when creating a new project, validating an existing one against conventions, setting up agent configurations, or migrating legacy structures.
metadata:
  author: yazilim-vip
  version: "0.1.0"
  status: "stable"
---

# Project Scaffold

## AGENTS.md Hierarchy

Every project uses `AGENTS.md` as its instruction file. Subfolders with distinct concerns can have their own `AGENTS.md` that narrows scope.

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
├── skills/          # Agent skills — each skill can have assets/ for templates
└── learnings/       # Accumulated knowledge from past sessions
```

Only create subdirs the project actually needs.

## Key Rules

- `AGENTS.md` is the instruction file at every level — keep it lean, move details to `.ai/`
- `.ai/` is the single directory for all AI/agent content — no tool-specific files inside it
- No tool-specific files in `.ai/` — conventions must be tool-agnostic
- Fog-of-war applies to monorepo folders — each folder level is part of the navigation chain
- `.skills/` is deprecated — migrate contents to `.ai/skills/`

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

## Layered Map

Each level is fully self-contained — it must work independently without referencing any parent.

```
Workspace map
  → pointer to project, no details

Agent-config AGENTS.md (multi-repo)
  → pointer to each repo, no build/run details

Repo AGENTS.md
  → fully self-contained: identity, build/run, key paths, all rules

Subfolder AGENTS.md
  → fully self-contained for that subfolder's concerns
```

## Project Patterns

### Mono-Repo

- `AGENTS.md` at root with project identity, module map, build/run instructions
- Subfolder `AGENTS.md` files for distinct modules
- Use template: [assets/mono-repo/AGENTS.md](assets/mono-repo/AGENTS.md)

### Multi-Repo

- `<project>-agent-config/AGENTS.md` — project identity, repo map
- Each repo has its own self-contained `AGENTS.md`
- Always read the agent-config first, then the target repo
- Use templates: [assets/multi-repo/](assets/multi-repo/)

## Convention Adoption Protocol

When entering a project for the first time or when asked to validate:

1. Check if the project has an `AGENTS.md`
2. Validate it aligns with workspace conventions
3. If missing or non-compliant, offer to scaffold from templates
4. If the project has a `.skills/` directory, migrate it to `.ai/skills/`

## What Belongs in a Project AGENTS.md

- **Identity**: What the project is, tech stack
- **Repo/Module Map**: What's inside
- **Build & Run**: How to build, test, run locally
- **Key Paths**: Important files and directories
- **Project Rules**: All rules needed (baked in, not referenced)
- **Dependencies**: Related repos, external services

## What Does NOT Belong

- References to workspace or parent configs
- Ephemeral task details
- Secrets or credentials
- Information derivable from the code itself
