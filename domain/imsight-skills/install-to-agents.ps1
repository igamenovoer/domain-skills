<#
.SYNOPSIS
    Install the local imsight-* skills into a supported agent skills directory.

.DESCRIPTION
    Discovers all imsight-* skill directories next to this script, removes any
    pre-existing imsight-* entries in the chosen destination, then installs the
    skills by copy or symlink.

.PARAMETER Target
    Agent target: claude-code, generic, kimi-code, codex. Default: generic.

.PARAMETER Mode
    Install mode: copy or symlink. Default: copy.

.PARAMETER Scope
    Install scope: global (under $HOME) or project (under the current directory).
    Default: project.

.PARAMETER Yes
    Skip the confirmation prompt.

.EXAMPLE
    .\install-to-agents.ps1
    # Installs with defaults: generic, copy, project scope.

.EXAMPLE
    .\install-to-agents.ps1 -Target kimi-code -Mode symlink -Scope global -Yes
    # Symlinks all imsight skills into ~/.kimi-code/skills without prompting.
#>
[CmdletBinding()]
param(
    [ValidateSet("claude-code", "generic", "kimi-code", "codex")]
    [string]$Target = "generic",

    [ValidateSet("copy", "symlink")]
    [string]$Mode = "copy",

    [ValidateSet("global", "project")]
    [string]$Scope = "project",

    [switch]$Yes
)

$ErrorActionPreference = "Stop"

$scriptDir = $PSScriptRoot

if ($Scope -eq "global") {
    switch ($Target) {
        "claude-code" { $destRoot = Join-Path $HOME ".claude" "skills" }
        "kimi-code"   { $destRoot = Join-Path $HOME ".kimi-code" "skills" }
        "codex"       {
            $codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
            $destRoot = Join-Path $codexHome "skills"
        }
        "generic"     { $destRoot = Join-Path $HOME ".agents" "skills" }
    }
} else {
    switch ($Target) {
        "claude-code" { $destRoot = Join-Path $PWD ".claude" "skills" }
        "kimi-code"   { $destRoot = Join-Path $PWD ".kimi-code" "skills" }
        "codex"       { $destRoot = Join-Path $PWD ".codex" "skills" }
        "generic"     { $destRoot = Join-Path $PWD ".agents" "skills" }
    }
}

New-Item -ItemType Directory -Path $destRoot -Force | Out-Null
$destRoot = (Resolve-Path $destRoot).Path

$skills = Get-ChildItem -Path $scriptDir -Directory -Filter "imsight-*" | Select-Object -ExpandProperty Name

if ($skills.Count -eq 0) {
    Write-Error "No imsight-* skill directories found in $scriptDir"
    exit 1
}

if (-not $Yes) {
    if (-not [Environment]::UserInteractive) {
        Write-Error "This script removes existing imsight-* entries in $destRoot before installing. Run with -Yes to confirm non-interactively."
        exit 2
    }

    Write-Host "This will install $($skills.Count) imsight skill(s) into:"
    Write-Host "  $destRoot"
    Write-Host "Any existing imsight-* entries there will be removed first."
    $reply = Read-Host "Continue? [Y/n]"
    if ($reply -notmatch '^(|y|yes)$') {
        Write-Host "Aborted."
        exit 1
    }
}

Write-Host "Installing imsight skills for target=$Target mode=$Mode scope=$Scope into $destRoot"

# Remove any existing imsight-* entries. Remove-Item on a symlink removes the
# link itself, not its target, so the source tree is never deleted.
Get-ChildItem -Path $destRoot -Filter "imsight-*" -ErrorAction SilentlyContinue |
    Remove-Item -Recurse -Force

foreach ($name in $skills) {
    $src = Join-Path $scriptDir $name
    $dst = Join-Path $destRoot $name

    if ($Mode -eq "symlink") {
        New-Item -ItemType SymbolicLink -Path $dst -Target $src | Out-Null
    } else {
        Copy-Item -Path $src -Destination $dst -Recurse -Force
    }

    Write-Host "  $name"
}

Write-Host "Installed $($skills.Count) skill(s)."
