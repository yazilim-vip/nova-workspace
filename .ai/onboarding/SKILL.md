---
name: nova-onboarding
description: Guide the user through setting up their local NOVA workspace instance — workspace identity, persona overrides, repository map, infra config. Trigger on first session, missing `.ai/workspace/.initialized`, or when the user says "set up my workspace", "onboard me", or "set up this workspace".
---

# Workspace Onboarding

Framework skill — gets a fresh NOVA workspace configured for the local user.

Guide the user through setting up their local workspace instance via conversation. At the end, generate the workspace instance files from their answers.

See [assets/example-dialogue.md](assets/example-dialogue.md) for a full example conversation — shape reference only, not a script.

## When to Trigger

- `.ai/workspace/.initialized` does not exist
- `.ai/workspace/AGENTS.md` does not exist
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

> "Which AI assistant are you primarily using here — Claude Code, Kiro, Cursor, something else? I'll set up the right adapter."

Capture: primary tool for adapter commit decision.

## Output

All onboarding output lands under `.ai/workspace/`. Never edit the root `AGENTS.md` or `SOUL.md` — those are framework defaults owned by upstream.

After collecting answers, generate:

1. **`.ai/workspace/AGENTS.md`** — workspace identity + any override rules, from the template at `.ai/onboarding/assets/AGENTS.md`. This is the file the agent layers on top of root `AGENTS.md` every session.
2. **`.ai/workspace/SOUL.md`** — only if the workspace needs persona overrides (tone, language, extra boundaries). Skip otherwise. Template: `.ai/onboarding/assets/SOUL.md`.
3. **`.ai/workspace/map/repos.md`** — populated from the repo answers, using the template at `.ai/onboarding/assets/map/repos.md`.
4. **`.ai/workspace/infra.md`** — populated from infra and rules answers, using the template at `.ai/onboarding/assets/infra.md`.
5. **`.ai/workspace/learnings/drift-log.md`** — copy the seed from `.ai/onboarding/assets/learnings/drift-log.md` verbatim. No user input needed; it's the measurement log for `.ai/enforcement.md`.

Show each file to the user before writing. Ask for confirmation.

After all files are written, create `.ai/workspace/.initialized` with a timestamp and a one-line summary of what was set up. This is the sentinel that tells NOVA the workspace is onboarded — don't create it until the user has confirmed the generated files.

## Rules

- Never assume — if an answer is ambiguous, ask a clarifying question
- Don't generate files until the conversation is complete
- Keep questions conversational, not form-like — this is a dialogue, not a survey
- If the user skips a topic, note it as "TBD" in the generated file and move on
- After writing files, tell the user what's still missing and offer to continue
