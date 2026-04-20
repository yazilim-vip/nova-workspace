---
name: self-update
description: Review and selectively integrate upstream NOVA changes into this workspace. Use when the user asks to "sync with upstream", "pull NOVA updates", "update my workspace", or similar. Never run a blind git merge — upstream changes are proposals, not commands.
metadata:
  author: yazilim-vip
  version: "0.1.0"
  status: "stable"
---

# Self-Update

## Principle

A fork of NOVA diverges on purpose. Team-specific skills, tightened safety rules, custom onboarding questions — these are the reason the fork exists. A blind `git merge upstream/main` risks either overwriting those customizations or silently adopting upstream changes that don't fit this workspace.

Treat every upstream change as a **proposal**. Review it, decide whether it fits, apply or skip deliberately. Evolve the workspace — don't replace it.

## When to Trigger

- "sync with upstream", "pull NOVA updates", "update my workspace"
- "check for NOVA changes"
- User points at the upstream repo and asks what's new
- After a long gap since the last sync

## Preflight

Before touching anything:

1. **Confirm `upstream` remote exists.** If not, add it:
   ```bash
   git remote add upstream https://github.com/yazilim-vip/nova-workspace.git
   ```
2. **Working tree must be clean.** If there are uncommitted changes, stop and ask the user to commit or stash first. Never stash silently.
3. **Current branch must be `main`** (or the workspace's equivalent trunk). If not, ask which branch should receive updates.

## Review Flow

### 1. Fetch and summarize

```bash
git fetch upstream
git log --oneline main..upstream/main
```

Present a summary: count of commits, touched paths grouped by area (skills, AGENTS.md, templates, README, etc.). Do not run `git merge` yet.

### 2. Classify each change

Walk each commit (or squash logical groups) and classify:

| Class | What it is | Default action |
|-------|-----------|----------------|
| **New skill** | New `.ai/skills/<name>/` directory | Offer — user decides if it fits their workflow |
| **Skill update (compatible)** | Change to a skill the fork hasn't customized | Apply |
| **Skill update (conflicting)** | Change to a skill the fork has modified | Discuss — surface both versions, recommend a merge strategy |
| **AGENTS.md / SOUL.md change** | Edit to root-level instruction files | Always discuss — these are identity files, forks often customize heavily |
| **Template change** | `.ai/skills/workspace-onboarding/assets/*` | Apply unless the fork has diverged |
| **Docs / README** | README.md, CONTRIBUTING notes | Apply unless fork-specific wording exists |
| **Breaking / structural** | Path renames, removed skills, schema changes | Discuss — may require fork migration |
| **Deprecation** | Marked-deprecated content | Note in learnings; schedule removal, don't apply blindly |

### 3. Present the plan

Before applying anything, show the user:
- What will be applied as-is
- What needs a merge decision (with both sides shown)
- What will be skipped and why

Get explicit confirmation. The user can redirect any item.

### 4. Apply deliberately

Use `git cherry-pick` for individual commits when classification varies across a range. Use `git merge upstream/main` only when every commit in the range is being accepted as-is. Resolve conflicts interactively — never favor one side with `-X theirs` or `-X ours` blindly.

For skipped commits, note them in `.ai/workspace/learnings/upstream-skipped.md` with reason, so future syncs don't re-propose them.

### 5. Post-sync validation

After merging:

1. Check that `AGENTS.md` still loads without dangling references (skill paths, template paths).
2. Verify every skill listed in the AGENTS.md skills table still has a `SKILL.md`.
3. If onboarding templates changed, verify the user's `.ai/workspace/*` instance files don't need regeneration.
4. Run any fork-specific sanity checks (e.g., for yazilim.vip: does `openclaw` skill still load?).

### 6. Evolve the agent's own knowledge

- If upstream deprecated something this fork still uses, add a learning note: what's deprecated, when to migrate.
- If upstream introduced a new convention that overlaps with a local practice, update the local skill or note the divergence.
- If a skill's frontmatter changed shape (e.g., new required metadata), update local skills to match.

## Rules

- **Never** run a blind `git merge upstream/main` without the review flow.
- **Never** force-overwrite local customizations with upstream content — surface the conflict to the user.
- **Never** silently drop upstream commits — every skip is recorded.
- **Always** commit post-sync changes as a single merge or a cherry-pick series with clear messages, so the sync itself is visible in git history.
- If upstream has rewritten history (force-push), stop and ask — don't auto-rebase.

## Output

After a successful sync, report to the user:
- Commits applied, commits skipped (with reasons)
- Any learning notes added
- Any follow-up work the fork should schedule (deprecation migrations, new skills to review in depth, etc.)
