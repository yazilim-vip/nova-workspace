<?xml version="1.0" encoding="UTF-8"?>
<!--
  Template: .idea/runConfigurations/<name>.xml  (Spring Boot)
  type="SpringBootApplicationConfigurationType" factoryName="Spring Boot"

  Requires the Spring Boot plugin (ships with IntelliJ IDEA Ultimate; available as
  plugin for Community). If the user is on Community without the plugin, fall back to
  the gradle.xml.tpl or maven.xml.tpl templates with the appropriate task/goal
  (`bootRun` for Gradle, `spring-boot:run` for Maven).

  Placeholders:
    {{NAME}}               — config name, e.g. "Run chart-ai"
    {{MODULE}}             — module owning the @SpringBootApplication class
    {{MAIN_CLASS}}         — fully-qualified main class, e.g. com.acme.chartai.ChartAiApplication
    {{ACTIVE_PROFILES}}    — comma-separated Spring profiles, e.g. "local,dev" (may be empty)
    {{VM_PARAMETERS}}      — JVM flags (may be empty)
    {{PROGRAM_PARAMETERS}} — application args (may be empty)
    {{WORKING_DIRECTORY}}  — working dir path or macro; $MODULE_WORKING_DIR$ is sane default
    {{ENV_VARS}}           — <env name="K" value="V" /> entries (may be empty)
-->
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="{{NAME}}" type="SpringBootApplicationConfigurationType" factoryName="Spring Boot">
    <module name="{{MODULE}}" />
    <option name="SPRING_BOOT_MAIN_CLASS" value="{{MAIN_CLASS}}" />
    <option name="ACTIVE_PROFILES" value="{{ACTIVE_PROFILES}}" />
    <option name="VM_PARAMETERS" value="{{VM_PARAMETERS}}" />
    <option name="PROGRAM_PARAMETERS" value="{{PROGRAM_PARAMETERS}}" />
    <option name="WORKING_DIRECTORY" value="{{WORKING_DIRECTORY}}" />
    <option name="ALTERNATIVE_JRE_PATH" />
    <envs>
{{ENV_VARS}}
    </envs>
    <method v="2">
      <option name="Make" enabled="true" />
    </method>
  </configuration>
</component>
