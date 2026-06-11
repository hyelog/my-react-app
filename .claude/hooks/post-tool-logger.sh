#!/usr/bin/env bash
# PostToolUse hook (matcher: *): appends an audit line for every tool call to
# .claude/logs/tool-audit.log. Never blocks; failures are swallowed.
#
# stdin: JSON { "tool_name": "...", "tool_input": {...}, ... }
set -uo pipefail

dir="${CLAUDE_PROJECT_DIR:-.}/.claude/logs"
mkdir -p "$dir" 2>/dev/null || true
log="$dir/tool-audit.log"

input="$(cat)"
ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

read -r tool detail < <(printf '%s' "$input" | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
except Exception:
    print("unknown -")
    sys.exit(0)
tool = d.get("tool_name", "unknown")
ti = d.get("tool_input", {}) or {}
detail = ti.get("command") or ti.get("file_path") or ti.get("pattern") or "-"
detail = " ".join(str(detail).split())[:200]
print(tool, detail)
' 2>/dev/null || echo "unknown -")

printf '%s\t%s\t%s\n' "$ts" "$tool" "$detail" >> "$log" 2>/dev/null || true
exit 0
