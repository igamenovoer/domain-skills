[CmdletBinding()]
param(
    [string]$ApiKey = "",
    [string]$ProfilePath = "",
    [string]$KeyFilePath = "",
    [string]$BaseUrl = "https://gaccode.com/claudecode"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ProfilePath)) {
    $ProfilePath = $PROFILE.CurrentUserCurrentHost
}
if ([string]::IsNullOrWhiteSpace($KeyFilePath)) {
    $KeyFilePath = Join-Path $env:LOCALAPPDATA "Programs\gac-launcher\gac-api-key"
}
if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    $ApiKey = $env:GAC_API_KEY
}

function ConvertTo-SingleQuotedLiteral {
    param([string]$Value)

    return "'" + $Value.Replace("'", "''") + "'"
}

$keyFileLiteral = ConvertTo-SingleQuotedLiteral -Value $KeyFilePath
$baseUrlLiteral = ConvertTo-SingleQuotedLiteral -Value $BaseUrl

$functionTemplate = @'
function claude-gac {
    $keyFile = __KEY_FILE__
    if (-not (Test-Path -LiteralPath $keyFile)) {
        $secureKey = Read-Host -Prompt 'GAC API key' -AsSecureString
        $keyPtr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)
        try {
            $apiKey = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($keyPtr)
        }
        finally {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($keyPtr)
        }

        if ([string]::IsNullOrWhiteSpace($apiKey)) {
            Write-Error 'claude-gac: empty GAC API key'
            return
        }

        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $keyFile) | Out-Null
        Set-Content -LiteralPath $keyFile -Value $apiKey -Encoding UTF8 -NoNewline
    }
    else {
        $apiKey = (Get-Content -Raw -LiteralPath $keyFile).Trim()
        if ([string]::IsNullOrWhiteSpace($apiKey)) {
            Write-Error "claude-gac: empty GAC API key in $keyFile"
            return
        }
    }

    $previousBaseUrlExists = Test-Path Env:ANTHROPIC_BASE_URL
    $previousApiKeyExists = Test-Path Env:ANTHROPIC_API_KEY
    $previousDiscoveryExists = Test-Path Env:CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY
    $previousBaseUrl = $env:ANTHROPIC_BASE_URL
    $previousApiKey = $env:ANTHROPIC_API_KEY
    $previousDiscovery = $env:CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY
    $claudeExitCode = $null

    try {
        $env:ANTHROPIC_BASE_URL = __BASE_URL__
        $env:ANTHROPIC_API_KEY = $apiKey
        $env:CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY = '1'

        $claudeCommand = Get-Command claude -ErrorAction Stop | Select-Object -First 1
        & $claudeCommand @args
        $claudeExitCode = $LASTEXITCODE
    }
    finally {
        if ($previousBaseUrlExists) {
            $env:ANTHROPIC_BASE_URL = $previousBaseUrl
        }
        else {
            Remove-Item Env:ANTHROPIC_BASE_URL -ErrorAction SilentlyContinue
        }

        if ($previousApiKeyExists) {
            $env:ANTHROPIC_API_KEY = $previousApiKey
        }
        else {
            Remove-Item Env:ANTHROPIC_API_KEY -ErrorAction SilentlyContinue
        }

        if ($previousDiscoveryExists) {
            $env:CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY = $previousDiscovery
        }
        else {
            Remove-Item Env:CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY -ErrorAction SilentlyContinue
        }

        $apiKey = $null
    }

    if ($null -ne $claudeExitCode) {
        $global:LASTEXITCODE = $claudeExitCode
    }
}
'@

$functionBody = $functionTemplate.Replace('__KEY_FILE__', $keyFileLiteral).Replace('__BASE_URL__', $baseUrlLiteral)
$startMarker = '# >>> claude-gac launcher >>>'
$endMarker = '# <<< claude-gac launcher <<<'
$managedBlock = $startMarker + [Environment]::NewLine + $functionBody.TrimEnd() + [Environment]::NewLine + $endMarker

$profileDirectory = Split-Path -Parent $ProfilePath
New-Item -ItemType Directory -Force -Path $profileDirectory | Out-Null
$profileText = if (Test-Path -LiteralPath $ProfilePath) {
    Get-Content -Raw -LiteralPath $ProfilePath
}
else {
    ""
}

$managedPattern = '(?ms)^# >>> claude-gac launcher >>>\r?\n.*?^# <<< claude-gac launcher <<<\r?$'
if ([regex]::IsMatch($profileText, $managedPattern)) {
    $profileText = [regex]::Replace($profileText, $managedPattern, [System.Text.RegularExpressions.MatchEvaluator]{
        param($match)
        return $managedBlock
    })
}
else {
    if ($profileText -match '(?im)^\s*function\s+claude-gac\b') {
        throw "An unmanaged claude-gac function already exists in $ProfilePath; migrate it manually before running this generator."
    }

    if (-not [string]::IsNullOrEmpty($profileText) -and -not $profileText.EndsWith("`n")) {
        $profileText += [Environment]::NewLine
    }
    if (-not [string]::IsNullOrEmpty($profileText)) {
        $profileText += [Environment]::NewLine
    }
    $profileText += $managedBlock + [Environment]::NewLine
}

Set-Content -LiteralPath $ProfilePath -Value $profileText -Encoding UTF8 -NoNewline

if (-not [string]::IsNullOrWhiteSpace($ApiKey)) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $KeyFilePath) | Out-Null
    Set-Content -LiteralPath $KeyFilePath -Value $ApiKey -Encoding UTF8 -NoNewline
}

Write-Host "updated PowerShell profile: $ProfilePath"
Write-Host "GAC key file: $KeyFilePath"
if (-not (Test-Path -LiteralPath $KeyFilePath)) {
    Write-Host "next step: reload the profile and run claude-gac to enter the key securely"
}
