<?xml version="1.0" encoding="UTF-8"?>
<!--
  Template: .idea/runConfigurations/<name>.xml  (Java Application)
  type="Application" — plain Java main-class launch. No build tool required.

  Placeholders:
    {{NAME}}               — human-readable config name, e.g. "Run Main"
    {{MODULE}}             — IntelliJ module name that owns the main class (from .iml)
    {{MAIN_CLASS}}         — fully-qualified class name, e.g. com.acme.Main
    {{VM_PARAMETERS}}      — JVM flags string, e.g. "-Xmx2g -Dfoo=bar" (may be empty)
    {{PROGRAM_PARAMETERS}} — program args string (may be empty)
    {{WORKING_DIRECTORY}}  — resolved path or macro; use $MODULE_WORKING_DIR$ by default
    {{ENV_VARS}}           — newline-joined <env name="KEY" value="VAL" /> entries (may be empty)

  Omit <option name="ALTERNATIVE_JRE_PATH" .../> unless user specifies a non-project JRE.
-->
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="{{NAME}}" type="Application" factoryName="Application">
    <option name="MAIN_CLASS_NAME" value="{{MAIN_CLASS}}" />
    <module name="{{MODULE}}" />
    <option name="VM_PARAMETERS" value="{{VM_PARAMETERS}}" />
    <option name="PROGRAM_PARAMETERS" value="{{PROGRAM_PARAMETERS}}" />
    <option name="WORKING_DIRECTORY" value="{{WORKING_DIRECTORY}}" />
    <envs>
{{ENV_VARS}}
    </envs>
    <shortenClasspath name="ARGS_FILE" />
    <method v="2">
      <option name="Make" enabled="true" />
    </method>
  </configuration>
</component>
