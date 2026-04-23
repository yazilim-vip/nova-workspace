# IntelliJ Run Configurations — Reference Notes

Deep reference for authoring `.idea/runConfigurations/*.xml` files. Covers storage location, the common XML shell, and a worked example for each of the 11 supported types.

## Where run configs live

| Location | Scope | When to use |
|----------|-------|-------------|
| `.idea/runConfigurations/<name>.xml` | Per-project, committable (shared) | **Our default** — simple, universally recognized across IntelliJ versions |
| `.run/<name>.run.xml` | Per-project, committable (modern) | Since v2020.1. Lets configs live outside `.idea/` when `.idea/` is gitignored but configs are committed. Not our case — our `.idea/` is gitignored entirely, per-dev |
| `.idea/workspace.xml` under `<component name="RunManager">` | Per-user, inside the IDE-managed state file | Default when a user creates a config in the UI without ticking "Store as project file". We don't write here — `workspace.xml` is IntelliJ's territory |

Our procedure writes to `.idea/runConfigurations/<name>.xml`. Since `.idea/` is gitignored for NOVA workspaces, generated configs are per-developer — the templates stay committed, each dev regenerates.

## Common XML shell

Every run configuration XML follows the same outer structure:

```xml
<component name="ProjectRunConfigurationManager">
  <configuration default="false"
                 name="<display-name>"
                 type="<type-id>"
                 factoryName="<factory-name>">
    <!-- type-specific body -->
    <method v="2">
      <option name="Make" enabled="true" />   <!-- optional: triggers build before run -->
    </method>
  </configuration>
</component>
```

### Core attributes on `<configuration>`

| Attribute | Required | Purpose |
|-----------|----------|---------|
| `default` | yes | `false` for actual run configs; `true` for template defaults used by the "Edit Templates" UI — almost always `false` in our files |
| `name` | yes | Display name in the Run widget. Can contain spaces; use descriptive names |
| `type` | yes | Type ID — identifies the configuration kind. See the type catalog below |
| `factoryName` | for most types | Secondary ID when a type has multiple factories (e.g. JUnit supports JUnit, TestNG, Cucumber factories under different types, but Spring Boot's factory is "Spring Boot") |
| `folderName` | no | Groups this config under a folder in the Run widget tree. Strings are literal folder names |
| `nameIsGenerated` | no | `true` if IntelliJ auto-generated the name (e.g. from a test class name). For our templates, usually omit |
| `singleton` | no | `true` prevents multiple simultaneous instances. Default: false |

### The `<method>` element

Declares what IntelliJ should do before launching:

```xml
<method v="2">
  <option name="Make" enabled="true" />            <!-- Build the module -->
  <option name="MakeProject" enabled="true" />     <!-- Build entire project -->
  <option name="Gradle.BeforeRunTask" enabled="true" tasks="compile" />
  <option name="RunConfigurationTask" enabled="true" run_configuration_name="Prepare DB" run_configuration_type="ShConfigurationType" />
</method>
```

Empty `<method v="2" />` means "run directly, no pre-launch build." Most templates include `<option name="Make" enabled="true" />` for language-aware types so classes are compiled before launch.

### The `<envs>` / `<env>` elements

Environment variables for the run:

```xml
<envs>
  <env name="SPRING_PROFILES_ACTIVE" value="local" />
  <env name="DB_URL" value="jdbc:postgresql://localhost/dev" />
</envs>
```

Empty `<envs />` self-closing is valid when no vars are set.

## Type catalog — worked examples

Each section below shows the real XML IntelliJ writes for that type. Fields that differ between configs are called out.

### 1. Java Application — `type="Application"`

Plain Java main-class launch. The simplest type.

```xml
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="Run Main" type="Application" factoryName="Application">
    <option name="MAIN_CLASS_NAME" value="com.acme.Main" />
    <module name="acme-app" />
    <option name="VM_PARAMETERS" value="-Xmx2g -Dspring.profiles.active=local" />
    <option name="PROGRAM_PARAMETERS" value="--port=8080" />
    <option name="WORKING_DIRECTORY" value="$MODULE_WORKING_DIR$" />
    <envs>
      <env name="LOG_LEVEL" value="DEBUG" />
    </envs>
    <shortenClasspath name="ARGS_FILE" />
    <method v="2">
      <option name="Make" enabled="true" />
    </method>
  </configuration>
</component>
```

Key options:
- `MAIN_CLASS_NAME` — fully-qualified class with a `public static void main(String[])`
- `ALTERNATIVE_JRE_PATH` + `ALTERNATIVE_JRE_PATH_ENABLED="true"` — only when running on a non-project JRE (e.g. `BUNDLED` for an IDE plugin launch)
- `shortenClasspath` — `ARGS_FILE` handles long classpaths on Windows; safe default
- `$MODULE_WORKING_DIR$` — resolves to the module's directory at runtime

### 2. JUnit Test — `type="JUnit"`

Runs JUnit tests. Use `type="TestNG"` for TestNG.

```xml
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="FooTest" type="JUnit" factoryName="JUnit">
    <module name="acme-app" />
    <shortenClasspath name="ARGS_FILE" />
    <option name="PACKAGE_NAME" value="com.acme" />
    <option name="MAIN_CLASS_NAME" value="com.acme.FooTest" />
    <option name="METHOD_NAME" value="" />
    <option name="TEST_OBJECT" value="class" />
    <method v="2">
      <option name="Make" enabled="true" />
    </method>
  </configuration>
</component>
```

`TEST_OBJECT` drives which other options are used:
- `class` → uses `MAIN_CLASS_NAME`
- `method` → uses `MAIN_CLASS_NAME` + `METHOD_NAME`
- `package` → uses `PACKAGE_NAME`
- `directory` → adds `<option name="TEST_DIRECTORY" value="$PROJECT_DIR$/.../tests" />`
- `pattern` → adds `<option name="TEST_PATTERN" value="com.acme.*Test" />`
- `category` → uses JUnit `@Category` annotations

### 3. Spring Boot — `type="SpringBootApplicationConfigurationType"` factoryName="Spring Boot"

Requires the Spring Boot plugin (ships with Ultimate; available as plugin for Community).

```xml
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="Run chart-ai" type="SpringBootApplicationConfigurationType" factoryName="Spring Boot">
    <module name="chart-ai" />
    <option name="SPRING_BOOT_MAIN_CLASS" value="com.acme.chartai.ChartAiApplication" />
    <option name="ACTIVE_PROFILES" value="local,dev" />
    <option name="VM_PARAMETERS" value="-Xmx4g" />
    <option name="PROGRAM_PARAMETERS" value="--server.port=8090" />
    <option name="WORKING_DIRECTORY" value="$MODULE_WORKING_DIR$" />
    <option name="ALTERNATIVE_JRE_PATH" />
    <envs>
      <env name="DB_URL" value="jdbc:postgresql://localhost/chart_ai" />
    </envs>
    <method v="2">
      <option name="Make" enabled="true" />
    </method>
  </configuration>
</component>
```

Key options unique to Spring Boot:
- `SPRING_BOOT_MAIN_CLASS` — the `@SpringBootApplication`-annotated class
- `ACTIVE_PROFILES` — comma-separated profile names; gets folded into `--spring.profiles.active`
- `FRAME_DEACTIVATION_UPDATE_POLICY` / `RUNNING_APPLICATION_UPDATE_POLICY` — hot-reload policy on frame deactivation. Omit unless user asks.

Fallback if the Spring Boot plugin isn't available: use `gradle.xml.tpl` with task `bootRun`, or `maven.xml.tpl` with goal `spring-boot:run`.

### 4. Gradle — `type="GradleRunConfiguration"` factoryName="Gradle"

Runs Gradle tasks. Repo must be linked as a Gradle project first (**Link Gradle Project** from `build.gradle` context menu).

```xml
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="Build gym-tracker" type="GradleRunConfiguration" factoryName="Gradle">
    <ExternalSystemSettings>
      <option name="executionName" />
      <option name="externalProjectPath" value="$PROJECT_DIR$/git-repositories/github/yazilim-vip/gym-tracker" />
      <option name="externalSystemIdString" value="GRADLE" />
      <option name="scriptParameters" value="-x test --no-daemon" />
      <option name="taskDescriptions"><list /></option>
      <option name="taskNames">
        <list>
          <option value="clean" />
          <option value="build" />
        </list>
      </option>
      <option name="vmOptions" value="-Xmx2g" />
    </ExternalSystemSettings>
    <ExternalSystemDebugServerProcess>true</ExternalSystemDebugServerProcess>
    <ExternalSystemReattachDebugProcess>true</ExternalSystemReattachDebugProcess>
    <DebugAllEnabled>false</DebugAllEnabled>
    <method v="2" />
  </configuration>
</component>
```

Key options:
- `externalProjectPath` — absolute path to the repo (uses `$PROJECT_DIR$`)
- `taskNames` — each `<option value="taskName" />` is one task; list them in execution order
- `scriptParameters` — raw CLI args: `-x test`, `--no-daemon`, `-Pfoo=bar`
- `vmOptions` — JVM flags for the Gradle launcher itself

For Spring Boot Gradle projects, use `<option value="bootRun" />` as the single task.

### 5. Maven — `type="MavenRunConfiguration"` factoryName="Maven"

Runs Maven goals. Repo must be linked (**Add as Maven Project** from `pom.xml` context menu).

```xml
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="Package chart-ai" type="MavenRunConfiguration" factoryName="Maven">
    <MavenSettings>
      <option name="myGeneralSettings" />
      <option name="myRunnerSettings">
        <MavenRunnerSettings>
          <option name="delegateBuildToMaven" value="false" />
          <option name="environmentProperties"><map /></option>
          <option name="jreName" value="#USE_PROJECT_JDK" />
          <option name="mavenProperties"><map /></option>
          <option name="passParentEnv" value="true" />
          <option name="runMavenInBackground" value="true" />
          <option name="skipTests" value="false" />
          <option name="vmOptions" value="-Xmx2g" />
        </MavenRunnerSettings>
      </option>
      <option name="myRunnerParameters">
        <MavenRunnerParameters>
          <option name="cmdOptions" />
          <option name="profiles"><set /></option>
          <option name="goals">
            <list>
              <option value="clean" />
              <option value="package" />
            </list>
          </option>
          <option name="multimoduleDir" />
          <option name="pomFileName" />
          <option name="profilesMap"><map /></option>
          <option name="projectsCmdOptionValues"><list /></option>
          <option name="resolveToWorkspace" value="false" />
          <option name="workingDirPath" value="$PROJECT_DIR$/git-repositories/gitlab/yazilim.vip/private/chart-ai/chart-ai" />
        </MavenRunnerParameters>
      </option>
    </MavenSettings>
    <method v="2" />
  </configuration>
</component>
```

Verbose by design — Maven configs carry a lot of state. Key pieces:
- `workingDirPath` — path to the repo containing `pom.xml`
- `goals` — `<option value="..." />` per goal or `-D` flag
- `skipTests` — top-level flag; more reliable than `-DskipTests` in `goals`
- `vmOptions` — JVM flags for the Maven launcher
- `jreName="#USE_PROJECT_JDK"` — sentinel meaning "use the project SDK"; can be replaced with a configured JDK name

For Spring Boot: `<option value="spring-boot:run" />` as the single goal.

### 6. Shell Script — `type="ShConfigurationType"`

No `factoryName`. Two modes — choose via `EXECUTE_SCRIPT_FILE`:

**Mode A — inline** (`EXECUTE_SCRIPT_FILE="false"`):

```xml
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="Start Heroic" type="ShConfigurationType">
    <option name="SCRIPT_TEXT" value="pnpm start" />
    <option name="INDEPENDENT_SCRIPT_PATH" value="true" />
    <option name="SCRIPT_PATH" value="" />
    <option name="SCRIPT_OPTIONS" value="" />
    <option name="INDEPENDENT_SCRIPT_WORKING_DIRECTORY" value="true" />
    <option name="SCRIPT_WORKING_DIRECTORY" value="$PROJECT_DIR$" />
    <option name="INDEPENDENT_INTERPRETER_PATH" value="true" />
    <option name="INTERPRETER_PATH" value="/bin/bash" />
    <option name="INTERPRETER_OPTIONS" value="" />
    <option name="EXECUTE_IN_TERMINAL" value="false" />
    <option name="EXECUTE_SCRIPT_FILE" value="false" />
    <envs />
    <method v="2" />
  </configuration>
</component>
```

**Mode B — script file** (`EXECUTE_SCRIPT_FILE="true"`):

```xml
<option name="SCRIPT_TEXT" value="" />
<option name="SCRIPT_PATH" value="$PROJECT_DIR$/git-repositories/github/yazilim-vip/<repo>/run.sh" />
<option name="SCRIPT_OPTIONS" value="--env=dev" />
<option name="EXECUTE_SCRIPT_FILE" value="true" />
```

Other options:
- `EXECUTE_IN_TERMINAL` — `true` to open an IDE terminal tab instead of the Run tool window. Nice for interactive scripts
- `INTERPRETER_PATH` — `/bin/bash`, `/bin/zsh`, `pwsh.exe` on Windows; any shell

### 7. Node.js — `type="NodeJSConfigurationType"` factoryName="Node.js"

Direct `node` invocation on a JS file. For npm scripts, use the npm type instead.

```xml
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="Start API"
                 type="NodeJSConfigurationType"
                 factoryName="Node.js"
                 path-to-node="project"
                 path-to-js-file="bin/www"
                 working-dir="$PROJECT_DIR$/git-repositories/github/yazilim-vip/<repo>">
    <envs>
      <env name="DEBUG" value="acme:*" />
      <env name="PORT" value="3000" />
    </envs>
    <method v="2" />
  </configuration>
</component>
```

Note the unusual shape: several fields are **attributes on `<configuration>`** rather than `<option>` children:
- `path-to-node` — `"project"` uses the project's Node interpreter; absolute path overrides
- `path-to-js-file` — entry script, relative to `working-dir` or absolute
- `working-dir` — execution cwd

Optional `<browser url="http://localhost:3000/" />` child — pops a browser when the app starts.

### 8. npm — `type="js.build_tools.npm"`

Runs `npm <command> [script]`. Also handles yarn/pnpm if the user's package.json uses them (interpreter-dependent).

```xml
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="build" type="js.build_tools.npm">
    <package-json value="$PROJECT_DIR$/git-repositories/github/yazilim-vip/<repo>/package.json" />
    <command value="run" />
    <scripts>
      <script value="build" />
    </scripts>
    <node-interpreter value="project" />
    <envs />
    <method v="2" />
  </configuration>
</component>
```

- `<command>` — `run`, `install`, `test`, `start`, `ci`
- `<scripts>` — only meaningful when `command="run"`; the script key from `package.json`'s `scripts` block
- `<node-interpreter>` — `"project"` uses the project setting; absolute path overrides
- `<package-json>` — absolute path to the `package.json`; use `$PROJECT_DIR$` macro

### 9. Go Application — `type="GoApplicationRunConfiguration"` factoryName="Go Application"

Requires the Go plugin (or use GoLand).

```xml
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="Run pyroscope" type="GoApplicationRunConfiguration" factoryName="Go Application">
    <module name="pyroscope" />
    <working_directory value="$PROJECT_DIR$/git-repositories/github/<org>/pyroscope" />
    <go_parameters value="-tags embedassets" />
    <parameters value="-storage.backend=filesystem" />
    <kind value="FILE" />
    <package value="github.com/grafana/pyroscope" />
    <directory value="$PROJECT_DIR$/git-repositories/github/<org>/pyroscope" />
    <filePath value="$PROJECT_DIR$/git-repositories/github/<org>/pyroscope/cmd/pyroscope/main.go" />
    <envs />
    <method v="2" />
  </configuration>
</component>
```

`kind` selects which of `package`/`directory`/`filePath` is authoritative:
- `FILE` — launch a single `main.go` from `filePath`
- `PACKAGE` — launch a Go module path from `package`
- `DIRECTORY` — launch the main package under `directory`

Other fields:
- `go_parameters` — flags for `go` tool itself (e.g. `-tags`, `-ldflags`)
- `parameters` — flags for the built binary

### 10. Python — `type="PythonConfigurationType"` factoryName="Python"

Requires the Python plugin (or use PyCharm).

```xml
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="Run bookmarks-mcp" type="PythonConfigurationType" factoryName="Python">
    <module name="bookmarks-mcp" />
    <option name="INTERPRETER_OPTIONS" value="-u" />
    <option name="PARENT_ENVS" value="true" />
    <envs>
      <env name="PYTHONUNBUFFERED" value="1" />
    </envs>
    <option name="SDK_HOME" value="" />
    <option name="WORKING_DIRECTORY" value="$PROJECT_DIR$/git-repositories/github/yazilim-vip/bookmarks-mcp" />
    <option name="IS_MODULE_SDK" value="true" />
    <option name="ADD_CONTENT_ROOTS" value="true" />
    <option name="ADD_SOURCE_ROOTS" value="true" />
    <option name="SCRIPT_NAME" value="$PROJECT_DIR$/git-repositories/github/yazilim-vip/bookmarks-mcp/main.py" />
    <option name="PARAMETERS" value="" />
    <option name="SHOW_COMMAND_LINE" value="false" />
    <RunnerSettings RunnerId="PythonRunner" />
    <ConfigurationWrapper RunnerId="PythonRunner" />
    <method v="2" />
  </configuration>
</component>
```

Key options:
- `IS_MODULE_SDK="true"` — use the module's configured Python interpreter. Set to `false` and fill `SDK_HOME` to override with a specific python binary path
- `ADD_CONTENT_ROOTS` / `ADD_SOURCE_ROOTS` — add these to `PYTHONPATH`; keep `true` for normal imports
- `SCRIPT_NAME` — absolute path to the `.py` entry
- `INTERPRETER_OPTIONS` — `python`'s own flags (`-u` unbuffered, `-O` optimize)
- The two orphan-looking `<RunnerSettings>` / `<ConfigurationWrapper>` elements are required — IntelliJ rejects the config without them

### 11. Compound — `type="CompoundRunConfigurationType"`

Runs a set of existing configs together. No `factoryName`.

```xml
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="all-services" type="CompoundRunConfigurationType">
    <toRun name="Run chart-ai" type="SpringBootApplicationConfigurationType" />
    <toRun name="Start API" type="js.build_tools.npm" />
    <toRun name="Start frontend" type="js.build_tools.npm" />
    <toRun name="Docker-compose up -d" type="ShConfigurationType" />
    <method v="2" />
  </configuration>
</component>
```

Each `<toRun>` references another config by exact `name` + `type`. If the referenced config doesn't exist, IntelliJ silently skips it at launch — no error. **Always verify both name and type match before writing.**

Nesting compound configs (compound → compound → other) works.

## Authoring checklist

When generating a run config from a template, verify:

1. **`name` is unique** within `.idea/runConfigurations/` — same name collides (IntelliJ picks one). Use descriptive names: "Run chart-ai (local)", not "Run".
2. **`type` matches the file body** — mixing `type="Application"` with Spring Boot's options won't work.
3. **Paths use `$PROJECT_DIR$`** — never raw `/Users/...` or `/home/...`.
4. **Module references** (`<module name="..." />`) must match an actual `.iml` basename — otherwise the config errors at launch.
5. **XML is well-formed** — close every tag, quote every attribute, escape `&` → `&amp;`, `<` → `&lt;`, `"` → `&quot;` in attribute values.
6. **Filename matches the `name` attribute** — IntelliJ loads the file by filename, displays by `name`. Differences won't break things but confuse users searching for configs by name.

## Sources

- JetBrains `intellij-community` run configs: [ApiCheckTest.xml (JUnit)](https://github.com/JetBrains/intellij-community/blob/master/.idea/runConfigurations/ApiCheckTest.xml), [Android_Studio (Application)](https://github.com/JetBrains/intellij-community/blob/master/.idea/runConfigurations/Android_Studio__dev_build__.xml)
- Real Spring Boot example: [daggerok/kotlin-webflux-mvc](https://github.com/daggerok/kotlin-webflux-mvc/blob/master/.idea/runConfigurations/webflux.xml)
- Real Shell example: [Heroic-Games-Launcher](https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/blob/main/.idea/runConfigurations/Launch_Heroic.xml)
- Real npm example: [zdhxiong/mdui](https://github.com/zdhxiong/mdui/blob/master/.idea/runConfigurations/build.xml)
- Real Maven example: [DependencyTrack](https://github.com/DependencyTrack/dependency-track/blob/master/.idea/runConfigurations/Jetty.run.xml)
- Real Go example: [grafana/pyroscope](https://github.com/grafana/pyroscope/blob/main/.idea/runConfigurations/v2.xml)
- Real Python example: [AndroidViewClient](https://github.com/dtmilano/AndroidViewClient/blob/master/.idea/runConfigurations/dump.xml)
- Real Compound example: [crispab/codekvast](https://github.com/crispab/codekvast/blob/master/.idea/runConfigurations/all_services.xml)
- [Run/debug configurations | IntelliJ IDEA Documentation](https://www.jetbrains.com/help/idea/run-debug-configuration.html)
- [Run Configurations Tutorial | IntelliJ Platform Plugin SDK](https://plugins.jetbrains.com/docs/intellij/run-configurations-tutorial.html)
- [How to share run configurations in IntelliJ IDEA — Vojtech Ruzicka](https://www.vojtechruzicka.com/idea-sharing-run-configurations/)
