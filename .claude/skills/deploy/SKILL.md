---
name: deploy
description: Build the React app and deploy it to the live S3 + CloudFront site from your machine. Use for a manual/local deploy. Runs npm run build, syncs the build/ directory to S3, and invalidates the CloudFront cache.
---

# /deploy

Build and ship the app to the existing infrastructure (provisioned by `/tf-apply`).

## Steps

1. Resolve infra targets from Terraform outputs:
   ```bash
   BUCKET=$(terraform -chdir=terraform output -raw bucket_name)
   DIST=$(terraform -chdir=terraform output -raw cloudfront_distribution_id)
   ```
2. Build the production bundle (output is the **`build/`** directory):
   ```bash
   npm ci
   npm run build
   ```
3. Sync **`build/`** (not the project root) to S3, deleting removed files:
   ```bash
   aws s3 sync build/ "s3://$BUCKET/" --delete
   ```
   Optionally set long cache headers on hashed assets and `no-cache` on `index.html`.
4. Invalidate the CloudFront cache so users get the new version:
   ```bash
   aws cloudfront create-invalidation --distribution-id "$DIST" --paths "/*"
   ```
5. Print the live URL (`https://<cloudfront-domain>/`) and confirm a 200 response.

## Guardrails

- Always sync `build/`, never the repo root — syncing the root would expose source.
- `--delete` removes stale objects; confirm the build succeeded before syncing.
