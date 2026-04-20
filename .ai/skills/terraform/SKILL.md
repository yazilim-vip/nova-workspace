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

1. Always `plan` before `apply` — show a summary of what will be created, changed, destroyed
2. Highlight destructive changes (`destroy`, `replace`, `force-new`) with an explicit warning
3. Wait for explicit user approval before applying
4. Apply one module at a time — never `apply-all`
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

- `snake_case` for all resource, variable, and output names
- Always `terraform fmt -recursive` and `terraform validate` before commit
- Pin provider versions to minor (`~> 5.0`); Terraform `~> 1.5`
- Terragrunt: use `include` blocks for DRY, `dependency` blocks for cross-module refs
- Never modify `.tfstate` files directly
- Never hardcode secrets — use variables marked `sensitive = true`

## Reading a Plan

A plan output classifies every resource change. Recognize the symbols:

| Symbol | Meaning | Reversible? |
|--------|---------|-------------|
| `+` | create | yes (destroy) |
| `~` | update in-place | sometimes |
| `-/+` | destroy + recreate | **data loss risk** — downtime, potentially unrecoverable |
| `<=` | read data source | yes, safe |
| `-` | destroy | **permanent** — verify before apply |

Whenever a plan shows `-/+` or `-`, stop and walk the user through what's being replaced/destroyed and why, *before* asking for apply approval.

## Handling Plan Failures

- **Auth errors** → provider credentials are missing or expired. Check env vars or the CLI wrapper's `.env` file. Never commit credentials to fix this.
- **"Resource already exists"** → something was created outside Terraform. Either `terraform import` it into state (preferred — preserves the resource) or delete it out-of-band and re-plan.
- **Version mismatch** (`required_providers` or `required_version`) → run `terraform init -upgrade` and commit the updated `.terraform.lock.hcl`.

## State Locks

A stale lock (`Error acquiring the state lock`) usually means a previous run crashed or was cancelled. Before force-unlocking:

1. Confirm no one else is running Terraform against this state (check CI, ask team)
2. Inspect the lock info — who/when/from where
3. Only then: `terraform force-unlock <LOCK_ID>`

Never routine `-lock=false` — it defeats the lock's purpose and risks concurrent writes corrupting state.

## Importing Existing Resources

To bring an existing resource under Terraform management without recreating it:

```bash
# 1. Write the resource block in .tf exactly as it should look
# 2. Import its current state:
terraform import 'aws_s3_bucket.logs' company-logs-bucket

# 3. Run plan — it should show "no changes" if the .tf matches reality.
#    If it shows changes, either your .tf doesn't match the real resource
#    (fix the .tf), or you imported the wrong ID.
```

## Provider Upgrades

- Bump providers one at a time
- Read the upstream changelog for breaking changes **before** running `init -upgrade`
- Plan after each upgrade — unexpected drift often appears
- Commit `.terraform.lock.hcl` alongside the version bump so CI uses the same provider

## Example — minimal module

```hcl
# variables.tf
variable "bucket_name" {
  description = "S3 bucket name (globally unique)"
  type        = string
}

# main.tf
resource "aws_s3_bucket" "logs" {
  bucket = var.bucket_name
}

# outputs.tf
output "bucket_arn" {
  description = "ARN of the created bucket"
  value       = aws_s3_bucket.logs.arn
}

# versions.tf
terraform {
  required_version = "~> 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```
