---
name: scaffold-terraform
description: Generate the Terraform configuration for hosting this React app — a private S3 bucket plus a CloudFront distribution with Origin Access Control (OAC). Use when setting up infrastructure-as-code for the first time or refreshing the IaC. Writes files under terraform/.
---

# /scaffold-terraform

Create (or refresh) the Terraform that provisions the static-site infrastructure:
a **private S3 bucket** (origin) and a **CloudFront distribution** that reads it via
**Origin Access Control**. Output goes in `terraform/`.

## Steps

1. Ensure `terraform/` exists. Create these files (do not commit state or tfvars):
   - `terraform/versions.tf` — required providers + Terraform version.
   - `terraform/variables.tf` — `aws_region` (default `us-east-1`), `project_name`,
     `tags`.
   - `terraform/main.tf` — the resources (below).
   - `terraform/outputs.tf` — bucket name, distribution id, and the CloudFront
     domain (`*.cloudfront.net`).
2. The infrastructure **must** include:
   - `random_id` suffix so the bucket name is globally unique.
   - `aws_s3_bucket` (private).
   - `aws_s3_bucket_public_access_block` with all four flags `true`.
   - `aws_s3_bucket_ownership_controls` (BucketOwnerEnforced) + SSE.
   - `aws_cloudfront_origin_access_control` (sigv4, always sign).
   - `aws_cloudfront_distribution` with `default_root_object = "index.html"`,
     `viewer_protocol_policy = "redirect-to-https"`, `compress = true`,
     `price_class = "PriceClass_100"`, and custom error responses mapping
     403/404 → `/index.html` (SPA routing).
   - `aws_s3_bucket_policy` granting `s3:GetObject` to the CloudFront service
     principal, scoped with `AWS:SourceArn = <distribution ARN>`.
3. Run `terraform -chdir=terraform fmt` and `terraform -chdir=terraform init`.
4. Run `terraform -chdir=terraform validate` and report the result.
5. Do **not** run `apply` here — that's `/tf-apply`. Tell the user to run `/tf-plan` next.

## Notes

- Keep the bucket strictly private; all public access is via CloudFront + OAC.
- Use `PriceClass_100` to keep CloudFront cost low for a small site.
