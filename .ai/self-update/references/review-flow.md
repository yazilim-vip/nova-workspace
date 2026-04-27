# Case B — Upstream Review Flow

The detailed flow for syncing upstream NOVA changes into a fork. Read alongside `../SKILL.md`. See `workflow.md` for the end-to-end diagram.

## 1. Fetch and summarize

Let `REMOTE` be the remote resolved in SKILL.md's *Discover the Upstream* (e.g. `upstream` or `origin`) and `BRANCH` be the resolved branch (e.g. `main`).

```bash
git fetch <REMOTE>
git log --oneline <local-branch>..<REMOTE>/<BRANCH>
git diff --stat <local-branch>..<REMOTE>/<BRANCH>
```

Present a summary: commit count, touched paths grouped by area (skills, AGENTS.md, templates, README, etc.). If there are zero incoming commits, report "already up to date" and stop. Do not run `git merge` yet.

## 2. Classify each change

Walk each commit (or squash logical groups) and classify:

| Class | What it is | Default action |
|-------|-----------|----------------|
| **Framework skill change** | Change to a `.ai/<name>/SKILL.md` (e.g. `nova-onboarding`, `nova-self-update`) or its supporting files | Usually apply — core machinery. If the fork customized the skill, surface the diff. |
| **Convention doc change** | Change to flat `.ai/*.md` (e.g. `.ai/project-structure.md`) | Apply unless the fork has diverged |
| **Onboarding template change** | `.ai/onboarding/assets/*` | Apply unless the fork has diverged |
| **AGENTS.md / SOUL.md change** | Edit to root-level instruction files | Always discuss — these are identity files, forks often customize heavily |
| **Docs / README** | README.md, top-level docs | Apply unless fork-specific wording exists |
| **Breaking / structural** | Path renames, removed skills, schema changes | Discuss — may require fork migration |
| **Deprecation** | Marked-deprecated content | Note in learnings; schedule removal, don't apply blindly |

## 3. Present the plan

Before applying anything, show the user:

- What will be applied as-is
- What needs a merge decision (with both sides shown)
- What will be skipped and why

Get explicit confirmation. The user can redirect any item.

## 4. Apply deliberately

Use `git cherry-pick` for individual commits when classification varies across a range. Use `git merge <REMOTE>/<BRANCH>` only when every commit in the range is being accepted as-is. Resolve conflicts interactively — never favor one side with `-X theirs` or `-X ours` blindly.

For skipped commits, record them in `.ai/workspace/learnings/upstream-skipped.md` with reason, so future syncs don't re-propose them.

### Example `upstream-skipped.md` entry

```markdown
## 2026-05-14 — sync against yazilim-vip/nova-workspace main

| Commit | Summary | Skipped because |
|--------|---------|-----------------|
| `a1b2c3d` | feat(skill): add slack-notify shared skill | Fork doesn't use Slack for agent notifications; adopting would add maintenance without benefit. Revisit if we migrate. |
| `e4f5g6h` | docs: shorten README onboarding section | Our fork has a longer, team-specific onboarding section. Keep our version. |

## 2026-04-20 — sync against yazilim-vip/nova-workspace main

…
```

One section per sync, dated. Each row: commit SHA, one-line summary, why it was skipped. Include a hint about *when* it might be worth revisiting — so future syncs can decide whether conditions have changed.

## 5. Post-sync validation

After merging:

1. Check that `AGENTS.md` still loads without dangling references (skill paths, template paths).
2. Verify every skill listed in the `AGENTS.md` skills table still has a `SKILL.md`.
3. If onboarding templates changed, verify the user's `.ai/workspace/*` instance files don't need regeneration.
4. Run any fork-specific sanity checks (e.g. do the team's custom skills still load and validate?).

## 6. Evolve the agent's own knowledge

- If upstream deprecated something this fork still uses, add a learning note: what's deprecated, when to migrate.
- If upstream introduced a new convention that overlaps with a local practice, update the local skill or note the divergence.
- If a skill's frontmatter changed shape (e.g., new required metadata), update local skills to match.
