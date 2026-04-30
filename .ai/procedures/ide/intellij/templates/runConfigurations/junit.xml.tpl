<?xml version="1.0" encoding="UTF-8"?>
<!--
  Template: .idea/runConfigurations/<name>.xml  (JUnit test)
  type="JUnit" factoryName="JUnit" — runs JUnit tests. For TestNG, change to type="TestNG".

  Placeholders:
    {{NAME}}           — config name, e.g. "MyFeatureTest"
    {{MODULE}}         — module that owns the test class
    {{TEST_OBJECT}}    — one of: class, package, method, directory, pattern, category
    {{PACKAGE_NAME}}   — only used when TEST_OBJECT=package; otherwise leave empty
    {{MAIN_CLASS_NAME}} — fully-qualified test class; used when TEST_OBJECT=class or method
    {{METHOD_NAME}}    — only used when TEST_OBJECT=method; otherwise leave empty
    {{VM_PARAMETERS}}  — JVM flags (may be empty)
    {{ENV_VARS}}       — <env name="K" value="V" /> entries (may be empty)

  Common combinations:
    Run single class:   TEST_OBJECT=class,  MAIN_CLASS_NAME=com.acme.FooTest
    Run single method:  TEST_OBJECT=method, MAIN_CLASS_NAME=com.acme.FooTest, METHOD_NAME=testBar
    Run a package:      TEST_OBJECT=package, PACKAGE_NAME=com.acme
-->
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="{{NAME}}" type="JUnit" factoryName="JUnit">
    <module name="{{MODULE}}" />
    <shortenClasspath name="ARGS_FILE" />
    <option name="PACKAGE_NAME" value="{{PACKAGE_NAME}}" />
    <option name="MAIN_CLASS_NAME" value="{{MAIN_CLASS_NAME}}" />
    <option name="METHOD_NAME" value="{{METHOD_NAME}}" />
    <option name="TEST_OBJECT" value="{{TEST_OBJECT}}" />
    <option name="VM_PARAMETERS" value="{{VM_PARAMETERS}}" />
    <envs>
{{ENV_VARS}}
    </envs>
    <method v="2">
      <option name="Make" enabled="true" />
    </method>
  </configuration>
</component>
