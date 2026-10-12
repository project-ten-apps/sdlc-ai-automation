<#
.SYNOPSIS
    Validates an agentic-readiness report before it is handed over.

.DESCRIPTION
    Checks that required sections exist and contain real content (not just the
    template), that no {{PLACEHOLDER}} is left, that every audit row has a
    red/amber/green status, that questionnaire answers are filled, and, with
    -ProjectRoot, that AGENTS.md / CLAUDE.md stay within the size limits.
    Exit code 0 = valid (warnings allowed), 1 = errors.

.EXAMPLE
    pwsh scripts/validate-report.ps1 -Path ../acme-agentic/agentic-readiness-report.md -Mode Audit
#>
param(
    [Parameter(Mandatory = $true)][string]$Path,
    [ValidateSet('Full', 'Audit')][string]$Mode = 'Full',
    [string]$ProjectRoot
)

$ErrorActionPreference = 'Stop'
$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

if (-not (Test-Path -LiteralPath $Path)) { Write-Host "ERROR: report not found: $Path"; exit 1 }
$lines = @(Get-Content -LiteralPath $Path -Encoding UTF8)
$templatePath = Join-Path $PSScriptRoot '..\templates\reports\agentic-readiness-report.md'
$templateLines = @{}
if (Test-Path -LiteralPath $templatePath) {
    foreach ($t in (Get-Content -LiteralPath $templatePath -Encoding UTF8)) { $templateLines[$t.Trim()] = $true }
}

function Get-Section([string]$Title) {
    $start = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match ('^##\s+' + [regex]::Escape($Title) + '\s*$')) { $start = $i; break }
    }
    if ($start -lt 0) { return $null }
    $body = New-Object System.Collections.Generic.List[string]
    for ($j = $start + 1; $j -lt $lines.Count; $j++) {
        if ($lines[$j] -match '^##\s') { break }
        $body.Add($lines[$j])
    }
    return , $body
}

function Get-TableRows($Body) {
    # Data rows only: skip the header row and the |---| separator.
    $rows = @()
    $seenSeparator = $false
    foreach ($l in $Body) {
        if ($l -notmatch '^\s*\|') { continue }
        if ($l -match '^\s*\|[\s\-:|]+\|\s*$') { $seenSeparator = $true; continue }
        if (-not $seenSeparator) { continue }
        $cells = $l.Trim().Trim('|').Split('|') | ForEach-Object { $_.Trim() }
        $rows += , @($cells)
    }
    return $rows
}

function Test-HasContent($Body) {
    foreach ($l in $Body) {
        $t = ($l -replace '<!--.*?-->', '').Trim()
        if (-not $t) { continue }
        if ($t -match '^\|[\s\-:|]+\|$') { continue }
        if ($templateLines.ContainsKey($l.Trim())) { continue }
        return $true
    }
    return $false
}

$required = @('Questionnaire answers', 'Audit (before)', 'Security summary', 'Recommended next steps')
if ($Mode -eq 'Full') {
    $required += @('Tools installed', 'Generated files', 'Migration plan', 'Pilot (after)', 'Readiness after')
}

foreach ($s in $required) {
    $body = Get-Section $s
    if ($null -eq $body) { $errors.Add("missing section: ## $s"); continue }
    if (-not (Test-HasContent $body)) { $errors.Add("section not filled in: ## $s") }
}

# Placeholders
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '\{\{[A-Z0-9_]+\}\}') { $errors.Add("unfilled placeholder on line $($i + 1): $($Matches[0])") }
}

# Audit statuses
$audit = Get-Section 'Audit (before)'
if ($null -ne $audit) {
    $rows = Get-TableRows $audit
    if ($rows.Count -eq 0) { $errors.Add('audit table has no rows') }
    foreach ($r in $rows) {
        $status = if ($r.Count -gt 1) { $r[1].ToLower() } else { '' }
        if ($status -notmatch '^(red|amber|green)$') { $errors.Add("audit row '$($r[0])' needs status red, amber or green (found '$($r[1])')") }
        elseif ($r.Count -gt 2 -and -not $r[2]) { $warnings.Add("audit row '$($r[0])' has no evidence") }
    }
}

# Questionnaire answers
$q = Get-Section 'Questionnaire answers'
if ($null -ne $q) {
    $mustAnswer = if ($Mode -eq 'Audit') { @('1', '4', '11') } else { $null }
    foreach ($r in (Get-TableRows $q)) {
        if ($null -ne $mustAnswer -and $mustAnswer -notcontains $r[0]) { continue }
        if ($r.Count -lt 3 -or -not $r[2]) { $errors.Add("questionnaire answer #$($r[0]) is empty") }
    }
}

# Instruction size
if ($ProjectRoot) {
    foreach ($f in @('AGENTS.md', 'CLAUDE.md', 'GEMINI.md')) {
        $p = Join-Path $ProjectRoot $f
        if (-not (Test-Path -LiteralPath $p)) { continue }
        $n = @(Get-Content -LiteralPath $p).Count
        if ($n -gt 500) { $errors.Add("$f has $n lines (limit 500, target 200)") }
        elseif ($n -gt 200) { $warnings.Add("$f has $n lines (target 200)") }
    }
}

foreach ($w in $warnings) { Write-Host "WARN:  $w" }
foreach ($e in $errors) { Write-Host "ERROR: $e" }
if ($errors.Count -gt 0) { Write-Host "INVALID ($($errors.Count) errors, $($warnings.Count) warnings)"; exit 1 }
Write-Host "VALID ($Mode mode, $($warnings.Count) warnings)"
exit 0
