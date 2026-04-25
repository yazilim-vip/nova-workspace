# Claude + IntelliJ IDEA MCP — capability doctrine

Strict rules for Claude Code sessions running **inside an IntelliJ IDEA terminal pane**, where the IDEA MCP server (built-in since IntelliJ 2025.2 — see [JetBrains MCP Server docs](https://www.jetbrains.com/help/idea/mcp-server.html)) auto-attaches and exposes `mcp__idea__*` tools against the running IntelliJ instance.

This file is `@`-imported by `.claude/CLAUDE.md`. Whether it applies is a **declared workspace property**, not runtime detection — see "Activation" below.

> **Anti-duplication.** This file owns *which IDEA MCP tool to prefer when*. It does not restate NOVA safety or navigation rules. Reference paths (`AGENTS.md:<line>`, `.ai/workspace/AGENTS.md:<line>`); never paraphrase.

## Activation

Active when `.ai/workspace/AGENTS.md` declares `intellij` in the workspace's host-environments list (see the workspace AGENTS.md template's "Host Environments" section).

If the user has not declared IntelliJ as a host, **ignore this entire file** — the rules below do not apply, and you must not invoke `mcp__idea__*` tools even if the harness happens to expose them.

If the workspace AGENTS.md has no Host Environments section at all, the workspace was onboarded before this convention existed — flag it once to the user, suggest they add the section, then default to inactive.

## Workspace shape — critical context

Our `.ai/ide/intellij/` procedure generates **one** `.idea/` at the workspace root with **every cloned repo registered as a module**. This is non-obvious and has consequences:

- All `mcp__idea__*` tools operate on the **whole workspace** unless scoped. Project-wide search hits all repos. `build_project` (with no `filesToRebuild`) compiles every module.
- **`rename_refactoring` has cross-repo blast radius.** If two repos coincidentally share a class name (`Application`, `Config`, `User`), a project-wide rename can edit both. Always pre-check usages with `search_symbol` scoped via `paths` glob to the target repo's `git-repositories/<platform>/<org>/<repo>/**` prefix before renaming.
- **Always pass `projectPath`** to every tool call. Set it to the workspace root (the directory containing `.idea/`). The schema says "ALWAYS pass this if known" — for our setup it's always known.
- **Confirm scope before any state-changing tool.** Tell the user "this will affect <N> modules / files matching <pattern>" before invoking refactor / build / SQL / terminal.

## Decision table — prefer IDEA MCP over shell when…

| Task | Prefer | Over | Why |
|------|--------|------|-----|
| Find a symbol's definition / usages in a JVM repo | `mcp__idea__search_symbol` (scope with `paths` to one repo), `mcp__idea__get_symbol_info` | `grep`, `Bash rg` | PSI-resolved — handles overloads, imports, aliases, generics. Grep can't disambiguate. |
| Rename a class / method / field across a JVM repo | `mcp__idea__rename_refactoring` (after pre-checking usages) | `Edit replace_all`, `sed` | Safe across imports, references, XML config, Spring bean names. Text replace breaks on shadowed names. |
| Check compile status after editing Java/Kotlin | `mcp__idea__get_file_problems`, then `mcp__idea__build_project` with `filesToRebuild: [<changed paths>]` if needed | `mvn compile`, `gradle build` from Bash | Faster; uses IntelliJ's incremental compiler. Use `filesToRebuild` to avoid building the whole workspace. Only shell out for full CI-equivalent verification. |
| Run a configured app / test from `.idea/runConfigurations/` | `mcp__idea__execute_run_configuration` (after `get_run_configurations` to list) | `mvn spring-boot:run`, `gradle bootRun` | Honors the run config the user already set up via `.ai/ide/intellij/`. No env-var drift. |
| Inspect schema of a dev DB the user has connected | `list_database_connections` → `list_database_schemas` → `list_schema_objects` → `preview_table_data` / `execute_sql_query` | `psql`, `mysql` from Bash | Reuses the user's IntelliJ Database Tool Window connection — no credentials in shell history. **Requires the Database Tools plugin (Ultimate); silently absent on Community Edition.** |
| Project text search honoring scopes / excludes | `search_in_files_by_text`, `search_in_files_by_regex` (scope with `directoryToSearch` + `fileMask`) | `Bash rg` | Indexed; auto-skips `target/`, `node_modules/`, `build/` per IntelliJ's project model. |
| Find files when you only know a name fragment | `mcp__idea__find_files_by_name_keyword` | `find`, `fd`, glob | JetBrains docs explicitly call this the fastest method — backed by the filename index. |
| Find files by glob pattern | `mcp__idea__find_files_by_glob` or `search_file` | `find -name`, `Bash ls` | Indexed; understands project content roots. |
| List a directory's contents | `mcp__idea__list_directory_tree` | `ls`, `tree` Bash | JetBrains docs: "MUST prefer this tool over `ls` or `dir`." |
| Reformat a file before commit | `mcp__idea__reformat_file` | nothing equivalent | Applies the project's IntelliJ code style (`.idea/codeStyles/`) — matches what the user's IDE will reformat to anyway. |
| Project module / dependency / VCS-root reasoning | `get_project_modules`, `get_project_dependencies`, `get_repositories` | parsing `pom.xml` / `build.gradle` / `git remote -v` by hand | Authoritative — what IntelliJ resolved + every VCS root in the workspace. |
| Know which file the user is currently looking at | `mcp__idea__get_all_open_file_paths` | guessing | No shell equivalent. Active editor + other open tabs. Useful before suggesting "look at file X" — they may already have it open. |
| Surface a file the user should look at | `mcp__idea__open_file_in_editor` | quoting `<path>:<line>` and hoping | Pops the file open in their IDE. Use after edits or when surfacing a finding. |
| Targeted in-file edit when paths are known | `mcp__idea__replace_text_in_file` (use `regex: true` and `caseSensitive: false` when the surrounding text varies) | `Edit replace_all` | File auto-saved after modification; flags handle case-variant matches without read-modify-write. |
| Run a Jupyter notebook cell | `mcp__idea__runNotebookCell` | shelling out to `jupyter` | Reuses the IDE's kernel session; preserves notebook state. |

## When NOT to use IDEA MCP (even when active)

- **Scripts, dotfiles, prose, markdown, YAML, shell**: use Bash/Read/Edit. PSI tools are for JVM (Java/Kotlin/Groovy/Scala) and IntelliJ-supported web stacks.
- **Speculative or read-only navigation in unfamiliar code**: prefer cheap `Read` and `Grep` first. Only escalate to PSI tools when you have a specific symbol or refactor in mind.
- **Anything outside the IntelliJ project's content roots**: IDEA MCP can't see them. Verify with `get_project_modules` if unsure.
- **CI-equivalent verification before merge**: shell out to the actual `mvn` / `gradle` so the result matches what CI will produce. `build_project` is for *feedback loops*, not pre-merge gates.

## Custom inspections — FlexInspect / `.inspection.kts`

[FlexInspect](https://www.jetbrains.com/help/qodana/flexinspect.html) lets you write custom IntelliJ inspections as Kotlin scripts that run **both live in the IDE and in Qodana CI** (Ultimate / Ultimate Plus). The same file gates regressions in both surfaces — no duplication.

**Layout (per JetBrains spec):**
- File extension: `.inspection.kts` (note the leading dot in the extension itself).
- Location: an `inspections/` directory at the **project root** (the repo root), *not* `.ai/`. The directory name and file extension are conventions FlexInspect's runner expects.
- Script content: Kotlin using IntelliJ's PSI (Program Structure Interface) API.

**Doctrine for the agent:**
- **Propose, don't auto-write.** When you spot a recurring rule the user keeps re-stating (e.g., "no provider specifics past the extractor layer" — Chart AI memory), suggest an inspection — wait for go-ahead before authoring.
- **Authoring loop:**
  1. `generate_inspection_kts_api` (Java or Kotlin) → docs of the API surface.
  2. `generate_inspection_kts_examples` → reference templates.
  3. `generate_psi_tree` against a small code snippet that should trigger / not trigger the rule → understand the AST you need to match.
  4. Draft the script.
  5. `validate_inspection_kts` against a spec file with positive + negative examples — confirms it triggers where intended and doesn't elsewhere.
  6. `run_inspection_kts` against real files in the repo for a final smoke test.
- **Note:** `generate_psi_tree` parses a *provided code snippet string*, not an existing project file. It's a tool for inspection authoring, not for analyzing real files — don't confuse the two.

## Permissions and confirmation

IntelliJ ships with **"Brave Mode" off by default** (Settings → Tools → MCP Server). With Brave Mode off, IntelliJ itself prompts the user before each terminal-command / run-config / SQL / build invocation. The agent's own confirmation per `AGENTS.md` "Executing actions with care" stacks on top of that — don't rely on Brave Mode being on.

State-changing tools to confirm before invoking: `execute_terminal_command`, `execute_run_configuration`, `execute_sql_query`, `build_project`, `rename_refactoring`, `create_new_file`, `replace_text_in_file`, `reformat_file`, `runNotebookCell`.

If `mcp__idea__permission_prompt` returns a denial, surface it to the user — do not retry blindly.

## Cross-references

- `.ai/ide/intellij/README.md` — the one-shot procedure that generates `.idea/` modules and run configs. The MCP doctrine here is the runtime counterpart.
- `.ai/adapters/claude/README.md` — capability mapping table; the host-environment row note points here.
- `.ai/onboarding/README.md` — the onboarding question that captures host environments and writes the declaration into `.ai/workspace/AGENTS.md`.
- `AGENTS.md` "Executing actions with care" — confirmation bar for state-changing tools applies to IDEA MCP too.
- [JetBrains MCP Server docs](https://www.jetbrains.com/help/idea/mcp-server.html), [FlexInspect](https://www.jetbrains.com/help/qodana/flexinspect.html), [Custom inspections](https://www.jetbrains.com/help/idea/creating-custom-inspections.html).
