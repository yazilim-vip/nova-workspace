# Contributing to NOVA

NOVA is an opinionated framework shipped as *how the yazilim.vip crew works*. You're welcome to use it as-is, fork it, or contribute upstream.

## Adding your own skills

NOVA recognizes two places for skills:

### Team-shared skills — fork model

Skills your whole team should have (e.g. a shared internal tool, a mandatory deployment flow, a custom review checklist) belong in `.ai/skills/<your-skill>/SKILL.md` — **committed to your fork** of `nova-workspace`.

The yazilim.vip crew does this with the `openclaw` skill. Your fork is the source of truth for your team; upstream NOVA stays generic.

To stay current with upstream NOVA:

```bash
git remote add upstream https://github.com/yazilim-vip/nova-workspace.git
git fetch upstream
git merge upstream/main
```

### Personal, local-only skills — `.ai/workspace/skills/`

One-off helpers, experimental skills, or anything machine-specific goes in `.ai/workspace/skills/<your-skill>/SKILL.md`. This directory is gitignored — nothing you put there is shared or committed.

Use this for: a skill you're prototyping, a shortcut tied to your local setup, anything you wouldn't want to push to a team repo.

If the same skill name exists in both locations, the local version (`.ai/workspace/skills/`) wins.

## Skill structure

Every skill has a `SKILL.md` with YAML frontmatter:

```markdown
---
name: my-skill
description: One-line description of when to load this skill.
metadata:
  author: your-name
  version: "0.1.0"
  status: "stable"
---

# My Skill

## When to Use

…

## How it Works

…
```

Look at `.ai/skills/git-workflow/SKILL.md` or `.ai/skills/terraform/SKILL.md` as references.

## Contributing upstream

If you've built something generic enough that other teams would benefit — a new skill, a fix to an existing one, a better onboarding question — open a PR.

Keep PRs focused and opinionated. NOVA is not trying to be a neutral framework; it's trying to be a good one. "This is how we do it, here's why" is a better PR description than "adds optional support for X."

## Licensing

By contributing, you agree your contribution is licensed under the MIT License (same as the rest of the repo).
