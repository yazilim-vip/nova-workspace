<?xml version="1.0" encoding="UTF-8"?>
<!--
  Template: .idea/runConfigurations/<name>.xml  (npm / pnpm / yarn)
  type="js.build_tools.npm"

  Runs an npm command. For pnpm or yarn, change the <command> element or rely on the
  scripts block in package.json — but this template is specifically npm.

  Placeholders:
    {{NAME}}             — config name, e.g. "build"
    {{PACKAGE_JSON}}     — absolute path to package.json, e.g.
                           $PROJECT_DIR$/git-repositories/github/yazilim-vip/<repo>/package.json
    {{COMMAND}}          — npm subcommand: run | install | test | start | ci
    {{SCRIPT}}           — when COMMAND=run, the script name from package.json scripts
                           (e.g. "build", "dev"). Leave empty for install/test/start.
    {{NODE_INTERPRETER}} — "project" (project-configured) or absolute path to node
    {{ENV_VARS}}         — <env name="K" value="V" /> entries (may be empty)

  Common combinations:
    npm run build:    COMMAND=run,     SCRIPT=build
    npm start:        COMMAND=start,   SCRIPT=
    npm test:         COMMAND=test,    SCRIPT=
    npm install:      COMMAND=install, SCRIPT=
-->
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="{{NAME}}" type="js.build_tools.npm">
    <package-json value="{{PACKAGE_JSON}}" />
    <command value="{{COMMAND}}" />
    <scripts>
      <script value="{{SCRIPT}}" />
    </scripts>
    <node-interpreter value="{{NODE_INTERPRETER}}" />
    <envs>
{{ENV_VARS}}
    </envs>
    <method v="2" />
  </configuration>
</component>
