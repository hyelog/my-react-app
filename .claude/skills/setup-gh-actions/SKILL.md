---
name: setup-gh-actions
description: Generate or manage the GitHub Actions CI/CD workflow that builds the React app and deploys build/ to S3 + CloudFront on push to main. Use with the "create" argument to write the workflow file.
---

# /setup-gh-actions

Manage the deployment pipeline in `.github/workflows/`.

## Argument: `create`

Write `.github/workflows/deploy.yml` that, on push to `main`:

1. Checks out the repo.
2. Sets up Node (use Node 20).
3. Runs **`npm ci`** then **`npm run build`** — the build MUST run before any S3 sync.
4. Configures AWS credentials from repo secrets (`AWS_ACCESS_KEY_ID`,
   `AWS_SECRET_ACCESS_KEY`, region `us-east-1`).
5. Syncs **the `build/` directory** (not the project root) to the S3 bucket with `--delete`.
6. Creates a CloudFront invalidation for `/*`.

Use repo secrets/vars for `S3_BUCKET` and `CLOUDFRONT_DISTRIBUTION_ID` (or hardcode
the values produced by `/tf-apply` if the user prefers).

Required structure (the order matters — build before sync, sync `build/` only):

```yaml
name: Deploy to S3 + CloudFront
on:
  push:
    branches: [ main ]
permissions:
  contents: read
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: "20", cache: "npm" }
      - run: npm ci
      - run: npm run build          # produces ./build
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      - run: aws s3 sync build/ s3://${{ secrets.S3_BUCKET }}/ --delete
      - run: aws cloudfront create-invalidation --distribution-id ${{ secrets.CLOUDFRONT_DISTRIBUTION_ID }} --paths "/*"
```

## Other arguments

- `status` — show the latest workflow runs (`gh run list`) if `gh` is available.

## Guardrails

- Never sync the project root — only `build/`.
- Never write AWS secrets into the workflow file; use `secrets.*`.
- Tell the user which repo secrets to set: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`,
  `S3_BUCKET`, `CLOUDFRONT_DISTRIBUTION_ID`.
