<?xml version="1.0" encoding="UTF-8"?>
<!--
  Template: .idea/modules/<name>.iml
  Per-module config. type="WEB_MODULE" is the safe generic default — no language
  commitments, shows all files. User upgrades specific modules in-IDE by linking
  to the build tool (pom.xml / build.gradle → Link Project).

  CRITICAL: inside .iml files, IntelliJ only resolves $MODULE_DIR$.
  $PROJECT_DIR$ is NOT substituted inside .iml — IntelliJ logs
  "Watch roots should be absolute: $PROJECT_DIR$/..." and silently drops
  every module. Since our .iml lives at .idea/modules/<name>.iml,
  $MODULE_DIR$ resolves to .idea/modules/, so $MODULE_DIR$/../.. climbs
  to the workspace root.

  Placeholders:
    {{CONTENT_URL}}     — $MODULE_DIR$-relative path, e.g.
                          $MODULE_DIR$/../../git-repositories/github/yazilim-vip/gym-tracker
                          For the workspace-root module, use: $MODULE_DIR$/../..
    {{EXCLUDE_FOLDERS}} — newline-joined list of <excludeFolder url="file://..." /> entries,
                          all rooted at $MODULE_DIR$/../..

  Example rendered excludes for a repo module:
      <excludeFolder url="file://$MODULE_DIR$/../../git-repositories/github/yazilim-vip/gym-tracker/node_modules" />
      <excludeFolder url="file://$MODULE_DIR$/../../git-repositories/github/yazilim-vip/gym-tracker/build" />
      <excludeFolder url="file://$MODULE_DIR$/../../git-repositories/github/yazilim-vip/gym-tracker/target" />
      <excludeFolder url="file://$MODULE_DIR$/../../git-repositories/github/yazilim-vip/gym-tracker/dist" />
      <excludeFolder url="file://$MODULE_DIR$/../../git-repositories/github/yazilim-vip/gym-tracker/out" />
      <excludeFolder url="file://$MODULE_DIR$/../../git-repositories/github/yazilim-vip/gym-tracker/.gradle" />
      <excludeFolder url="file://$MODULE_DIR$/../../git-repositories/github/yazilim-vip/gym-tracker/.venv" />
      <excludeFolder url="file://$MODULE_DIR$/../../git-repositories/github/yazilim-vip/gym-tracker/__pycache__" />
      <excludeFolder url="file://$MODULE_DIR$/../../git-repositories/github/yazilim-vip/gym-tracker/vendor" />
      <excludeFolder url="file://$MODULE_DIR$/../../git-repositories/github/yazilim-vip/gym-tracker/.idea" />

  Example rendered excludes for the workspace-root module:
      <excludeFolder url="file://$MODULE_DIR$/../../git-repositories" />
      <excludeFolder url="file://$MODULE_DIR$/../../scripts" />
      <excludeFolder url="file://$MODULE_DIR$/../../.idea" />
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
