<#
.SYNOPSIS
    Installs the agentic-readiness skill for Claude Code and other coding agents.

.DESCRIPTION
    Links (directory junction, no admin rights needed) or copies ./agentic-readiness
    into the user-level skill folders of the selected tools. For tools you want to
    drive through global instructions instead of skills, it can append a small,
    idempotent snippet (between marker comments) to their global instruction file.

    Skill folders (checked 2026-10-09):
      claude    ~/.claude/skills              Claude Code (does NOT read ~/.agents/skills)
      agents    ~/.agents/skills              Codex CLI, Gemini CLI, Cursor, GitHub Copilot,
                                              Windsurf/Devin, OpenCode
      gemini    ~/.gemini/skills              Gemini CLI only
      cursor    ~/.cursor/skills              Cursor only
      copilot   ~/.copilot/skills             GitHub Copilot only
      opencode  ~/.config/opencode/skills     OpenCode only
      windsurf  ~/.codeium/windsurf/skills    Windsurf/Devin only

    Default: claude + agents, which covers all seven tools. Adding tool-specific
    folders on top of "agents" makes those tools see the skill twice.

.PARAMETER Targets
    Skill folders to install into. Default: claude, agents. Use 'all' for every folder.

.PARAMETER Mode
    Link (default): directory junction to this repo, so 'git pull' updates every tool.
    Copy: independent copy (use when the repo will move or on shared machines).

.PARAMETER Force
    Replace an existing agentic-readiness folder/link in a target.

.PARAMETER Uninstall
    Remove the skill from the targets and the snippet from the instruction files.

.PARAMETER Instructions
    Append a pointer snippet to these tools' global instruction files:
      claude   ~/.claude/CLAUDE.md
      codex    ~/.codex/AGENTS.md
      gemini   ~/.gemini/GEMINI.md
      copilot  ~/.copilot/copilot-instructions.md
      opencode ~/.config/opencode/AGENTS.md
      windsurf ~/.codeium/windsurf/memories/global_rules.md
    Only needed for tools without skills support or when you want the skill
    mentioned explicitly. Existing content is kept; the snippet is replaced in place.

.PARAMETER HomeDir
    Folder used instead of your user profile (for testing).

.PARAMETER SnippetPath
    Write the pointer snippet to this file (for any other tool: paste it into its
    rules/instructions settings). Does not install anything else unless other
    parameters are given.

.EXAMPLE
    ./install.ps1
.EXAMPLE
    ./install.ps1 -Targets claude,agents -Mode Copy -Force
.EXAMPLE
    ./install.ps1 -Targets @() -Instructions codex,windsurf
.EXAMPLE
    ./install.ps1 -SnippetPath ./dist/agentic-readiness.rules.md -Targets @()
.EXAMPLE
    ./install.ps1 -Uninstall -Targets all -Instructions claude,codex,gemini,copilot,opencode,windsurf
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateSet('claude', 'agents', 'gemini', 'cursor', 'copilot', 'opencode', 'windsurf', 'all')]
    [string[]]$Targets = @('claude', 'agents'),

    [ValidateSet('Link', 'Copy')]
    [string]$Mode = 'Link',

    [switch]$Force,

    [switch]$Uninstall,

    [ValidateSet('claude', 'codex', 'gemini', 'copilot', 'opencode', 'windsurf')]
    [string[]]$Instructions = @(),

    [string]$SnippetPath,

    # Base folder that stands in for ~ (default: your user profile). Useful for testing.
    [string]$HomeDir = [Environment]::GetFolderPath('UserProfile')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$SkillName = 'agentic-readiness'
$SourceDir = Join-Path $PSScriptRoot $SkillName
$UserHome = $HomeDir
$MarkerBegin = "<!-- BEGIN $SkillName (managed by install.ps1) -->"
$MarkerEnd = "<!-- END $SkillName -->"

$SkillDirs = [ordered]@{
    claude   = Join-Path $UserHome '.claude\skills'
    agents   = Join-Path $UserHome '.agents\skills'
    gemini   = Join-Path $UserHome '.gemini\skills'
    cursor   = Join-Path $UserHome '.cursor\skills'
    copilot  = Join-Path $UserHome '.copilot\skills'
    opencode = Join-Path $UserHome '.config\opencode\skills'
    windsurf = Join-Path $UserHome '.codeium\windsurf\skills'
}

$InstructionFiles = [ordered]@{
    claude   = Join-Path $UserHome '.claude\CLAUDE.md'
    codex    = Join-Path $UserHome '.codex\AGENTS.md'
    gemini   = Join-Path $UserHome '.gemini\GEMINI.md'
    copilot  = Join-Path $UserHome '.copilot\copilot-instructions.md'
    opencode = Join-Path $UserHome '.config\opencode\AGENTS.md'
    windsurf = Join-Path $UserHome '.codeium\windsurf\memories\global_rules.md'
}

function Test-ReparsePoint([string]$Path) {
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    return ($null -ne $item) -and (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0)
}

function Remove-SkillFolder([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return }
    if (Test-ReparsePoint $Path) {
        # Deletes only the junction/symlink, never the target repo.
        [IO.Directory]::Delete($Path)
    }
    else {
        [IO.Directory]::Delete($Path, $true)
    }
}

function Get-SnippetText {
    $skillFile = Join-Path $SourceDir 'SKILL.md'
    if ($SkillDirs.Contains('agents')) {
        $installed = Join-Path (Join-Path $SkillDirs['agents'] $SkillName) 'SKILL.md'
        if (Test-Path -LiteralPath $installed) { $skillFile = $installed }
    }
    $skillFile = $skillFile -replace '\\', '/'
    return @"
$MarkerBegin
## Agentic readiness

When asked to prepare a repository for agentic / AI-assisted development (agent setup, AGENTS.md, project skills, subagents, readiness audit), read ``$skillFile`` and follow it step by step. Its supporting files (questionnaire, stack guides, templates) are in the same folder; read them only when a step points to them.
$MarkerEnd
"@
}

function Set-Snippet([string]$File, [bool]$Remove) {
    $content = ''
    if (Test-Path -LiteralPath $File) { $content = [IO.File]::ReadAllText($File) }
    $pattern = '(?s)\r?\n?' + [regex]::Escape($MarkerBegin) + '.*?' + [regex]::Escape($MarkerEnd) + '\r?\n?'
    $stripped = [regex]::Replace($content, $pattern, "`n").TrimEnd()

    if ($Remove) {
        if ($stripped -eq $content.TrimEnd()) { Write-Host "  no snippet in $File"; return }
        if ($PSCmdlet.ShouldProcess($File, 'Remove agentic-readiness snippet')) {
            [IO.File]::WriteAllText($File, $stripped + "`n")
            Write-Host "  removed snippet from $File"
        }
        return
    }

    $new = (Get-SnippetText).Trim()
    $result = if ($stripped) { "$stripped`n`n$new`n" } else { "$new`n" }
    if ($PSCmdlet.ShouldProcess($File, 'Write agentic-readiness snippet')) {
        $dir = Split-Path -Parent $File
        if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        [IO.File]::WriteAllText($File, $result)
        Write-Host "  snippet written to $File"
    }
}

if (-not (Test-Path -LiteralPath (Join-Path $SourceDir 'SKILL.md'))) {
    throw "Skill not found at $SourceDir. Run this script from the repository root."
}

if ($Targets -contains 'all') { $Targets = @($SkillDirs.Keys) }
$Targets = @($Targets | Select-Object -Unique)

$specific = @($Targets | Where-Object { $_ -notin @('claude', 'agents') })
if (($Targets -contains 'agents') -and $specific.Count -gt 0) {
    Write-Warning ("'agents' already covers $($specific -join ', '); those tools will list the skill twice.")
}

# Skill folders
foreach ($t in $Targets) {
    $root = $SkillDirs[$t]
    $dest = Join-Path $root $SkillName
    Write-Host "[$t] $dest"

    if ($Uninstall) {
        if (Test-Path -LiteralPath $dest) {
            if ($PSCmdlet.ShouldProcess($dest, 'Remove skill')) { Remove-SkillFolder $dest; Write-Host '  removed' }
        }
        else { Write-Host '  not installed' }
        continue
    }

    if (Test-Path -LiteralPath $dest) {
        if (-not $Force) {
            $kind = if (Test-ReparsePoint $dest) { 'link' } else { 'folder' }
            Write-Host "  already installed ($kind); use -Force to replace"
            continue
        }
        if ($PSCmdlet.ShouldProcess($dest, 'Replace existing skill')) { Remove-SkillFolder $dest }
    }

    if (-not $PSCmdlet.ShouldProcess($dest, "Install skill ($Mode)")) { continue }
    if (-not (Test-Path -LiteralPath $root)) { New-Item -ItemType Directory -Path $root -Force | Out-Null }

    if ($Mode -eq 'Link') {
        New-Item -ItemType Junction -Path $dest -Target $SourceDir | Out-Null
        Write-Host "  linked -> $SourceDir"
    }
    else {
        Copy-Item -LiteralPath $SourceDir -Destination $dest -Recurse
        Write-Host '  copied'
    }
}

# Global instruction snippets
foreach ($tool in $Instructions) {
    Write-Host "[instructions:$tool]"
    Set-Snippet -File $InstructionFiles[$tool] -Remove:$Uninstall.IsPresent
}

# Stand-alone snippet for any other tool
if ($SnippetPath -and -not $Uninstall) {
    if ($PSCmdlet.ShouldProcess($SnippetPath, 'Write snippet file')) {
        $dir = Split-Path -Parent ([IO.Path]::GetFullPath($SnippetPath))
        if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        [IO.File]::WriteAllText([IO.Path]::GetFullPath($SnippetPath), (Get-SnippetText).Trim() + "`n")
        Write-Host "[snippet] $SnippetPath"
    }
}

Write-Host 'Done. Restart running agent sessions so they pick up the change.'
