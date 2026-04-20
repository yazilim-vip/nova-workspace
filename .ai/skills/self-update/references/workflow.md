# Self-Update Workflow

End-to-end flow for the `self-update` skill. Read alongside `../SKILL.md`.

```mermaid
flowchart TD
    Start([User: "sync"]) --> Pre1{Git repo?}
    Pre1 -- No --> StopNotGit[Stop: needs git-tracked workspace]
    Pre1 -- Yes --> Pre2{Working tree clean?}
    Pre2 -- No --> StopDirty[Stop: ask user to commit/stash]
    Pre2 -- Yes --> Pre3{On main/trunk branch?}
    Pre3 -- No --> AskBranch[Ask which branch to update]
    Pre3 -- Yes --> Remotes[git remote -v<br/>inspect URLs]
    AskBranch --> Remotes

    Remotes --> Classify{Remote setup?}

    Classify -- "Only origin<br/>= canonical NOVA" --> CaseA
    Classify -- "origin = fork<br/>upstream = NOVA" --> Divergence
    Classify -- "No NOVA remote" --> OfferAdd[Offer: git remote add upstream<br/>github.com/yazilim-vip/nova-workspace]
    Classify -- "Mirror / renamed / ambiguous" --> AskUser[Ask user which remote<br/>is the NOVA source]

    OfferAdd --> AskUser
    AskUser --> Divergence

    Divergence{Local is behind...}
    Divergence -- "origin only" --> CaseA
    Divergence -- "upstream only" --> CaseB
    Divergence -- "both" --> CaseA
    Divergence -- "nothing" --> UpToDate[Report: already up to date]

    subgraph A[Case A — origin catch-up]
        CaseA[git fetch origin] --> AShow[Show incoming commits<br/>git log branch..origin/branch]
        AShow --> AConfirm{User confirms?}
        AConfirm -- No --> AStop[Stop]
        AConfirm -- Yes --> APull[git pull --ff-only origin branch]
        APull --> AOk{Fast-forward OK?}
        AOk -- No --> ADivergence[Surface divergence<br/>don't force merge — stop]
        AOk -- Yes --> ADone[Local caught up with origin]
    end

    ADone --> CheckUpstream{Case B<br/>also pending?}
    CheckUpstream -- No --> Done([Done])
    CheckUpstream -- Yes --> CaseB

    subgraph B[Case B — upstream NOVA review]
        CaseB[git fetch upstream] --> BSummary[Summarize:<br/>commit count, touched paths,<br/>grouped by area]
        BSummary --> BClassify[Classify each commit:<br/>new skill / compat update /<br/>conflicting / AGENTS.md /<br/>template / breaking / deprecation]
        BClassify --> BPlan[Present plan to user:<br/>apply as-is / needs decision / skip]
        BPlan --> BConfirm{User approves?}
        BConfirm -- No --> BAdjust[Adjust plan per user]
        BAdjust --> BConfirm
        BConfirm -- Yes --> BApply[Apply deliberately:<br/>cherry-pick / merge<br/>resolve conflicts manually]
        BApply --> BRecordSkips[Record skipped commits in<br/>.ai/workspace/learnings/<br/>upstream-skipped.md]
        BRecordSkips --> BValidate[Post-sync validation:<br/>skills table consistent<br/>template drift<br/>fork-specific checks]
        BValidate --> BEvolve[Update learnings:<br/>deprecations, convention shifts,<br/>frontmatter migrations]
    end

    BEvolve --> Done
    UpToDate --> Done

    classDef stop fill:#fee,stroke:#c33
    classDef done fill:#efe,stroke:#3a3
    classDef ask fill:#ffe,stroke:#aa3
    class StopNotGit,StopDirty,AStop,ADivergence stop
    class ADone,Done,UpToDate done
    class AskBranch,AskUser,OfferAdd,AConfirm,BConfirm,CheckUpstream ask
```

## How to read it

- **Preflight** (top) — bail early if the basics aren't met.
- **Classify remotes** — fork-in-the-road moment. Decide whether this is Case A (your own remote) or Case B (upstream NOVA).
- **Case A** (left) — simple fetch, show, fast-forward pull. Refuses to force a merge if local has diverged.
- **Case B** (right) — deliberate flow: fetch → classify → plan → confirm → apply → validate → learn. Skipped commits are recorded so they don't re-propose on the next sync.
- **Red** = stop/error, **yellow** = user input needed, **green** = success.
