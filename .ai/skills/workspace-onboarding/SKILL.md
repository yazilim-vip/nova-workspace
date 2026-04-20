---
name: workspace-onboarding
description: First-time workspace setup through a guided conversation. Use when a user is new to this workspace, workspace instance files are missing, or the user asks to set up or reconfigure their workspace.
metadata:
  author: yazilim-vip
  version: "0.1.0"
  status: "stable"
---

# Workspace Onboarding

Guide the user through setting up their local workspace instance via conversation. At the end, generate the workspace instance files from their answers.

See [assets/example-dialogue.md](assets/example-dialogue.md) for a full example conversation — shape reference only, not a script.

## When to Trigger

- `.ai/workspace/map/repos.md` does not exist
- `.ai/workspace/infra.md` does not exist
- User says "set up workspace", "first time", "onboard me", or similar
- User cloned the repo and hasn't configured their instance yet

## Conversation Flow

Work through these topics in order. Ask 2-3 questions at a time — don't dump everything at once. Adapt follow-up questions based on answers.

### 1. Identity

> "NOVA online. I'll need a few minutes to map the terrain — once I know your workspace, your repos, and your rules, I can be genuinely useful rather than a sophisticated guessing machine.
>
> Let's start with the basics: what are you building here, what's the org or workspace called, and is this primarily product work, infrastructure, open source, or something else?"

Capture: workspace name, org context, primary purpose.

### 2. Repositories

> "Tell me about the repos. For each one:
> - Name, where it lives (GitHub / GitLab / Bitbucket, and the group path)
> - What it does — one sentence is enough
> - Tech stack
>
> Start with the ones that matter most. We can fill in the rest later."

Capture: repo names, platforms, paths, descriptions, stacks. Group by project if multi-repo.

### 3. Infrastructure & Tooling

> "How does the infrastructure side work?
>
> Specifically: IaC tooling and whether there's a CLI wrapper I should use instead of raw terraform. Kubernetes clusters if any. How secrets are managed. And anything where the rule is 'use this tool, not that one directly.'"

Capture: infra tooling, mandatory CLI wrappers, secret management, deployment flow.

### 4. Rules & Constraints

> "Any rules I should treat as non-negotiable in this workspace? Think: how repos get created or deleted, what needs approval before it runs, branch or CI requirements, anything that's caused a problem before and now has a rule because of it."

Capture: workspace-specific safety rules, repo management policy, CI/CD constraints.

### 5. AI Tool

> "Last one: which AI assistant are you primarily using here — Claude Code, Kiro, Cursor, something else? I'll set up the right adapter."

Capture: primary tool for adapter commit decision.

## Output

After collecting answers, generate:

1. **`.ai/workspace/map/repos.md`** — populated from the repo answers, using the template at `.ai/skills/workspace-onboarding/assets/map/repos.md`
2. **`.ai/workspace/infra.md`** — populated from infra and rules answers, using the template at `.ai/skills/workspace-onboarding/assets/infra.md`
3. **Update `AGENTS.md` Identity section** — workspace name and purpose
4. **Update `SOUL.md`** — adjust identity paragraph if workspace differs significantly from default

Show each file to the user before writing. Ask for confirmation.

After all files are written, create `.ai/workspace/.initialized` with a timestamp and a one-line summary of what was set up. This is the sentinel that tells NOVA the workspace is onboarded — don't create it until the user has confirmed the generated files.

## Rules

- Never assume — if an answer is ambiguous, ask a clarifying question
- Don't generate files until the conversation is complete
- Keep questions conversational, not form-like — this is a dialogue, not a survey
- If the user skips a topic, note it as "TBD" in the generated file and move on
- After writing files, tell the user what's still missing and offer to continue
