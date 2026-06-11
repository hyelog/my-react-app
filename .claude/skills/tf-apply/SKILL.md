---
name: tf-apply
description: Apply the Terraform plan to create or update the S3 + CloudFront infrastructure. Use after /tf-plan has been reviewed. Creates real, billable AWS resources.
---

# /tf-apply

Apply the previously reviewed Terraform plan in `terraform/`.

## Steps

1. Confirm a reviewed plan exists. Prefer applying the saved plan file:
   ```bash
   terraform -chdir=terraform apply -no-color tfplan
   ```
   If no `tfplan` exists, run `/tf-plan` first; only fall back to
   `terraform -chdir=terraform apply -auto-approve` after the user has reviewed a plan.
2. After apply, print the outputs:
   ```bash
   terraform -chdir=terraform output
   ```
   Capture the **bucket name**, **distribution id**, and **CloudFront domain**.
3. Note that a new CloudFront distribution takes ~10–20 minutes to reach `Deployed`.
   Optionally check status:
   ```bash
   aws cloudfront get-distribution --id <dist-id> --query 'Distribution.Status' --output text
   ```
4. Tell the user the next step is `/deploy` (or push to `main`) to upload the built site.

## Guardrails

- This creates real, billable resources. Never run with `-destroy` here.
- Never commit `terraform.tfstate` (it may contain resource metadata).
