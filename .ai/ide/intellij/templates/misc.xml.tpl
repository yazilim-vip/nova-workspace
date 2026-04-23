<?xml version="1.0" encoding="UTF-8"?>
<!--
  Template: .idea/misc.xml
  Project-level SDK + language level. A "safe guess" — user adjusts via Project Structure
  (⌘;) → Project → SDK / Language level if wrong for their JDK.

  Placeholders:
    {{LANGUAGE_LEVEL}} — IntelliJ language level constant, e.g. JDK_21, JDK_17, JDK_1_8.
                         Default: JDK_21.
    {{JDK_NAME}}       — Name of a configured JDK in the user's IntelliJ settings, e.g.
                         "21", "corretto-21", "temurin-17". Default: "21".
                         If no matching JDK is configured, IntelliJ will surface this at
                         first open; user picks one from the Project Structure dialog.

  The ExternalStorageConfigurationManager component lets Gradle/Maven-imported modules
  store their settings externally (outside .idea/), which is the modern default and avoids
  churn in the committed .iml files when the build imports run.
-->
<project version="4">
  <component name="ExternalStorageConfigurationManager" enabled="true" />
  <component name="FrameworkDetectionExcludesConfiguration">
    <file type="web" url="file://$PROJECT_DIR$" />
  </component>
  <component name="ProjectRootManager" version="2" languageLevel="{{LANGUAGE_LEVEL}}" default="true" project-jdk-name="{{JDK_NAME}}" project-jdk-type="JavaSDK">
    <output url="file://$PROJECT_DIR$/out" />
  </component>
</project>
