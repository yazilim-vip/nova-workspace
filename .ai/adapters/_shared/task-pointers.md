# Task-relevant pointers

Per-turn hooks (Claude `user-prompt-submit`, Kiro `prompt-submit`) parse the lines between `<!-- begin-pointers -->` and `<!-- end-pointers -->`. Each line: `<extended-regex> => <pointer text>`.

The separator is the literal three-character string ` => ` (space-arrow-space). Parser splits at the **first** occurrence; everything before is the pattern, everything after is the pointer. This lets patterns contain pipe alternation (`a|b|c`) without conflicting with the splitter.

The pattern is matched case-insensitively against the user's prompt (raw stdin envelope, no JSON parsing — keywords are workspace-specific so false positives from JSON metadata are negligible). When a pattern matches, the pointer is emitted as a "Consider:" line in the per-turn re-injection. This is a **just-in-time retrieval** layer — turns the static checklist into task-relevant context.

## Authoring rules

- **Pattern format.** POSIX extended regex. Avoid `\b` (not portable across BSD/GNU `grep`). For boundary-sensitive short keywords use `(^|[^a-zA-Z])(kw)([^a-zA-Z]|$)` instead.
- **Separator.** Exactly ` => ` (space-arrow-space). Patterns and pointers must not contain that exact 4-char substring; if you need to match `=>` inside a regex, separate the words: `=[ ]*>`.
- **Pointer text.** Free prose. Convention: `` `<path>` (one-line description) ``.
- **Update when:** a new workspace skill is added, a new repo enters `repos.md` and you find yourself naming it often, or the drift log shows the agent missing a specific skill despite the keyword being present in the prompt.
- **Don't over-add.** Every pointer adds tokens to every turn it fires. Aim for high-precision triggers — a keyword that fires only when the relevant skill is genuinely useful.

## Patterns

<!-- begin-pointers -->
(commit|branch|merge|pull request|merge request|rebase|squash|cherry-pick) => `.ai/workspace/skills/git-workflow/SKILL.md` (git-workflow skill)
(terraform|terragrunt) => `.ai/workspace/skills/terraform/SKILL.md` (terraform skill)
(kubectl|kubernetes|helm chart|kustomize|fluxcd|flux cd) => `.ai/workspace/skills/kubernetes/SKILL.md` (kubernetes skill)
(pipeline|gitlab.?ci|github action|workflow\.ya?ml|image tag) => `.ai/workspace/skills/ci-cd/SKILL.md` (ci-cd skill)
(openclaw) => `.ai/workspace/skills/openclaw/SKILL.md` (openclaw skill)
(refactor|debugging|code quality|code review) => `.ai/workspace/skills/code-quality/SKILL.md` (code-quality skill)
(gym-tracker) => `git-repositories/gitlab/yazilim.vip/community/projects/gym-tracker/gym-tracker/AGENTS.md` (gym-tracker repo)
(chart-ai) => `git-repositories/gitlab/yazilim.vip/private/chart-ai/chart-ai/` (chart-ai monorepo — read its AGENTS.md)
(payment-vip) => `git-repositories/gitlab/yazilim.vip/community/projects/payment-vip/` (payment-vip group)
(yaver) => `git-repositories/gitlab/yazilim.vip/private/yaver/` (yaver group — inactive)
(bookmarks-mcp) => `git-repositories/github/yazilim-vip/bookmarks-mcp/AGENTS.md` (bookmarks MCP server)
(yvip-fluxcd|fluxcd) => `git-repositories/gitlab/yazilim.vip/yvip-fluxcd/` (fluxcd GitOps)
(yvip-terragrunt) => `git-repositories/gitlab/yazilim.vip/terraform/yvip-terragrunt/` (terragrunt orchestrator)
(bifrost|llm gateway) => `.ai/workspace/infra.md` (Bifrost LLM gateway — internal apps SHOULD route through it)
(keycloak|sso|oidc) => `.ai/workspace/infra.md` (Keycloak SSO — internal apps SHOULD authenticate via it)
(dream pass|dream worker|consolidate.+memory) => `.ai/dream/SKILL.md` (dream pass procedure)
(onboard|set up.+workspace|fresh.+workspace) => `.ai/onboarding/SKILL.md` (onboarding flow)
<!-- end-pointers -->
