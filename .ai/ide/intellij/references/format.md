# IntelliJ `.idea/` Format — Reference Notes

Deep reference for agents generating `.idea/` config files. Consulted when a template placeholder is ambiguous, a new file needs to be authored, or a user request lies outside the templates.

## `.idea/` directory layout

```
.idea/
├── modules.xml          # Project manifest — lists all modules
├── modules/             # Optional subfolder for .iml files (our convention)
│   ├── <workspace>.iml
│   ├── <repo-1>.iml
│   └── <repo-2>.iml
├── vcs.xml              # VCS directory mappings
├── misc.xml             # Project SDK + language level
├── encodings.xml        # File encoding defaults
├── workspace.xml        # Per-user UI/editor state — DO NOT generate; IntelliJ owns this
├── runConfigurations/   # Shared run configs — each *.xml is one config
│   └── <name>.xml
└── compiler.xml, inspectionProfiles/, etc.   # Optional — generate only when asked
```

`workspace.xml` is **per-user state** (open tabs, window layout, unshared run configs). Our procedure never writes it. If it doesn't exist, IntelliJ creates it on first open.

## Path macros

All `.idea/` files reference paths via macros — never raw absolute paths, so the project is portable between machines.

| Macro | Resolves to | Used in |
|-------|-------------|---------|
| `$PROJECT_DIR$` | Directory containing `.idea/` — the workspace root | `modules.xml`, `vcs.xml`, `runConfigurations/*.xml`, `.iml` when content lives outside the module directory |
| `$MODULE_DIR$` | Directory containing the `.iml` being parsed | `.iml` files when content root is adjacent to the `.iml` (NOT our case — we put `.iml` under `.idea/modules/`) |
| `$USER_HOME$` | User's home directory | Rarely — only for user-global references |
| `$MAVEN_REPOSITORY$` | Local Maven `~/.m2/repository` | Dependency URLs in Maven-imported modules |
| `$APPLICATION_CONFIG_DIR$` | IntelliJ's per-install config dir | Almost never in project files |

**Gotcha**: `$MODULE_DIR$` resolves relative to the `.iml` file's directory, **not** to the content root. When our `.iml` lives at `.idea/modules/<repo>.iml` but the content lives at `git-repositories/<platform>/<org>/<repo>/`, always use `$PROJECT_DIR$/...` in URLs — `$MODULE_DIR$` would point at `.idea/modules/` and break content roots.

## modules.xml

Declares every module in the project. One `<module>` element per `.iml` file.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="ProjectModuleManager">
    <modules>
      <module fileurl="file://$PROJECT_DIR$/.idea/modules/yazilim-vip-workspace.iml"
              filepath="$PROJECT_DIR$/.idea/modules/yazilim-vip-workspace.iml" />
      <module fileurl="file://$PROJECT_DIR$/.idea/modules/gym-tracker.iml"
              filepath="$PROJECT_DIR$/.idea/modules/gym-tracker.iml"
              group="github/yazilim-vip" />
      <module fileurl="file://$PROJECT_DIR$/.idea/modules/chart-ai.iml"
              filepath="$PROJECT_DIR$/.idea/modules/chart-ai.iml"
              group="gitlab/yazilim.vip/private/chart-ai" />
    </modules>
  </component>
</project>
```

### `<module>` attributes

| Attribute | Required | Purpose |
|-----------|----------|---------|
| `fileurl` | yes | `file://` URL to the `.iml` |
| `filepath` | yes | Plain path to the `.iml` — duplicates `fileurl` without the scheme (IntelliJ uses both for different operations) |
| `group` | no | Folder path in the Project tool window tree; `/` creates hierarchy. Omit for root-level modules |

### Rules
- Module names (the `.iml` basename) must be unique across the whole project. Disambiguate collisions by prefixing with the org path.
- `fileurl` and `filepath` must point to the same file.
- The `group` path is virtual — no folder is created on disk; IntelliJ only uses it to build the tool window tree.

## `.iml` — module file

Per-module config. Defines content roots, source folders, excludes, JDK, and dependencies.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<module type="WEB_MODULE" version="4">
  <component name="NewModuleRootManager">
    <content url="file://$PROJECT_DIR$/git-repositories/github/yazilim-vip/gym-tracker">
      <excludeFolder url="file://$PROJECT_DIR$/git-repositories/github/yazilim-vip/gym-tracker/node_modules" />
      <excludeFolder url="file://$PROJECT_DIR$/git-repositories/github/yazilim-vip/gym-tracker/build" />
      <excludeFolder url="file://$PROJECT_DIR$/git-repositories/github/yazilim-vip/gym-tracker/target" />
      <excludeFolder url="file://$PROJECT_DIR$/git-repositories/github/yazilim-vip/gym-tracker/dist" />
      <excludeFolder url="file://$PROJECT_DIR$/git-repositories/github/yazilim-vip/gym-tracker/out" />
      <excludeFolder url="file://$PROJECT_DIR$/git-repositories/github/yazilim-vip/gym-tracker/.gradle" />
      <excludeFolder url="file://$PROJECT_DIR$/git-repositories/github/yazilim-vip/gym-tracker/.idea" />
    </content>
    <orderEntry type="inheritedJdk" />
    <orderEntry type="sourceFolder" forTests="false" />
  </component>
</module>
```

### Module types

The `type` attribute on `<module>` signals the module's nature. Common values:

| Type | Purpose |
|------|---------|
| `WEB_MODULE` | Generic — no language commitments. **Our default** for content-root-only modules generated from repos. |
| `JAVA_MODULE` | Java module with source/test folders, language level, JDK |
| `PYTHON_MODULE` | Python — requires the Python plugin |
| `EMPTY_MODULE` | Truly empty — no content, no deps. Rare |

When IntelliJ auto-imports a Maven/Gradle project, it rewrites the module type to match the build tool's view — usually `JAVA_MODULE` with proper source/test folders. Our `WEB_MODULE` default is a bootstrap; users upgrade specific repos by "Link Maven/Gradle Project" from the IDE.

### `<content>` element

Declares a content root — a directory tree IntelliJ watches.

```xml
<content url="file://..."> 
  <sourceFolder url="file://.../src/main/java" isTestSource="false" />
  <sourceFolder url="file://.../src/test/java" isTestSource="true" />
  <excludeFolder url="file://.../build" />
</content>
```

- A module can have multiple `<content>` roots — but ours have one each (the repo directory).
- `<sourceFolder>` marks a directory as source (`isTestSource="false"`) or test (`isTestSource="true"`). Maven/Gradle imports populate these automatically; we leave them empty and let IntelliJ's plain file view handle everything.
- `<excludeFolder>` hides a subdirectory from indexing, searches, and diffing.
- `<resourceFolder>` marks a resource directory — rare, typically only added by Maven import.

### `<orderEntry>` elements

Module dependencies, in order:

```xml
<orderEntry type="inheritedJdk" />                                    <!-- use project SDK -->
<orderEntry type="jdk" jdkName="corretto-21" jdkType="JavaSDK" />     <!-- override SDK -->
<orderEntry type="sourceFolder" forTests="false" />                   <!-- module's own sources -->
<orderEntry type="module" module-name="core" />                       <!-- another module -->
<orderEntry type="library" name="spring-boot" level="project" />      <!-- named library -->
<orderEntry type="module-library">                                    <!-- ad-hoc library -->
  <library>
    <CLASSES><root url="jar://.../some.jar!/" /></CLASSES>
    <JAVADOC /><SOURCES />
  </library>
</orderEntry>
```

Our generated `.iml` files use only `inheritedJdk` + `sourceFolder` — dependencies come from the build tool import when the user triggers it.

### Content root overlap

IntelliJ refuses to load when two modules' content roots overlap. That's why the workspace-root module **must** exclude `git-repositories/` — each cloned repo is its own content root.

Workspace-root module excludes:
```xml
<content url="file://$PROJECT_DIR$">
  <excludeFolder url="file://$PROJECT_DIR$/git-repositories" />
  <excludeFolder url="file://$PROJECT_DIR$/.idea" />
  <excludeFolder url="file://$PROJECT_DIR$/scripts" />
</content>
```

## vcs.xml

Maps directories to VCS systems. For multi-repo workspaces: one entry per cloned repo plus the workspace itself.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="VcsDirectoryMappings">
    <mapping directory="$PROJECT_DIR$" vcs="Git" />
    <mapping directory="$PROJECT_DIR$/git-repositories/github/yazilim-vip/gym-tracker" vcs="Git" />
    <mapping directory="$PROJECT_DIR$/git-repositories/gitlab/yazilim.vip/private/chart-ai/chart-ai" vcs="Git" />
  </component>
</project>
```

### Rules

- **Separate mapping per repo.** Each cloned repo is a distinct Git root — IntelliJ's Git integration (status, branches, push/pull) operates per-mapping.
- **Supported vcs values**: `Git`, `Mercurial`, `Subversion`, `Perforce`. Stick to `Git` for our workspaces.
- **Detection fallback**: IntelliJ auto-detects Git roots under the project at first open. Explicit mappings are still preferred — detection is eventual and can misfire for nested repos.
- **No wildcards**: one mapping per directory; no globbing. If there are many repos, list them all.

## misc.xml

Project-level metadata: SDK, language level, compiler output root.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="ExternalStorageConfigurationManager" enabled="true" />
  <component name="FrameworkDetectionExcludesConfiguration">
    <file type="web" url="file://$PROJECT_DIR$" />
  </component>
  <component name="ProjectRootManager" version="2"
             languageLevel="JDK_21"
             default="true"
             project-jdk-name="21"
             project-jdk-type="JavaSDK">
    <output url="file://$PROJECT_DIR$/out" />
  </component>
</project>
```

### `ProjectRootManager` attributes

| Attribute | Values |
|-----------|--------|
| `languageLevel` | `JDK_1_8`, `JDK_11`, `JDK_17`, `JDK_21`, etc. |
| `project-jdk-name` | Any JDK name registered in IntelliJ's SDK list. User-specific. |
| `project-jdk-type` | `JavaSDK`, `KotlinSDK`, `Python SDK`, etc. |
| `default` | `true` if this SDK applies to modules with `inheritedJdk` |

Our defaults (`JDK_21` / name `"21"` / `JavaSDK`) are guesses — surface this to the user so they can pick the right JDK on first open.

### `ExternalStorageConfigurationManager`

When `enabled="true"`, Maven/Gradle imports store their module configs outside `.idea/` (under `.idea/modules.xml` pointing to external `.iml` files, or under `$USER_HOME$/.ideaLibSources/`). Keeps the committed `.idea/` clean when the build runs imports repeatedly.

### `FrameworkDetectionExcludesConfiguration`

Tells IntelliJ not to auto-suggest framework setup (e.g., "It looks like this is a Spring project, add the plugin?") for the workspace root. Prevents noise when the root isn't really a framework project.

## encodings.xml

Per-project file encoding override. Set UTF-8 everywhere — stops Windows-line-ending surprises on mixed-OS teams.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="Encoding">
    <file url="PROJECT" charset="UTF-8" />
  </component>
</project>
```

- `url="PROJECT"` means "apply to every file in the project."
- Additional `<file url="file://..." charset="..." />` entries can set per-directory overrides.

## Common gotchas

1. **XML must be well-formed.** IntelliJ silently drops components from a malformed `.idea/` file — the project opens but features quietly fail. Always close tags, quote attributes, escape `&`/`<`/`>` in values.
2. **Module name != filename base.** The module's display name is derived from the `.iml` basename (minus `.iml`). Changing the filename renames the module.
3. **Two modules with the same name** break `modules.xml`. IntelliJ accepts the file but only loads the first; the second silently disappears from the tree.
4. **Missing JDK at first open** shows as a banner ("Project SDK is not defined"). Not fatal — user picks one from the dropdown. But `project-jdk-name` referencing a JDK the user doesn't have reads as red in the UI.
5. **`.idea/` inside a cloned repo** is a common source of confusion. Our workspace `.idea/` and the repo's own `.idea/` coexist peacefully — IntelliJ only reads the workspace one because that's where we pointed it. But indexing can pick up stale `.iml` files inside the repo, which is why our excludes list them.
6. **Refresh issues**: after editing `.idea/` files while IntelliJ is open, use **File → Reload All from Disk** (⌘⇧A → "Synchronize") to pick up changes. Some components need IntelliJ restart.

## Minimal file set for a working project

These are all it takes for IntelliJ to open the workspace with modules visible:

1. `.idea/modules.xml` — listing every module
2. One `.iml` per module referenced in `modules.xml`
3. `.idea/vcs.xml` — for Git operations to light up
4. `.idea/misc.xml` — to avoid the "no SDK" banner

`encodings.xml`, `compiler.xml`, and the others are nice-to-have but optional. Always include `encodings.xml` to set the UTF-8 default.

## Sources

- JetBrains' own `intellij-sdk-docs` project `.idea/`: [modules.xml](https://github.com/JetBrains/intellij-sdk-docs/blob/main/.idea/modules.xml), [misc.xml](https://github.com/JetBrains/intellij-sdk-docs/blob/main/.idea/misc.xml), [vcs.xml](https://github.com/JetBrains/intellij-sdk-docs/blob/main/.idea/vcs.xml), [encodings.xml](https://github.com/JetBrains/intellij-sdk-docs/blob/main/.idea/encodings.xml)
- [Modules | IntelliJ IDEA Documentation](https://www.jetbrains.com/help/idea/creating-and-managing-modules.html)
- [Content roots | IntelliJ IDEA Documentation](https://www.jetbrains.com/help/idea/content-roots.html)
- [How to manage projects under Version Control Systems](https://intellij-support.jetbrains.com/hc/en-us/articles/206544839-How-to-manage-projects-under-Version-Control-Systems)
- [Configure projects | IntelliJ IDEA Documentation](https://www.jetbrains.com/help/idea/working-with-projects.html)
- [What Is the .idea Directory? — Baeldung](https://www.baeldung.com/intellij-idea-directory)
