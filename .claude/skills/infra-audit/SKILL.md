---
name: infra-audit
description: Run a full post-deploy audit of the S3 + CloudFront infrastructure — security, cost, and drift — by delegating to the security-auditor, cost-optimizer, and drift-detector subagents, then summarizing. Use after deploying or on a schedule.
---

# /infra-audit

Verify the deployed infrastructure is **secure**, **cost-optimized**, and **drift-free**
by orchestrating the three specialist subagents and consolidating their findings.

## Steps

1. Confirm infra exists (read `terraform/` and outputs). Gather the bucket name and
   distribution id for the subagents.
2. Delegate, in parallel where possible:
   - **security-auditor** (Sonnet, read-only) → public-access, OAC, TLS, bucket policy,
     encryption, secrets.
   - **cost-optimizer** (Haiku, read-only) → price class, caching/compression, lifecycle,
     versioning bloat; monthly cost estimate.
   - **drift-detector** (Haiku, Bash) → `terraform plan -refresh-only` /
     `-detailed-exitcode` + read-only AWS spot checks.
3. Consolidate into one report:
   - **Security:** verdict + any CRITICAL/HIGH findings.
   - **Cost:** verdict + estimated monthly cost + top savings.
   - **Drift:** verdict + drifted resources.
4. End with an overall status line: `PASS` (secure, optimized, no drift) or
   `ACTION REQUIRED` with the prioritized list of fixes.

## Notes

- This skill is read-only by design; it recommends fixes but does not apply them.
- If subagents are unavailable, perform the equivalent read-only checks inline.
