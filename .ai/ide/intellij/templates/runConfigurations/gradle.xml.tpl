<?xml version="1.0" encoding="UTF-8"?>
<!--
  Template: .idea/runConfigurations/<name>.xml  (Gradle)
  type="GradleRunConfiguration" factoryName="Gradle"

  Runs one or more Gradle tasks against the project at {{PROJECT_PATH}}. IntelliJ must
  have the repo linked as a Gradle project first (right-click build.gradle → Link
  Gradle Project); otherwise `taskNames` won't resolve.

  Placeholders:
    {{NAME}}              — config name, e.g. "Build gym-tracker"
    {{PROJECT_PATH}}      — absolute path to the repo with $PROJECT_DIR$ macro, e.g.
                            $PROJECT_DIR$/git-repositories/github/yazilim-vip/gym-tracker
    {{TASK_NAMES}}        — newline-joined <option value="taskName" /> entries, e.g.
                              <option value="clean" />
                              <option value="build" />
    {{SCRIPT_PARAMETERS}} — raw CLI args as a single string, e.g. "-x test" to skip tests,
                            or "-Pfoo=bar" to set project properties
    {{VM_OPTIONS}}        — JVM flags for the Gradle launcher (may be empty)

  Common task lists:
    Default build:  <option value="build" />
    Spring Boot:    <option value="bootRun" />
    Tests only:     <option value="test" />
    Clean build:    <option value="clean" />   <option value="build" />
-->
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="{{NAME}}" type="GradleRunConfiguration" factoryName="Gradle">
    <ExternalSystemSettings>
      <option name="executionName" />
      <option name="externalProjectPath" value="{{PROJECT_PATH}}" />
      <option name="externalSystemIdString" value="GRADLE" />
      <option name="scriptParameters" value="{{SCRIPT_PARAMETERS}}" />
      <option name="taskDescriptions">
        <list />
      </option>
      <option name="taskNames">
        <list>
{{TASK_NAMES}}
        </list>
      </option>
      <option name="vmOptions" value="{{VM_OPTIONS}}" />
    </ExternalSystemSettings>
    <ExternalSystemDebugServerProcess>true</ExternalSystemDebugServerProcess>
    <ExternalSystemReattachDebugProcess>true</ExternalSystemReattachDebugProcess>
    <DebugAllEnabled>false</DebugAllEnabled>
    <method v="2" />
  </configuration>
</component>
