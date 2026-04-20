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

1. **Is this even a git repo?** Run `git rev-parse --is-inside-work-tree`. If not, stop — advise the user this skill needs a git-tracked workspace.
2. **Working tree must be clean.** Run `git status --porcelain`. If there are uncommitted changes, stop and ask the user to commit or stash first. Never stash silently.
3. **Resolve the current branch.** Usually `main`. If on a different branch, ask which branch should receive updates.

## Discover the Upstream

This is the most important step. The "upstream" can be in different places depending on how this workspace was set up. **Never assume** — detect, then confirm with the user before fetching.

### Known NOVA URLs

Treat any of these as "upstream NOVA":
- `github.com/yazilim-vip/nova-workspace` (canonical, HTTPS or SSH)
- Any remote whose URL ends with `nova-workspace.git` and lives under the `yazilim-vip` org

### Detection flow

1. Run `git remote -v` and list remotes with their URLs.
2. Check each remote against the known NOVA URLs:

   | Match | Interpretation | Fetch from |
   |-------|----------------|-----------|
   | `upstream` points at canonical NOVA | Fork scenario (recommended setup) | `upstream/<branch>` |
   | `origin` points at canonical NOVA, no `upstream` | Vanilla clone, no fork | `origin/<branch>` |
   | Both `origin` and `upstream` point at canonical NOVA | Ambiguous — ask the user which to use |
   | A different remote name points at canonical NOVA | Mirror or custom naming — confirm with the user |
   | No remote points at canonical NOVA | Ask the user. Offer to add an `upstream` remote |
   | No remotes at all | Stop — this workspace isn't wired to upstream. Offer to add `upstream` |

3. **Confirm the choice with the user before fetching.** Show: "I'll pull from `<remote>/<branch>` (URL: `…`). Proceed?"

### Which branch

Default to `main`. If the resolved upstream uses a different trunk name (e.g. `master`, `trunk`), use that — detect via `git remote show <remote> | grep 'HEAD branch'`.

If the user wants a specific tag or release instead of the trunk, honor that request and fetch `refs/tags/<tag>`.

### No upstream? Offer to add one.

If detection finds nothing:

```bash
git remote add upstream https://github.com/yazilim-vip/nova-workspace.git
git fetch upstream
```

Confirm with the user before running these commands — they may want a different URL (internal mirror, SSH, different fork as source).

## Review Flow

### 1. Fetch and summarize

Let `REMOTE` be the remote resolved in **Discover the Upstream** (e.g. `upstream` or `origin`) and `BRANCH` be the resolved branch (e.g. `main`).

```bash
git fetch <REMOTE>
git log --oneline <local-branch>..<REMOTE>/<BRANCH>
git diff --stat <local-branch>..<REMOTE>/<BRANCH>
```

Present a summary: count of commits, touched paths grouped by area (skills, AGENTS.md, templates, README, etc.). If there are zero incoming commits, report "already up to date" and stop. Do not run `git merge` yet.

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
