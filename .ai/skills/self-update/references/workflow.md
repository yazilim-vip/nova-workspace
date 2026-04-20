# Self-Update Workflow

End-to-end flow for the `self-update` skill. Read alongside `../SKILL.md`.

```mermaid
flowchart TD
    Start([User asks to sync]) --> Pre1{Git repo?}
    Pre1 -- No --> StopNotGit[Stop — needs git-tracked workspace]
    Pre1 -- Yes --> Pre2{Working tree clean?}
    Pre2 -- No --> StopDirty[Stop — ask user to commit or stash]
    Pre2 -- Yes --> Pre3{On main or trunk branch?}
    Pre3 -- No --> AskBranch[Ask which branch to update]
    Pre3 -- Yes --> Remotes[Run: git remote -v, inspect URLs]
    AskBranch --> Remotes

    Remotes --> Classify{Remote setup?}

    Classify -- Only origin equals canonical NOVA --> Divergence
    Classify -- origin is fork and upstream is NOVA --> Divergence
    Classify -- No NOVA remote --> OfferAdd[Offer to add upstream remote pointing at yazilim-vip nova-workspace]
    Classify -- Mirror or renamed or ambiguous --> AskUser[Ask user which remote is the NOVA source]

    OfferAdd --> AskUser
    AskUser --> Divergence

    Divergence{Local is behind which remote?}
    Divergence -- origin only --> CaseA
    Divergence -- upstream only --> CaseB
    Divergence -- both --> CaseA
    Divergence -- nothing --> UpToDate[Report: already up to date]

    subgraph A[Case A — origin catch-up]
        CaseA[git fetch origin] --> AShow[Show incoming commits from branch to origin branch]
        AShow --> AConfirm{User confirms?}
        AConfirm -- No --> AStop[Stop]
        AConfirm -- Yes --> APull[git pull --ff-only origin branch]
        APull --> AOk{Fast-forward OK?}
        AOk -- No --> ADivergence[Surface divergence, do not force merge, stop]
        AOk -- Yes --> ADone[Local caught up with origin]
    end

    ADone --> CheckUpstream{Case B also pending?}
    CheckUpstream -- No --> Done([Done])
    CheckUpstream -- Yes --> CaseB

    subgraph B[Case B — upstream NOVA review]
        CaseB[git fetch upstream] --> BSummary[Summarize commit count, touched paths, grouped by area]
        BSummary --> BClassify[Classify each commit: new skill, compatible update, conflicting update, AGENTS change, template, breaking, deprecation]
        BClassify --> BPlan[Present plan: apply as-is, needs decision, skip]
        BPlan --> BConfirm{User approves?}
        BConfirm -- No --> BAdjust[Adjust plan per user]
        BAdjust --> BConfirm
        BConfirm -- Yes --> BApply[Apply deliberately via cherry-pick or merge, resolve conflicts manually]
        BApply --> BRecordSkips[Record skipped commits in .ai/workspace/learnings/upstream-skipped.md]
        BRecordSkips --> BValidate[Post-sync validation: skills table, template drift, fork checks]
        BValidate --> BEvolve[Update learnings: deprecations, convention shifts, frontmatter migrations]
    end

    BEvolve --> Done
    UpToDate --> Done

    classDef stop fill:#c62828,stroke:#8e0000,color:#ffffff
    classDef done fill:#2e7d32,stroke:#1b5e20,color:#ffffff
    classDef ask fill:#f9a825,stroke:#b28704,color:#000000
    class StopNotGit,StopDirty,AStop,ADivergence stop
    class ADone,Done,UpToDate done
    class AskBranch,AskUser,OfferAdd,AConfirm,BConfirm,CheckUpstream ask
```

## How to read it

- **Preflight** (top) — bail early if the basics are not met.
- **Classify remotes** — fork-in-the-road moment. Decide whether this is Case A (your own remote) or Case B (upstream NOVA).
- **Case A** (left) — simple fetch, show, fast-forward pull. Refuses to force a merge if local has diverged.
- **Case B** (right) — deliberate flow: fetch → classify → plan → confirm → apply → validate → learn. Skipped commits are recorded so they do not re-propose on the next sync.
- **Red** nodes mean stop or error, **yellow** means user input needed, **green** means success.
