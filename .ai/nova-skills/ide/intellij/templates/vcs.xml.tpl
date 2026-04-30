<?xml version="1.0" encoding="UTF-8"?>
<!--
  Template: .idea/vcs.xml
  Maps directories to Git so IntelliJ treats each cloned repo as its own VCS root.
  Status, branch switches, commits, and push/pull operate per-repo.

  Placeholders:
    {{REPO_MAPPINGS}} — newline-joined list of <mapping directory="..." vcs="Git" /> entries
                         for each cloned repo. The workspace-root mapping is always included
                         above this placeholder.

  Example rendered mappings:
      <mapping directory="$PROJECT_DIR$/git-repositories/github/yazilim-vip/gym-tracker" vcs="Git" />
      <mapping directory="$PROJECT_DIR$/git-repositories/gitlab/yazilim.vip/private/chart-ai/chart-ai" vcs="Git" />

  Omit the workspace-root mapping if the workspace is not itself a Git repo. For NOVA
  workspaces that ARE a Git repo (the common case), keep it.
-->
<project version="4">
  <component name="VcsDirectoryMappings">
    <mapping directory="$PROJECT_DIR$" vcs="Git" />
{{REPO_MAPPINGS}}
  </component>
</project>
