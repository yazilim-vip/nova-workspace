# IntelliJ IDEA

Implementation detail of `ide` — generates IntelliJ project config (`.idea/`) from the NOVA workspace's cloned repos and optionally registers run configurations. Loaded on demand by the parent skill at `.ai/procedures/ide/PROCEDURE.md`.

## When to trigger

- "set up intellij", "generate idea config"
- "sync intellij", "intellij is missing my new repo", "I just cloned a repo, update intellij" → use the **`sync intellij` standalone flow** (incremental, no backup) rather than the full setup
- "register my repos as intellij modules", "add <repo> as an intellij module"
- "create a run configuration for <module>", "add a spring boot run config for chart-ai"
- User mentions IntelliJ isn't showing the cloned repos in the Project tool window

## What gets generated

Under `.idea/` at the workspace root (gitignored; per-developer):

| File | Purpose |
|------|---------|
| `.idea/modules.xml` | Project module manifest — lists every `.iml` with group path |
| `.idea/modules/<workspace>.iml` | Workspace-root module (AGENTS.md, .ai/, etc.) with `git-repositories/` excluded |
| `.idea/modules/<repo>.iml` | One per cloned repo — content root + build-output excludes |
| `.idea/vcs.xml` | VCS mappings — one per repo + workspace root |
| `.idea/misc.xml` | Project SDK + language level (safe defaults) |
| `.idea/encodings.xml` | UTF-8 default |
| `.idea/runConfigurations/<name>.xml` | Optional — proposed after module generation based on detected build tools |

Templates with `{{PLACEHOLDERS}}` live under `templates/`. Research notes on the XML format live under `references/`.

## Core flow: `set up intellij`

1. **Preflight**
   - Confirm `.ai/workspace/map/repos.md` exists. If not, ask the user to run onboarding first.
   - Confirm `git-repositories/` contains at least one directory with a `.git/` subfolder.
   - If `.idea/` already exists at the workspace root, back it up to `.idea.bak-<YYYYMMDDHHMMSS>/` and tell the user. Never silently overwrite.

2. **Scan**
   - Walk `git-repositories/` for directories containing `.git/` — this is the ground truth of what's cloned. **Use unbounded depth** — repos can be nested arbitrarily deep under `<platform>/<org-path>/`, including extra group levels (e.g., `gitlab/yazilim.vip/community/projects/<group>/<repo>`). A `find` with `-maxdepth N` will silently miss them.
   - Enrich each hit from `repos.md`: description, tech stack, human-readable name where available.
   - If a repo is cloned but absent from `repos.md`, include it with a warning.
   - If a repo is in `repos.md` but not cloned, skip it — and tell the user which.
   - **Nested project detection (monorepo case)** — for each cloned repo, peek inside it (depth ≤ 2) for build markers (`pom.xml`, `build.gradle[.kts]`, `package.json`, `go.mod`, `pyproject.toml`, `Cargo.toml`). See "Nested project detection" below for the heuristic and what to surface to the user.

3. **Confirm**
   - Show the user the module list (name, path, detected tech). Wait for go-ahead before writing anything.

4. **Generate `.idea/` baseline**
   - For each cloned repo, render `templates/module.iml.tpl` → `.idea/modules/<repo>.iml`.
   - Render a workspace-root module (`templates/module.iml.tpl` with the workspace-root excludes from `references/format.md`) → `.idea/modules/<workspace-name>.iml`.
   - Render `templates/modules.xml.tpl` → `.idea/modules.xml`, listing every `.iml` with a `group` attribute built from the platform + org path under `git-repositories/`.
   - Render `templates/vcs.xml.tpl` → `.idea/vcs.xml`, one `<mapping>` per cloned repo plus the workspace root.
   - Render `templates/misc.xml.tpl` → `.idea/misc.xml` with `JDK_21` / Java 21 default. Tell the user they can change this via Project Structure if wrong for their JDK.
   - Render `templates/encodings.xml.tpl` → `.idea/encodings.xml`.

5. **Propose run configurations (optional phase)**
   - Scan each module for build-tool markers (see the detection table below).
   - List candidate run configs to the user. Ask which to create. Never auto-write.
   - For each approved config, render the matching template from `templates/runConfigurations/` → `.idea/runConfigurations/<name>.xml`.
   - If the user says "skip run configs", honor it — they can add them later via the standalone flow.

6. **Report**
   - Modules created (count, group paths).
   - Run configs created (names, types).
   - Per-repo follow-ups:
     - "For Maven repos, right-click `pom.xml` in IntelliJ → **Add as Maven Project** to upgrade that module with proper dependency resolution."
     - "For Gradle repos, right-click `build.gradle[.kts]` → **Link Gradle Project**."
   - **Reload asymmetry — known IntelliJ behavior:** `modules.xml` auto-reloads as you write it; new `.iml` modules appear immediately. `vcs.xml` does **not** — IntelliJ caches VCS mappings, so newly added roots stay invisible to its UI until the user runs **File → Reload Project from Disk** (or restarts the IDE). Always tell the user: "If the VCS panel looks stale, run **File → Reload Project from Disk**."

## Standalone flow: `sync intellij` (incremental, no backup)

Triggered without full IDE setup — user wants to add new repos to an existing `.idea/` without rewriting the whole thing.

When to use over the core flow: every time *after* the first run. The core flow's backup-and-overwrite makes sense once; sync is the steady-state.

1. **Preflight** — confirm `.idea/` exists at the workspace root (if not, the user wants the core flow).

2. **Diff `.idea/modules.xml` vs. filesystem**

   ```
   filesystem repos = walk(git-repositories/) for .git directories  # unbounded depth — see core flow Phase 2
   registered modules = parse(.idea/modules.xml)        # source of truth: what we last wrote
   registered roots   = parse(.idea/vcs.xml)
   missing            = filesystem - registered modules
   stale              = registered modules - filesystem # cloned repo got deleted
   ```

   For each `missing` repo, also run **nested project detection** (see section below) — propose any sub-projects worth registering as separate modules.

3. **Confirm with the user.** Show the diff: "I'll add N modules: <list>. I'll remove M stale modules: <list>." Wait for go-ahead. If sub-projects were detected in any new repo, surface them as a separate question — don't auto-register.

4. **Surgical write — additions only**
   - For each missing repo, render `templates/module.iml.tpl` → `.idea/modules/<repo>.iml`.
   - Append one `<module ... group="<platform>/<org-path>" />` line to `.idea/modules.xml` inside `<modules>`.
   - Append one `<mapping directory="$PROJECT_DIR$/git-repositories/.../<repo>" vcs="Git" />` line to `.idea/vcs.xml` inside `<component name="VcsDirectoryMappings">`.
   - Do **not** rewrite or back up the rest of `.idea/`. This is intentional — preserves user customizations, run configs, scopes, hand-edited excludes.

5. **Surgical removal — stale modules**
   - For each stale module, delete `.idea/modules/<repo>.iml`.
   - Remove the `<module>` line from `modules.xml`.
   - Remove the `<mapping>` line from `vcs.xml`.

6. **Report** — additions, removals, and the explicit "if VCS panel looks stale, **File → Reload Project from Disk**" instruction.

## Standalone flow: `create a run config for <module>`

Triggered without full IDE setup — user wants a specific config.

1. Check `.idea/` exists at the workspace root. If not, offer to run `set up intellij` first.
2. Identify the target module by name or path.
3. Pick the matching template from `templates/runConfigurations/` using `references/run-configurations.md` as the type reference.
4. Prompt for any missing fields (main class, Gradle task, npm script, environment variables, working directory).
5. Write `.idea/runConfigurations/<user-named>.xml`. If a file with that name already exists, confirm before overwriting.
6. Report the path. Tell the user IntelliJ auto-reloads run configs while the project is open.

## Nested project detection

A cloned repo may contain multiple distinct sub-projects (a monorepo) that benefit from separate IntelliJ modules — e.g., a Spring Boot API in `api/` plus a React UI in `ui/` under one git root. Default behavior is one module per repo (rooted at the repo's top level). Nested detection extends that with an *opt-in* proposal: scan the repo shallowly, surface candidates, ask the user.

### Heuristic — when to flag a sub-directory as a candidate

Scan each cloned repo at **depth ≤ 2** for the following build markers:

| Marker | Hints at |
|--------|----------|
| `pom.xml` | Maven project |
| `build.gradle` / `build.gradle.kts` | Gradle project |
| `package.json` | Node / TypeScript project |
| `go.mod` | Go module |
| `pyproject.toml` / `requirements.txt` | Python project |
| `Cargo.toml` | Rust crate |

A sub-directory is a **candidate** when:
- It has at least one marker.
- The sub-directory is **not** already referenced by the root build file as part of a multi-module setup. Specifically:
  - Skip if root has `pom.xml` and the sub-dir is listed under `<modules>` (Maven multi-module — IntelliJ handles internally).
  - Skip if root has `settings.gradle[.kts]` and the sub-dir is listed via `include(...)` (Gradle multi-project — same).
  - Skip if root `package.json` declares `workspaces` and the sub-dir matches one (npm/Yarn workspaces — same).
- The sub-directory is **not** an excluded folder per `module.iml.tpl`'s exclude list (`node_modules/`, `target/`, `build/`, `vendor/`, `.venv/`, etc.).

### What to surface to the user

When candidates exist for a repo, **always ask** — never auto-register:

> "`<repo>` looks like it may have nested projects:
> - `<repo>/api/pom.xml` — Maven (Spring Boot? Java)
> - `<repo>/ui/package.json` — Node / React
>
> Register these as separate IntelliJ modules in addition to the repo-root module? (yes / pick a subset / no — just the repo root)"

Three valid outcomes:
1. **No additional modules** — keep the repo-root module only. The user already has Maven/Gradle multi-module or workspaces wired up at the root.
2. **One module per candidate** — write `.idea/modules/<repo>-<subdir>.iml` for each approved sub-project. Naming: `<repo>-<subdir>` (e.g., `gym-tracker-api`, `gym-tracker-ui`) to avoid collisions in `modules.xml`.
3. **Replace the repo-root module** — rare; only if the user explicitly says they don't want a module at the repo root. Default is to keep it (lets the user navigate top-level files like the README, scripts, docker-compose).

### When to skip the prompt

- `repos.md` declares `type: monorepo` AND has explicit sub-project entries — treat those as authoritative; register matching modules silently and move on. Still mention what was registered in the report.
- The repo has zero candidates — no prompt needed.

### Naming and grouping for sub-modules

- Module name: `<repo>-<subdir-relative-path-with-dashes>` (e.g., a candidate at `<repo>/services/auth/` becomes module `<repo>-services-auth`).
- Group: same as the parent repo's group, plus the repo name itself appended — so the IntelliJ Project tool window shows the sub-modules nested under their parent repo. E.g., if the parent repo's group is `gitlab/yazilim.vip/community/projects/gym-tracker`, the sub-module's group is `gitlab/yazilim.vip/community/projects/gym-tracker/gym-tracker`.
- Excludes: same set as `module.iml.tpl`, but pathed at the sub-directory's URL (`$MODULE_DIR$/../../git-repositories/.../<repo>/<subdir>/...`).

### Cross-references

- The "Run config detection table" still applies — once a sub-module exists, build-marker-based run-config proposals fire against the sub-module's path, not the repo root's.
- The "Excludes per module" rules in `module.iml.tpl` apply unchanged.

## Module generation details

### Location
All `.iml` files under `.idea/modules/<name>.iml`. Never write inside cloned repos.

### Type
Default `WEB_MODULE` — IntelliJ's safe generic type. Shows all files; no language commitments. Users upgrade specific modules by right-clicking the build file (`pom.xml`, `build.gradle`) → **Link Project**, and IntelliJ replaces the module with a properly-typed one.

### Grouping
Set `group="<platform>/<org-path>"` in `modules.xml` so the Project tool window shows nested folders, e.g. `github › yazilim-vip › gym-tracker`. Derive platform + org from the repo's path under `git-repositories/`.

### Excludes per module
Apply these to every generated repo `.iml` (the template has the full list with `$MODULE_DIR$`-relative URLs):

- `node_modules/`
- `target/` (Maven)
- `build/` (Gradle)
- `dist/`
- `out/`
- `.venv/`, `venv/`, `__pycache__/`
- `.gradle/`
- `vendor/` (Go, PHP)
- The repo's own `.idea/` if present (so we don't double-load its config)

The workspace-root module excludes `git-repositories/`, `.idea/`, and `scripts/` — see `references/format.md`.

Users override in the IDE with **Mark Directory As → Excluded / Sources** after first open.

### Collisions
Module names must be unique in `modules.xml`. If two cloned repos share a name (e.g. `application` across workshops), disambiguate by prefixing with the org-path: `workshops.k8s-workshop.application`. Tell the user when disambiguation kicks in so the module names in their tree make sense.

## Run config detection table

Scan each module for these markers. **Propose** — don't auto-write.

| Marker in repo | Proposed config | Template |
|----------------|-----------------|----------|
| `pom.xml` | Maven run config (default goal: `package`) | `runConfigurations/maven.xml.tpl` |
| `pom.xml` + Spring Boot parent or starter dep | Spring Boot app (prompt for main class, profile) | `runConfigurations/spring-boot.xml.tpl` |
| `build.gradle` / `build.gradle.kts` | Gradle run config (default task: `build`; `bootRun` if Spring Boot plugin detected) | `runConfigurations/gradle.xml.tpl` |
| `package.json` with `scripts.start` | npm `start` | `runConfigurations/npm.xml.tpl` |
| `package.json` with other scripts | One npm entry per script the user picks | `runConfigurations/npm.xml.tpl` |
| `go.mod` + `main.go` or `cmd/*/main.go` | Go Application | `runConfigurations/go.xml.tpl` |
| `requirements.txt` / `pyproject.toml` + a clear entry script | Python | `runConfigurations/python.xml.tpl` |
| Standalone main class in Java source (no build tool) | Application | `runConfigurations/application.xml.tpl` |
| Test classes with JUnit/TestNG | JUnit | `runConfigurations/junit.xml.tpl` |
| `*.sh` entry script at repo root (`run.sh`, `start.sh`) | Shell | `runConfigurations/shell.xml.tpl` |
| Multiple services across sibling modules that start together | Compound | `runConfigurations/compound.xml.tpl` |

## Safety rules

- **Never silently overwrite `.idea/`.** Always back up first; always confirm.
- **Never touch cloned repos.** All generated files live under the workspace `.idea/`. Repos are read-only during this procedure.
- **Never commit `.idea/` from this procedure.** It's gitignored for a reason — per-developer, regenerable.
- **Never generate run configs without the user's approval.** List candidates, wait for the user to pick.
- **If the user has a prior `.idea/` with hand-written files**, ask before overwriting each conflicting path. They may have customizations worth preserving.
- **Language level / JDK defaults are guesses.** Say so. Tell the user how to change it (Project Structure → Project → SDK / Language level).

## References

- `templates/` — XML templates with `{{PLACEHOLDERS}}` ready to fill.
- `templates/runConfigurations/` — one template per run config type.
- `references/format.md` — deep reference on `.idea/` file structure, macros (`$PROJECT_DIR$`, `$MODULE_DIR$`), and gotchas.
- `references/run-configurations.md` — reference + worked XML example per run config type.
