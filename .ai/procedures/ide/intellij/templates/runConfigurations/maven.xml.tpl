<?xml version="1.0" encoding="UTF-8"?>
<!--
  Template: .idea/runConfigurations/<name>.xml  (Maven)
  type="MavenRunConfiguration" factoryName="Maven"

  Runs one or more Maven goals against the pom at {{WORKING_DIR}}. The repo must be
  linked as a Maven project first (right-click pom.xml → Add as Maven Project).

  Placeholders:
    {{NAME}}        — config name, e.g. "Package chart-ai"
    {{WORKING_DIR}} — absolute path to repo root with $PROJECT_DIR$ macro, e.g.
                      $PROJECT_DIR$/git-repositories/gitlab/yazilim.vip/private/chart-ai/chart-ai
    {{GOALS}}       — newline-joined <option value="goal-or-flag" /> entries, e.g.
                         <option value="clean" />
                         <option value="package" />
                         <option value="-DskipTests" />
    {{SKIP_TESTS}}  — "true" or "false"
    {{VM_OPTIONS}}  — JVM flags for Maven itself, e.g. "-Xmx2g" (may be empty)

  Common goal lists:
    Build:         <option value="package" />
    Clean build:   <option value="clean" />   <option value="package" />
    Spring Boot:   <option value="spring-boot:run" />
    Run tests:     <option value="test" />
    Fast package:  <option value="package" />   <option value="-DskipTests" />
-->
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="{{NAME}}" type="MavenRunConfiguration" factoryName="Maven">
    <MavenSettings>
      <option name="myGeneralSettings" />
      <option name="myRunnerSettings">
        <MavenRunnerSettings>
          <option name="delegateBuildToMaven" value="false" />
          <option name="environmentProperties">
            <map />
          </option>
          <option name="jreName" value="#USE_PROJECT_JDK" />
          <option name="mavenProperties">
            <map />
          </option>
          <option name="passParentEnv" value="true" />
          <option name="runMavenInBackground" value="true" />
          <option name="skipTests" value="{{SKIP_TESTS}}" />
          <option name="vmOptions" value="{{VM_OPTIONS}}" />
        </MavenRunnerSettings>
      </option>
      <option name="myRunnerParameters">
        <MavenRunnerParameters>
          <option name="cmdOptions" />
          <option name="profiles">
            <set />
          </option>
          <option name="goals">
            <list>
{{GOALS}}
            </list>
          </option>
          <option name="multimoduleDir" />
          <option name="pomFileName" />
          <option name="profilesMap">
            <map />
          </option>
          <option name="projectsCmdOptionValues">
            <list />
          </option>
          <option name="resolveToWorkspace" value="false" />
          <option name="workingDirPath" value="{{WORKING_DIR}}" />
        </MavenRunnerParameters>
      </option>
    </MavenSettings>
    <method v="2" />
  </configuration>
</component>
