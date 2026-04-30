<?xml version="1.0" encoding="UTF-8"?>
<!--
  Template: .idea/runConfigurations/<name>.xml  (Node.js)
  type="NodeJSConfigurationType" factoryName="Node.js"

  Direct `node` invocation on a JS file. For `npm start` / `npm run <script>`, prefer
  the npm template — it integrates with package.json's scripts block and is more
  portable across dev machines.

  Placeholders:
    {{NAME}}             — config name, e.g. "Start API"
    {{PATH_TO_NODE}}     — "project" (uses the project's configured Node interpreter) or
                           absolute path like "/usr/local/bin/node"
    {{PATH_TO_JS_FILE}}  — entry file, relative to working-dir, e.g. "bin/www" or
                           absolute with $PROJECT_DIR$ macro
    {{WORKING_DIR}}      — absolute path to the repo, e.g.
                           $PROJECT_DIR$/git-repositories/github/yazilim-vip/<repo>
    {{ENV_VARS}}         — <env name="K" value="V" /> entries (may be empty)
-->
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="{{NAME}}" type="NodeJSConfigurationType" factoryName="Node.js" path-to-node="{{PATH_TO_NODE}}" path-to-js-file="{{PATH_TO_JS_FILE}}" working-dir="{{WORKING_DIR}}">
    <envs>
{{ENV_VARS}}
    </envs>
    <method v="2" />
  </configuration>
</component>
