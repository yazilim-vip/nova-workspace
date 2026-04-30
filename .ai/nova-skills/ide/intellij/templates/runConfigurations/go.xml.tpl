<?xml version="1.0" encoding="UTF-8"?>
<!--
  Template: .idea/runConfigurations/<name>.xml  (Go Application)
  type="GoApplicationRunConfiguration" factoryName="Go Application"

  Requires the Go plugin installed in IntelliJ (or use GoLand, where it's built in).

  Placeholders:
    {{NAME}}          — config name, e.g. "Run pyroscope"
    {{MODULE}}        — IntelliJ module name that owns the Go source
    {{WORKING_DIR}}   — absolute path to the repo with $PROJECT_DIR$ macro
    {{GO_PARAMETERS}} — flags for the `go` tool itself, e.g. "-tags embedassets"
    {{PARAMETERS}}    — flags passed to the compiled binary, e.g. "-storage.backend=filesystem"
    {{KIND}}          — one of: FILE, PACKAGE, DIRECTORY
    {{PACKAGE}}       — Go package path (when KIND=PACKAGE), e.g. "github.com/grafana/pyroscope"
    {{DIRECTORY}}     — directory path (when KIND=DIRECTORY), e.g. $PROJECT_DIR$/.../cmd/app
    {{FILE_PATH}}     — file path (when KIND=FILE), e.g. $PROJECT_DIR$/.../cmd/app/main.go
    {{ENV_VARS}}      — <env name="K" value="V" /> entries (may be empty)

  Common kinds:
    KIND=FILE       → FILE_PATH points at a single main.go
    KIND=PACKAGE    → PACKAGE is a full module path; DIRECTORY + FILE_PATH ignored
    KIND=DIRECTORY  → DIRECTORY is a local dir containing a main package
-->
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="{{NAME}}" type="GoApplicationRunConfiguration" factoryName="Go Application">
    <module name="{{MODULE}}" />
    <working_directory value="{{WORKING_DIR}}" />
    <go_parameters value="{{GO_PARAMETERS}}" />
    <parameters value="{{PARAMETERS}}" />
    <kind value="{{KIND}}" />
    <package value="{{PACKAGE}}" />
    <directory value="{{DIRECTORY}}" />
    <filePath value="{{FILE_PATH}}" />
    <envs>
{{ENV_VARS}}
    </envs>
    <method v="2" />
  </configuration>
</component>
