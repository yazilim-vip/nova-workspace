<?xml version="1.0" encoding="UTF-8"?>
<!--
  Template: .idea/modules/<name>.iml
  Per-module config. type="WEB_MODULE" is the safe generic default — no language
  commitments, shows all files. User upgrades specific modules in-IDE by linking
  to the build tool (pom.xml / build.gradle → Link Project).

  Placeholders:
    {{CONTENT_URL}}     — absolute path with $PROJECT_DIR$ macro, e.g.
                          $PROJECT_DIR$/git-repositories/github/yazilim-vip/gym-tracker
                          For the workspace-root module, use: $PROJECT_DIR$
    {{EXCLUDE_FOLDERS}} — newline-joined list of <excludeFolder url="file://..." /> entries.
                          Use $PROJECT_DIR$-relative URLs (not $MODULE_DIR$) when the .iml
                          lives outside the module content root — which is our convention
                          (.iml lives under .idea/modules/, content lives under git-repositories/).

  Example rendered excludes for a repo module:
      <excludeFolder url="file://$PROJECT_DIR$/git-repositories/github/yazilim-vip/gym-tracker/node_modules" />
      <excludeFolder url="file://$PROJECT_DIR$/git-repositories/github/yazilim-vip/gym-tracker/build" />
      <excludeFolder url="file://$PROJECT_DIR$/git-repositories/github/yazilim-vip/gym-tracker/target" />
      <excludeFolder url="file://$PROJECT_DIR$/git-repositories/github/yazilim-vip/gym-tracker/dist" />
      <excludeFolder url="file://$PROJECT_DIR$/git-repositories/github/yazilim-vip/gym-tracker/out" />
      <excludeFolder url="file://$PROJECT_DIR$/git-repositories/github/yazilim-vip/gym-tracker/.gradle" />
      <excludeFolder url="file://$PROJECT_DIR$/git-repositories/github/yazilim-vip/gym-tracker/.venv" />
      <excludeFolder url="file://$PROJECT_DIR$/git-repositories/github/yazilim-vip/gym-tracker/__pycache__" />
      <excludeFolder url="file://$PROJECT_DIR$/git-repositories/github/yazilim-vip/gym-tracker/vendor" />
      <excludeFolder url="file://$PROJECT_DIR$/git-repositories/github/yazilim-vip/gym-tracker/.idea" />

  Example rendered excludes for the workspace-root module:
      <excludeFolder url="file://$PROJECT_DIR$/git-repositories" />
      <excludeFolder url="file://$PROJECT_DIR$/scripts" />
      <excludeFolder url="file://$PROJECT_DIR$/.idea" />
-->
<module type="WEB_MODULE" version="4">
  <component name="NewModuleRootManager">
    <content url="file://{{CONTENT_URL}}">
{{EXCLUDE_FOLDERS}}
    </content>
    <orderEntry type="inheritedJdk" />
    <orderEntry type="sourceFolder" forTests="false" />
  </component>
</module>
