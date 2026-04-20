---
name: terraform
description: Terraform and Terragrunt apply protocol, module structure, and coding conventions. Use when writing Terraform modules, running plan/apply operations, reviewing infrastructure-as-code, or working with Terragrunt configurations.
metadata:
  author: yazilim-vip
  version: "0.1.0"
  status: "stable"
---

# Terraform

## Apply Protocol

1. Always plan before apply — show summary of what will be created, changed, destroyed
2. Highlight destructive changes (destroy, replace, force-new) with explicit warning
3. Wait for explicit user approval before applying
4. Apply one module at a time — never apply-all
5. If plan output changed since review, re-plan and re-confirm

## Module Structure

```
module-name/
├── main.tf          # Primary resources
├── variables.tf     # Input variables (description + type required)
├── outputs.tf       # Output values (description required)
├── versions.tf      # Provider versions (pin minor: ~> 5.0)
├── data.tf          # Data sources (optional)
└── locals.tf        # Local values (optional)
```

## Conventions

- Snake_case for all resource, variable, and output names
- Always `terraform fmt -recursive` and validate before commit
- Pin provider versions to minor (`~> 5.0`), Terraform `~> 1.5`
- Terragrunt: use `include` blocks for DRY, `dependency` blocks for cross-module refs
- Never modify `.tfstate` files directly
- Never hardcode secrets — use variables marked `sensitive = true`
