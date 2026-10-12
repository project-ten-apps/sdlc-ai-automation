#!/bin/sh
# Validates an agentic-readiness report (POSIX sh + awk). Same checks as validate-report.ps1.
# Usage: sh validate-report.sh <report.md> [full|audit] [<project-root>]
# Exit code 0 = valid (warnings allowed), 1 = errors.

report="$1"
mode="${2:-full}"
root="$3"
dir=$(cd "$(dirname "$0")" && pwd)
template="$dir/../templates/reports/agentic-readiness-report.md"

[ -f "$report" ] || { echo "ERROR: report not found: $report"; exit 1; }
[ -f "$template" ] || template=/dev/null

awk -v mode="$mode" '
function trim(s) { gsub(/^[ \t\r]+|[ \t\r]+$/, "", s); return s }
FNR == NR { tpl[trim($0)] = 1; next }
{
  line = $0; sub(/\r$/, "", line); n++
  if (match(line, /\{\{[A-Z0-9_]+\}\}/)) err[++e] = "unfilled placeholder on line " n ": " substr(line, RSTART, RLENGTH)
  if (line ~ /^##[ \t]/) { sec = trim(substr(line, 3)); seen[sec] = 1; sep = 0; next }
  if (sec == "") next
  t = line; gsub(/<!--.*-->/, "", t); t = trim(t)
  if (t != "" && t !~ /^\|[ \t\-:|]+\|$/ && !(trim(line) in tpl)) filled[sec] = 1
  if (t ~ /^\|[ \t\-:|]+\|$/) { sep = 1; next }
  if (t !~ /^\|/ || !sep) next
  row = t; gsub(/^\||\|$/, "", row); k = split(row, c, "|")
  for (i = 1; i <= k; i++) c[i] = trim(c[i])
  if (sec == "Audit (before)") {
    rows++
    s = tolower(c[2])
    if (s !~ /^(red|amber|green)$/) err[++e] = "audit row \x27" c[1] "\x27 needs status red, amber or green (found \x27" c[2] "\x27)"
    else if (k > 2 && c[3] == "") warn[++w] = "audit row \x27" c[1] "\x27 has no evidence"
  }
  if (sec == "Questionnaire answers") {
    if (mode == "audit" && c[1] != "1" && c[1] != "4" && c[1] != "11") next
    if (k < 3 || c[3] == "") err[++e] = "questionnaire answer #" c[1] " is empty"
  }
}
END {
  req = "Questionnaire answers|Audit (before)|Security summary|Recommended next steps"
  if (mode != "audit") req = req "|Tools installed|Generated files|Migration plan|Pilot (after)|Readiness after"
  m = split(req, r, "|")
  for (i = 1; i <= m; i++) {
    if (!(r[i] in seen)) err[++e] = "missing section: ## " r[i]
    else if (!(r[i] in filled)) err[++e] = "section not filled in: ## " r[i]
  }
  if (("Audit (before)" in seen) && rows == 0) err[++e] = "audit table has no rows"
  for (i = 1; i <= w; i++) print "WARN:  " warn[i]
  for (i = 1; i <= e; i++) print "ERROR: " err[i]
  exit (e > 0)
}' "$template" "$report"
status=$?

if [ -n "$root" ]; then
  for f in AGENTS.md CLAUDE.md GEMINI.md; do
    [ -f "$root/$f" ] || continue
    lines=$(wc -l < "$root/$f" | tr -d ' ')
    if [ "$lines" -gt 500 ]; then echo "ERROR: $f has $lines lines (limit 500, target 200)"; status=1
    elif [ "$lines" -gt 200 ]; then echo "WARN:  $f has $lines lines (target 200)"; fi
  done
fi

if [ "$status" -ne 0 ]; then echo "INVALID"; exit 1; fi
echo "VALID ($mode mode)"
