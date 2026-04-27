# Notes — viewer adapters

Per-viewer implementations of the notes vault contract (`.ai/personal-knowledge-management/SKILL.md`). Same shape as `.ai/adapters/<coding-agent>/`: the contract is tool-neutral; adapters are opt-in per-viewer specifics.

## Why adapters

The vault is plain markdown. It works with `nvim`, `bat`, VS Code, or any markdown viewer with no setup. Some viewers add value worth the setup cost — Obsidian's graph view, backlinks, plugin ecosystem; Foam's VS Code-native experience; Logseq's outliner model. Each one comes with its own settings, plugins, and quirks that don't belong in the contract.

Adapters keep the contract clean and make viewer choice a per-developer, per-machine decision.

## Anti-duplication rule

If a rule applies to every notes vault, it belongs in `.ai/personal-knowledge-management/SKILL.md`. If it applies only to one viewer, it belongs under `.ai/personal-knowledge-management/adapters/<viewer>/`. Adapters reference the contract; they never restate or contradict it.

## Activation

Opt-in, on-demand. The user says "set up Obsidian for my notes" (or the equivalent for another viewer); the agent reads that adapter and runs its scaffold. No runtime declaration is required — viewer adapters configure the vault, they don't change agent behavior at runtime.

## Supported viewers

| Viewer | Subdirectory | Status |
|--------|--------------|--------|
| Obsidian | `obsidian/` | supported |

To use no viewer, skip this directory entirely. The vault is fully usable as plain markdown.

## When to trigger

- "set up Obsidian for my notes", "wire Obsidian to my vault" → `obsidian/README.md`
- Equivalent phrasings for any other viewer once added

## Adding a viewer

To add Foam, Logseq, plain-text, or any other viewer:

1. Create `.ai/personal-knowledge-management/adapters/<viewer>/README.md`.
2. Document: required installs, recommended config, vault settings file paths, manual one-time-per-machine steps, anti-patterns specific to this viewer.
3. Add a row to the Supported viewers table above.
4. Reference the vault contract — never restate it.
