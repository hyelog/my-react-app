#!/usr/bin/env bash
# UserPromptSubmit hook: scans the submitted prompt for risky content before it
# reaches the model. Adds a cautionary context note for destructive intents and
# blocks prompts that appear to leak credentials.
#
# stdin: JSON { "prompt": "...", ... }
# Exit 0 + stdout  -> stdout is injected as additional context.
# Exit 2 + stderr  -> prompt is blocked, stderr shown to the user.
set -euo pipefail

input="$(cat)"
prompt="$(printf '%s' "$input" | grep -o '"prompt"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 || true)"

# --- Block: looks like a leaked AWS secret key in the prompt ---------------
if printf '%s' "$prompt" | grep -Eq 'aws_secret_access_key|AKIA[0-9A-Z]{16}|(["'\''[:space:]=])[A-Za-z0-9/+]{40}(["'\''[:space:]]|$)'; then
  echo "user-prompt-guard: this prompt appears to contain AWS credentials. Remove the secret and use the AWS profile / env vars instead." >&2
  exit 2
fi

# --- Warn: destructive infra intent ---------------------------------------
if printf '%s' "$prompt" | grep -Eiq 'destroy|delete (the )?(bucket|distribution|stack)|rm -rf|tear ?down'; then
  echo "[user-prompt-guard] Note: this request mentions destructive infrastructure actions. Confirm scope and prefer 'terraform plan -destroy' before any apply -destroy. The S3 bucket is private and stateful — back up before deleting."
fi

exit 0
