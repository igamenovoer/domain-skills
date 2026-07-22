param(
    [string]$ApiKey = "",
    [string]$OutputPath = "",
    [string]$CmdShimPath = "",
    [string]$KeyFilePath = "",
    [string]$BaseUrl = "https://api.moonshot.ai/anthropic",
    [string]$Model = "kimi-k3",
    [string]$CompactWindow = "",
    [string]$ClaudeBin = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    $ApiKey = $env:KIMI_API_KEY
}
if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    $ApiKey = $env:ANTHROPIC_API_KEY
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $env:LOCALAPPDATA "Programs\kimi-launchers\claude-kimi.ps1"
}
if ([string]::IsNullOrWhiteSpace($CmdShimPath)) {
    $CmdShimPath = Join-Path (Split-Path -Parent $OutputPath) "claude-kimi.cmd"
}
if ([string]::IsNullOrWhiteSpace($KeyFilePath)) {
    $KeyFilePath = Join-Path (Split-Path -Parent $OutputPath) "kimi-api-key"
}

if ([string]::IsNullOrWhiteSpace($CompactWindow)) {
    if ($Model -match 'k2\.' -or $Model -like 'kimi-for-coding*' -or $Model -eq 'k3') {
        # K2-series models, the K2.7 Code family, and coding-plan k3
        # (Moderato tier) use a 256K context window.
        $CompactWindow = '262144'
    } else {
        # kimi-k3 and coding-plan k3[1m] use a 1M context window.
        $CompactWindow = '1048576'
    }
}
if ($CompactWindow -notmatch '^\d+$') {
    Write-Error "invalid -CompactWindow: $CompactWindow (expected a number)"
    exit 2
}

# The Kimi Code membership endpoint authenticates with ANTHROPIC_API_KEY;
# the Moonshot API-platform endpoint authenticates with ANTHROPIC_AUTH_TOKEN.
$useApiKeyAuth = $BaseUrl -like '*api.kimi.com*'

function ConvertTo-SingleQuotedLiteralValue {
    param([string]$Value)
    return $Value.Replace("'", "''")
}

$keyFileLiteral = ConvertTo-SingleQuotedLiteralValue -Value $KeyFilePath
$baseUrlLiteral = ConvertTo-SingleQuotedLiteralValue -Value $BaseUrl
$modelLiteral = ConvertTo-SingleQuotedLiteralValue -Value $Model
$claudeBinLiteral = ConvertTo-SingleQuotedLiteralValue -Value $ClaudeBin

if ($useApiKeyAuth) {
    $authBlock = @"
`$env:ANTHROPIC_API_KEY = `$apiKey
Remove-Item Env:ANTHROPIC_AUTH_TOKEN -ErrorAction SilentlyContinue
Remove-Item Env:CLAUDE_CODE_OAUTH_TOKEN -ErrorAction SilentlyContinue
"@
    $laneBlock = @"
`$env:ANTHROPIC_DEFAULT_FABLE_MODEL = `$kimiModel
if ([string]::IsNullOrWhiteSpace(`$env:CLAUDE_CODE_MAX_CONTEXT_TOKENS)) {
    `$env:CLAUDE_CODE_MAX_CONTEXT_TOKENS = '$CompactWindow'
}
if (`$kimiModel -eq 'k3' -or `$kimiModel -eq 'k3[1m]') {
    # Only K3 supports CLAUDE_CODE_EFFORT_LEVEL, and only max.
    if ([string]::IsNullOrWhiteSpace(`$env:CLAUDE_CODE_EFFORT_LEVEL)) {
        `$env:CLAUDE_CODE_EFFORT_LEVEL = 'max'
    }
}
"@
} else {
    $authBlock = @"
`$env:ANTHROPIC_AUTH_TOKEN = `$apiKey
Remove-Item Env:ANTHROPIC_API_KEY -ErrorAction SilentlyContinue
Remove-Item Env:CLAUDE_CODE_OAUTH_TOKEN -ErrorAction SilentlyContinue
"@
    $laneBlock = @"
if ([string]::IsNullOrWhiteSpace(`$env:ENABLE_TOOL_SEARCH)) {
    `$env:ENABLE_TOOL_SEARCH = 'false'
}
"@
}

$launcher = @"
`$ErrorActionPreference = 'Stop'

`$keyFile = '$keyFileLiteral'
if (-not (Test-Path -LiteralPath `$keyFile)) {
    `$secureKey = Read-Host -Prompt 'Kimi API key' -AsSecureString
    `$keyPtr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR(`$secureKey)
    try {
        `$apiKey = [Runtime.InteropServices.Marshal]::PtrToStringBSTR(`$keyPtr)
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR(`$keyPtr)
    }
    if ([string]::IsNullOrWhiteSpace(`$apiKey)) {
        Write-Error 'claude-kimi: empty Kimi API key'
        exit 2
    }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent `$keyFile) | Out-Null
    Set-Content -LiteralPath `$keyFile -Value `$apiKey -Encoding UTF8
} else {
    `$apiKey = (Get-Content -LiteralPath `$keyFile -Raw).Trim()
    if ([string]::IsNullOrWhiteSpace(`$apiKey)) {
        Write-Error "claude-kimi: empty Kimi API key in `$keyFile"
        exit 2
    }
}

$authBlock
`$env:ANTHROPIC_BASE_URL = '$baseUrlLiteral'
if ([string]::IsNullOrWhiteSpace(`$env:CLAUDE_CODE_AUTO_COMPACT_WINDOW)) {
    `$env:CLAUDE_CODE_AUTO_COMPACT_WINDOW = '$CompactWindow'
}

`$node = Get-Command node -ErrorAction SilentlyContinue
if (`$node) {
    & `$node.Source --eval @'
const fs = require('fs');
const os = require('os');
const path = require('path');
const filePath = path.join(os.homedir(), '.claude.json');
const content = fs.existsSync(filePath)
  ? JSON.parse(fs.readFileSync(filePath, 'utf-8'))
  : {};
fs.writeFileSync(
  filePath,
  JSON.stringify({ ...content, hasCompletedOnboarding: true }, null, 2),
  'utf-8'
);
'@
}

`$kimiModel = if ([string]::IsNullOrWhiteSpace(`$env:CLAUDE_KIMI_MODEL)) { '$modelLiteral' } else { `$env:CLAUDE_KIMI_MODEL }
`$env:ANTHROPIC_DEFAULT_OPUS_MODEL = `$kimiModel
`$env:ANTHROPIC_DEFAULT_SONNET_MODEL = `$kimiModel
`$env:ANTHROPIC_DEFAULT_HAIKU_MODEL = `$kimiModel
`$env:CLAUDE_CODE_SUBAGENT_MODEL = `$kimiModel
$laneBlock
`$claudeBin = '$claudeBinLiteral'
if ([string]::IsNullOrWhiteSpace(`$claudeBin)) {
    `$claude = Get-Command claude -ErrorAction SilentlyContinue
    if (`$claude) {
        `$claudeBin = `$claude.Source
    }
}
if ([string]::IsNullOrWhiteSpace(`$claudeBin)) {
    Write-Error 'claude-kimi: claude binary not found'
    exit 127
}

`$addModel = `$true
foreach (`$arg in `$args) {
    # Runtime args belong to Claude Code. The launcher only observes them to avoid
    # injecting duplicate defaults; it must not consume or reinterpret Claude flags.
    if (`$arg -eq '--model' -or `$arg.StartsWith('--model=') -or `$arg -eq '--help' -or `$arg -eq '-h' -or `$arg -eq '--version' -or `$arg -eq '-v') {
        `$addModel = `$false
    }
}

if (`$addModel) {
    & `$claudeBin --dangerously-skip-permissions --model `$kimiModel @args
} else {
    & `$claudeBin --dangerously-skip-permissions @args
}
exit `$LASTEXITCODE
"@

$outputDir = Split-Path -Parent $OutputPath
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
Set-Content -LiteralPath $OutputPath -Value $launcher -Encoding UTF8

if (-not [string]::IsNullOrWhiteSpace($ApiKey)) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $KeyFilePath) | Out-Null
    Set-Content -LiteralPath $KeyFilePath -Value $ApiKey -Encoding UTF8
}

$cmdDir = Split-Path -Parent $CmdShimPath
New-Item -ItemType Directory -Force -Path $cmdDir | Out-Null
$ps1ForCmd = $OutputPath.Replace("%", "%%")
$shim = @"
@echo off
where pwsh.exe >nul 2>nul
if %ERRORLEVEL% equ 0 (
  pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "$ps1ForCmd" %*
) else (
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$ps1ForCmd" %*
)
"@
Set-Content -LiteralPath $CmdShimPath -Value $shim -Encoding ASCII

Write-Host "created $OutputPath"
Write-Host "created $CmdShimPath"
Write-Host "key file: $KeyFilePath"
