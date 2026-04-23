<?xml version="1.0" encoding="UTF-8"?>
<!--
  Template: .idea/runConfigurations/<name>.xml  (Python)
  type="PythonConfigurationType" factoryName="Python"

  Requires the Python plugin installed in IntelliJ (or use PyCharm). The SDK comes
  from the module's configured Python interpreter when IS_MODULE_SDK=true.

  Placeholders:
    {{NAME}}                — config name, e.g. "Run bookmarks-mcp"
    {{MODULE}}              — IntelliJ module that owns the script
    {{SCRIPT_NAME}}         — absolute path to the .py entry file, e.g.
                              $PROJECT_DIR$/git-repositories/github/yazilim-vip/<repo>/main.py
    {{WORKING_DIR}}         — working directory, usually the repo root with $PROJECT_DIR$ macro
    {{PARAMETERS}}          — CLI args passed to the script as a single string
    {{INTERPRETER_OPTIONS}} — flags for `python` itself, e.g. "-u" for unbuffered
    {{ENV_VARS}}            — <env name="K" value="V" /> entries (may be empty).
                              "PYTHONUNBUFFERED=1" is a common useful entry.

  IS_MODULE_SDK is left as "true" — IntelliJ uses the Python SDK configured on the
  module in Project Structure. For a different interpreter, set SDK_HOME to the
  absolute path of the python binary and set IS_MODULE_SDK to "false".
-->
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="{{NAME}}" type="PythonConfigurationType" factoryName="Python">
    <module name="{{MODULE}}" />
    <option name="INTERPRETER_OPTIONS" value="{{INTERPRETER_OPTIONS}}" />
    <option name="PARENT_ENVS" value="true" />
    <envs>
{{ENV_VARS}}
    </envs>
    <option name="SDK_HOME" value="" />
    <option name="WORKING_DIRECTORY" value="{{WORKING_DIR}}" />
    <option name="IS_MODULE_SDK" value="true" />
    <option name="ADD_CONTENT_ROOTS" value="true" />
    <option name="ADD_SOURCE_ROOTS" value="true" />
    <option name="SCRIPT_NAME" value="{{SCRIPT_NAME}}" />
    <option name="PARAMETERS" value="{{PARAMETERS}}" />
    <option name="SHOW_COMMAND_LINE" value="false" />
    <option name="EMULATE_TERMINAL" value="false" />
    <option name="MODULE_MODE" value="false" />
    <option name="REDIRECT_INPUT" value="false" />
    <option name="INPUT_FILE" value="" />
    <RunnerSettings RunnerId="PythonRunner" />
    <ConfigurationWrapper RunnerId="PythonRunner" />
    <method v="2" />
  </configuration>
</component>
