---
name: tf-plan
description: Preview Terraform infrastructure changes for the S3 + CloudFront stack without applying them. Use before any apply to review what will be created, changed, or destroyed. Read-only against AWS.
---

# /tf-plan

Produce and summarize a Terraform execution plan for `terraform/`.

## Steps

1. Ensure the working dir is initialized: `terraform -chdir=terraform init -input=false`
   (safe to re-run).
2. Validate config: `terraform -chdir=terraform validate -no-color`.
3. Generate the plan and save it for a later apply:
   ```bash
   terraform -chdir=terraform plan -no-color -out=tfplan
   ```
4. Summarize the plan for the user: counts of resources to **add / change / destroy**,
   and call out anything destructive or any public-exposure change explicitly.
5. If the plan shows a destroy, **stop and confirm** with the user before suggesting apply.

## Notes

- `plan` does not modify infrastructure. The saved `tfplan` file is consumed by `/tf-apply`.
- If `init` reports a provider/version mismatch, surface it rather than auto-upgrading.
