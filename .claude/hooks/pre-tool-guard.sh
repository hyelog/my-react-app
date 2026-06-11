#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash): inspects the command about to run and blocks
# irreversible / dangerous operations. Allowed commands pass through silently.
#
# stdin: JSON { "tool_name": "Bash", "tool_input": { "command": "..." }, ... }
# Exit 0 -> allow.  Exit 2 + stderr -> deny (stderr returned to the model).
set -euo pipefail

input="$(cat)"
cmd="$(printf '%s' "$input" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null || true)"

deny() { echo "[pre-tool-guard] BLOCKED: $1" >&2; exit 2; }

# Catastrophic filesystem wipes
printf '%s' "$cmd" | grep -Eq 'rm[[:space:]]+(-[a-zA-Z]*[rf][a-zA-Z]*[[:space:]]+)+(/|~|\*|\$HOME)([[:space:]]|$)' \
  && deny "recursive force-remove of a top-level path is not allowed."

# Destroy live infrastructure without an explicit plan file
printf '%s' "$cmd" | grep -Eq 'terraform[[:space:]].*destroy' \
  && deny "'terraform destroy' is gated. Run '/tf-plan' with -destroy and confirm before tearing infra down."

# Deleting the S3 bucket or its contents wholesale
printf '%s' "$cmd" | grep -Eq 'aws[[:space:]]+s3[[:space:]]+rb' \
  && deny "'aws s3 rb' removes the deployment bucket. Use Terraform to manage the bucket lifecycle."
printf '%s' "$cmd" | grep -Eq 'aws[[:space:]]+s3[[:space:]]+rm[[:space:]].*--recursive' \
  && deny "recursive S3 delete is gated to protect deployed assets."

# Deleting the CloudFront distribution out-of-band
printf '%s' "$cmd" | grep -Eq 'aws[[:space:]]+cloudfront[[:space:]]+delete-distribution' \
  && deny "deleting the CloudFront distribution out-of-band causes drift. Use Terraform."

# Committing obvious secrets
printf '%s' "$cmd" | grep -Eq 'AKIA[0-9A-Z]{16}' \
  && deny "command appears to contain an AWS access key id."

exit 0
