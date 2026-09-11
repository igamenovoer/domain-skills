Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    Write-Error "imsight-init: unable to resolve the script directory"
    exit 1
}

$scriptDirectory = (Resolve-Path -LiteralPath $PSScriptRoot).ProviderPath
$skillDirectory = Split-Path -Parent $scriptDirectory
$skillsRoot = Split-Path -Parent $skillDirectory

if ([string]::IsNullOrWhiteSpace($skillsRoot) -or -not (Test-Path -LiteralPath $skillsRoot -PathType Container)) {
    Write-Error "imsight-init: sibling skill root is unavailable: $skillsRoot"
    exit 1
}

function Normalize-DirectoryPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    return [IO.Path]::GetFullPath($Path).TrimEnd([char[]]"\/")
}

$currentSkillPath = Normalize-DirectoryPath -Path $skillDirectory
$skills = @(
    Get-ChildItem -LiteralPath $skillsRoot -Directory -Force |
        Where-Object {
            $candidatePath = Normalize-DirectoryPath -Path $_.FullName
            $entrypoint = Join-Path $_.FullName "SKILL.md"
            $_.Name -like "imsight-*" -and
                $candidatePath -ne $currentSkillPath -and
                (Test-Path -LiteralPath $entrypoint -PathType Leaf)
        } |
        Sort-Object -Property Name
)

if ($skills.Count -eq 0) {
    [Console]::Error.WriteLine(
        "imsight-init: no sibling imsight-* skills with SKILL.md found under $skillsRoot"
    )
    exit 1
}

Write-Output "Imsight skills root: $skillsRoot"
Write-Output "Discovered sibling Imsight skill entrypoints:"
foreach ($skill in $skills) {
    $entrypoint = (Resolve-Path -LiteralPath (Join-Path $skill.FullName "SKILL.md")).ProviderPath
    Write-Output ("- {0}: {1}" -f $skill.Name, $entrypoint)
}
Write-Output ""
Write-Output "Agent instruction: Inspect each listed SKILL.md name and description frontmatter to recover routing awareness. Read a matching SKILL.md completely before using that skill."
