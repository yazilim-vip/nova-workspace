<?xml version="1.0" encoding="UTF-8"?>
<!--
  Template: .idea/runConfigurations/<name>.xml  (Shell script)
  type="ShConfigurationType"

  Two execution modes — the template supports both; flip EXECUTE_SCRIPT_FILE:

    Mode A — inline script text (EXECUTE_SCRIPT_FILE=false):
      Runs SCRIPT_TEXT via INTERPRETER_PATH. Use for one-liners like "pnpm start".
      SCRIPT_PATH should be empty.

    Mode B — external script file (EXECUTE_SCRIPT_FILE=true):
      Runs the file at SCRIPT_PATH with SCRIPT_OPTIONS. Use for repo-owned *.sh files.
      SCRIPT_TEXT should be empty.

  Placeholders:
    {{NAME}}                       — config name, e.g. "Start gym-tracker"
    {{SCRIPT_TEXT}}                — inline shell command (Mode A); else empty
    {{SCRIPT_PATH}}                — absolute path to a .sh file (Mode B); else empty
    {{SCRIPT_OPTIONS}}             — args passed to the script in Mode B (may be empty)
    {{SCRIPT_WORKING_DIRECTORY}}   — working dir, usually $PROJECT_DIR$/git-repositories/.../<repo>
    {{INTERPRETER_PATH}}           — shell binary path, default: /bin/bash
    {{EXECUTE_IN_TERMINAL}}        — "true" to run in IDE's terminal, "false" for Run tool window
    {{EXECUTE_SCRIPT_FILE}}        — "true" for Mode B, "false" for Mode A
    {{ENV_VARS}}                   — <env name="K" value="V" /> entries (may be empty)
-->
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="{{NAME}}" type="ShConfigurationType">
    <option name="SCRIPT_TEXT" value="{{SCRIPT_TEXT}}" />
    <option name="INDEPENDENT_SCRIPT_PATH" value="true" />
    <option name="SCRIPT_PATH" value="{{SCRIPT_PATH}}" />
    <option name="SCRIPT_OPTIONS" value="{{SCRIPT_OPTIONS}}" />
    <option name="INDEPENDENT_SCRIPT_WORKING_DIRECTORY" value="true" />
    <option name="SCRIPT_WORKING_DIRECTORY" value="{{SCRIPT_WORKING_DIRECTORY}}" />
    <option name="INDEPENDENT_INTERPRETER_PATH" value="true" />
    <option name="INTERPRETER_PATH" value="{{INTERPRETER_PATH}}" />
    <option name="INTERPRETER_OPTIONS" value="" />
    <option name="EXECUTE_IN_TERMINAL" value="{{EXECUTE_IN_TERMINAL}}" />
    <option name="EXECUTE_SCRIPT_FILE" value="{{EXECUTE_SCRIPT_FILE}}" />
    <envs>
{{ENV_VARS}}
    </envs>
    <method v="2" />
  </configuration>
</component>
