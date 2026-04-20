---
name: self-update
description: Review and selectively integrate upstream NOVA changes into this workspace. Use when the user asks to sync with upstream, pull NOVA updates, update my workspace, or similar. Never run a blind git merge — upstream changes are proposals, not commands.
metadata:
  author: yazilim-vip
  version: "0.1.0"
  status: "stable"
---

# Self-Update

## Principle

A fork of NOVA diverges on purpose. Team-specific skills, tightened safety rules, custom onboarding questions — these are the reason the fork exists. A blind `git merge upstream/main` risks either overwriting those customizations or silently adopting upstream changes that don't fit this workspace.

Treat every upstream change as a **proposal**. Review it, decide whether it fits, apply or skip deliberately. Evolve the workspace — don't replace it.

See [references/workflow.md](references/workflow.md) for the end-to-end flow diagram.

## When to Trigger

- "sync", "pull", "update my workspace"
- "sync with upstream", "pull NOVA updates", "check for NOVA changes"
- User points at the upstream repo and asks what's new
- After a long gap since the last sync

## Two Kinds of Sync — Don't Conflate Them

The word "sync" is ambiguous. Disambiguate before doing anything.

### A. Sync with your own remote (origin catch-up)

**When:** The user pushed to this repo's `origin` from another machine, or a teammate pushed, and this local clone is now behind. Those commits are ours — there's nothing to review.

**Detection:** After `git fetch origin`, if `<branch>..origin/<branch>` has commits but `origin` is *this workspace's own canonical location* (not upstream NOVA), this is case A.

**Action:** Confirm with the user, then `git pull --ff-only origin <branch>`. If fast-forward fails (local has diverging commits), stop and surface the divergence — don't force a merge.

Review flow is **not** used here.

### B. Sync with upstream NOVA (fork catch-up)

**When:** This workspace is a fork, and we want to pull changes from the canonical `yazilim-vip/nova-workspace`. Those commits are *someone else's* — we need to review what applies to our fork and what doesn't.

**Detection:** An `upstream` remote exists pointing at canonical NOVA, or `origin` points at canonical NOVA and the local repo has fork-like customizations. (See **Discover the Upstream** below.)

**Action:** Full review flow — classify each commit, surface conflicts, apply deliberately.

### Which did the user mean?

If ambiguous, ask. Otherwise resolve by the state of the remotes:

| Setup | Default interpretation |
|-------|------------------------|
| Only `origin`, origin = canonical NOVA | Case A (you're the maintainer or a vanilla user — simple pull) |
| `origin` = fork, `upstream` = canonical NOVA; local behind `origin` | Case A |
| `origin` = fork, `upstream` = canonical NOVA; local behind `upstream` | Case B |
| Local behind both `origin` and `upstream` | Case A first, then offer Case B |

## Preflight

Before touching anything:

1. **Is this even a git repo?** Run `git rev-parse --is-inside-work-tree`. If not, stop — advise the user this skill needs a git-tracked workspace.
2. **Working tree must be clean.** Run `git status --porcelain`. If there are uncommitted changes, stop and ask the user to commit or stash first. Never stash silently.
3. **Resolve the current branch.** Usually `main`. If on a different branch, ask which branch should receive updates.

## Discover the Upstream

Only relevant for **Case B** (fork catch-up from canonical NOVA). If you already resolved this as Case A, skip this section and go straight to `git pull --ff-only`.

This is the most important step for Case B. The "upstream" can be in different places depending on how this workspace was set up. **Never assume** — detect, then confirm with the user before fetching.

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

## Review Flow (Case B)

Full procedure: fetch → classify → plan → apply → validate → learn.

See **[references/review-flow.md](references/review-flow.md)** — six steps with the classification table, an example `upstream-skipped.md` entry, and post-sync validation checklist.

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
