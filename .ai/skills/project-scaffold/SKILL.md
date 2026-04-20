---
name: project-scaffold
description: Scaffold and validate a single project's structure — AGENTS.md hierarchy, .ai/ directory, tool adapters. Use when creating a new project, validating an existing one, or migrating legacy structures.
metadata:
  author: yazilim-vip
  version: "0.2.0"
  status: "stable"
---

# Project Scaffold

## Scope

A **project** is one repo, one logical code unit. It has its own `AGENTS.md`, optionally an `.ai/` directory, and optionally subfolder `AGENTS.md` files for submodules with distinct rules.

Cross-project concerns — skills, safety rules, repo maps, infra conventions — belong to the **workspace**, not the project. If you need to coordinate across multiple repos, that's a workspace (see `workspace-onboarding`), not a "multi-repo project." No nested workspaces.

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

## Template

Use [assets/AGENTS.md](assets/AGENTS.md) as the starting point for a new project's root `AGENTS.md`.

## Convention Adoption Protocol

When entering a project for the first time or when asked to validate:

1. Check if the project has an `AGENTS.md`
2. Validate it aligns with project conventions (this skill) and workspace conventions (the parent workspace)
3. If missing or non-compliant, offer to scaffold from `assets/AGENTS.md`
4. If the project has a `.skills/` directory, migrate it to `.ai/skills/`

## What Belongs in a Project AGENTS.md

- **Identity**: What the project is, tech stack
- **Module Map**: What's inside (for projects with multiple modules/submodules)
- **Build & Run**: How to build, test, run locally
- **Key Paths**: Important files and directories
- **Project Rules**: Rules specific to this project — not workspace rules
- **Dependencies**: Related repos, external services

## What Does NOT Belong

- Workspace-level concerns (skills index, cross-project safety rules, repo map)
- References to sibling projects (each project must be self-contained)
- Ephemeral task details
- Secrets or credentials
- Information derivable from the code itself
