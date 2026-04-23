# IntelliJ IDEA

Framework procedure — generate IntelliJ project config (`.idea/`) from the NOVA workspace's cloned repos, and optionally register run configurations.

## When to trigger

- "set up intellij", "generate idea config"
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
   - Walk `git-repositories/` for directories containing `.git/` — this is the ground truth of what's cloned.
   - Enrich each hit from `repos.md`: description, tech stack, human-readable name where available.
   - If a repo is cloned but absent from `repos.md`, include it with a warning.
   - If a repo is in `repos.md` but not cloned, skip it — and tell the user which.

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

## Standalone flow: `create a run config for <module>`

Triggered without full IDE setup — user wants a specific config.

1. Check `.idea/` exists at the workspace root. If not, offer to run `set up intellij` first.
2. Identify the target module by name or path.
3. Pick the matching template from `templates/runConfigurations/` using `references/run-configurations.md` as the type reference.
4. Prompt for any missing fields (main class, Gradle task, npm script, environment variables, working directory).
5. Write `.idea/runConfigurations/<user-named>.xml`. If a file with that name already exists, confirm before overwriting.
6. Report the path. Tell the user IntelliJ auto-reloads run configs while the project is open.

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
