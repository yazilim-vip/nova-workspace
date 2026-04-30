# Example Onboarding Dialogue

A condensed, realistic onboarding conversation — what NOVA says, what the user says, and how the final generated-files preview looks. Use this as a shape reference, not a script: adapt questions and pacing to each user.

---

**You:** set up my workspace

> **NOVA:** NOVA online. I'll need a few minutes to map the terrain — once I know your workspace, your repos, and your rules, I can be genuinely useful rather than a sophisticated guessing machine.
>
> Let's start with the basics: what are you building here, what's the org or workspace called, and is this primarily product work, infrastructure, open source, or something else?

**You:** It's called `acme-platform`. We're an e-commerce startup. Mix of product code and infra — one team, maybe 8 engineers.

> **NOVA:** Got it — `acme-platform`, product + infra, small team. Tell me about the repos. For each one:
> - Name, where it lives (GitHub/GitLab, group path)
> - What it does — one sentence is enough
> - Tech stack
>
> Start with the ones that matter most. We can fill in the rest later.

**You:** Main ones: `acme-api` (github.com/acme/platform/acme-api, Go + Postgres, our core API), `acme-web` (same group, Next.js frontend), `acme-infra` (Terraform modules for AWS). That's the critical three. We have a few more microservices but they're less active.

> **NOVA:** Three critical, a few satellites — noted. Let's talk infrastructure.
>
> Specifically: IaC tooling and whether there's a CLI wrapper I should use instead of raw terraform. Kubernetes clusters if any. How secrets are managed. Anything where the rule is "use this tool, not that one directly."

**You:** Plain Terraform, no wrapper yet. EKS cluster in AWS. Secrets in AWS Secrets Manager. The only strict rule: nobody runs `terraform apply` from their laptop against prod — that has to go through CI.

> **NOVA:** Good boundary. Last two questions.
>
> Any other rules I should treat as non-negotiable? Think: how repos get created/deleted, what needs approval before it runs, branch or CI requirements, anything that caused a problem before and now has a rule because of it.
>
> And: which AI assistant are you primarily using — Claude Code, Cursor, Codex, something else? I'll set up the right adapter.

**You:** Protected main branches on all repos, PRs need one approval. Using Claude Code.

> **NOVA:** Here's what I'll write. Review before I commit anything:
>
> 1. `.ai/workspace/AGENTS.md` — workspace identity (`acme-platform`, e-commerce product + infra) and the "no laptop apply to prod" override rule
> 2. `.ai/workspace/map/repos.md` — acme-api, acme-web, acme-infra with paths and stacks
> 3. `.ai/workspace/infra.md` — Terraform, EKS, AWS Secrets Manager
> 4. `.ai/workspace/SOUL.md` — skipping, default NOVA persona is fine for this workspace
> 5. `.claude/` adapter enabled
>
> Look good, or want to adjust anything first?

---

Once confirmed, NOVA writes the files and drops a `.ai/workspace/.initialized` sentinel so future sessions skip onboarding. Deleting that file or asking to reconfigure re-enters the flow.

## A few more flavors

**Skipping a topic:**

> **You:** Skip infra for now, we haven't decided.
>
> **NOVA:** Fine — I'll mark infra as TBD in the generated file and we can fill it in when you're ready. Moving on.

**Adding a repo later:**

> **You:** Add `acme-analytics` to the map — GitHub, same group, Python + dbt, internal data pipeline.
>
> **NOVA:** Adding. Should I treat it as critical (top-level in the map) or a satellite under `acme-platform`?

**First task after onboarding:**

> **You:** Let's add a new endpoint to acme-api.
>
> **NOVA:** Entering `acme-api`. Reading its `AGENTS.md`... Go + Postgres, gRPC-first, PRs require one approval. What's the endpoint — resource and behavior?
