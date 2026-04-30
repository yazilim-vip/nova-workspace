<?xml version="1.0" encoding="UTF-8"?>
<!--
  Template: .idea/runConfigurations/<name>.xml  (Compound)
  type="CompoundRunConfigurationType"

  Runs a set of existing run configurations together. Useful for starting a stack:
  API + frontend + worker, or multiple microservices at once.

  Prerequisite: every config referenced in <toRun> must already exist by that exact
  name and type. If a referenced config is missing, IntelliJ silently skips it — no
  error at launch, just nothing happens for that entry. Double-check names match.

  Placeholders:
    {{NAME}}           — config name, e.g. "all-services"
    {{TO_RUN_ENTRIES}} — newline-joined <toRun name="..." type="..." /> entries.

  Example rendered entries (runs three services together):
      <toRun name="Start API" type="js.build_tools.npm" />
      <toRun name="Start CDN" type="js.build_tools.npm" />
      <toRun name="Start Gateway" type="js.build_tools.npm" />

  Supported target types (reference them by their type IDs):
    Application (Java)                 → type="Application"
    JUnit test                         → type="JUnit"
    Spring Boot                        → type="SpringBootApplicationConfigurationType"
    Gradle task                        → type="GradleRunConfiguration"
    Maven goal                         → type="MavenRunConfiguration"
    Shell script                       → type="ShConfigurationType"
    Node.js                            → type="NodeJSConfigurationType"
    npm                                → type="js.build_tools.npm"
    Go application                     → type="GoApplicationRunConfiguration"
    Python                             → type="PythonConfigurationType"
    Another compound                   → type="CompoundRunConfigurationType" (nesting works)
-->
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="{{NAME}}" type="CompoundRunConfigurationType">
{{TO_RUN_ENTRIES}}
    <method v="2" />
  </configuration>
</component>
