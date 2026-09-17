[CmdletBinding()]
param(
    [string]$ApiKey = "",
    [string]$ProfilePath = "",
    [switch]$RequirePermissionPrompts
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$baseUrl = 'https://gaccode.com/claudecode'

if ([string]::IsNullOrWhiteSpace($ProfilePath)) {
    $ProfilePath = $PROFILE.CurrentUserCurrentHost
}
if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    $ApiKey = $env:GAC_API_KEY
}
if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    $secureKey = Read-Host -Prompt 'GAC API key' -AsSecureString
    $keyPtr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)
    try {
        $ApiKey = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($keyPtr)
    }
    finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($keyPtr)
    }
}
if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    throw 'create-claude-gac-launcher: empty GAC API key'
}

function ConvertTo-SingleQuotedLiteral {
    param([string]$Value)

    return "'" + $Value.Replace("'", "''") + "'"
}

$apiKeyLiteral = ConvertTo-SingleQuotedLiteral -Value $ApiKey
$baseUrlLiteral = ConvertTo-SingleQuotedLiteral -Value $baseUrl
$permissionArgumentsLiteral = if ($RequirePermissionPrompts) { '@()' } else { "@('--dangerously-skip-permissions')" }

$functionTemplate = @'
function claude-gac {
    $previousBaseUrlExists = Test-Path Env:ANTHROPIC_BASE_URL
    $previousApiKeyExists = Test-Path Env:ANTHROPIC_API_KEY
    $previousAuthTokenExists = Test-Path Env:ANTHROPIC_AUTH_TOKEN
    $previousOauthTokenExists = Test-Path Env:CLAUDE_CODE_OAUTH_TOKEN
    $previousDiscoveryExists = Test-Path Env:CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY
    $previousBaseUrl = $env:ANTHROPIC_BASE_URL
    $previousApiKey = $env:ANTHROPIC_API_KEY
    $previousAuthToken = $env:ANTHROPIC_AUTH_TOKEN
    $previousOauthToken = $env:CLAUDE_CODE_OAUTH_TOKEN
    $previousDiscovery = $env:CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY
    $claudeExitCode = $null

    try {
        $env:ANTHROPIC_BASE_URL = __BASE_URL__
        $env:ANTHROPIC_API_KEY = __API_KEY__
        Remove-Item Env:ANTHROPIC_AUTH_TOKEN -ErrorAction SilentlyContinue
        Remove-Item Env:CLAUDE_CODE_OAUTH_TOKEN -ErrorAction SilentlyContinue
        $env:CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY = '1'

        $claudeCommand = Get-Command claude -ErrorAction Stop | Select-Object -First 1
        $defaultPermissionArguments = __PERMISSION_ARGUMENTS__
        & $claudeCommand @defaultPermissionArguments @args
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

        if ($previousAuthTokenExists) {
            $env:ANTHROPIC_AUTH_TOKEN = $previousAuthToken
        }
        else {
            Remove-Item Env:ANTHROPIC_AUTH_TOKEN -ErrorAction SilentlyContinue
        }

        if ($previousOauthTokenExists) {
            $env:CLAUDE_CODE_OAUTH_TOKEN = $previousOauthToken
        }
        else {
            Remove-Item Env:CLAUDE_CODE_OAUTH_TOKEN -ErrorAction SilentlyContinue
        }

        if ($previousDiscoveryExists) {
            $env:CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY = $previousDiscovery
        }
        else {
            Remove-Item Env:CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY -ErrorAction SilentlyContinue
        }
    }

    if ($null -ne $claudeExitCode) {
        $global:LASTEXITCODE = $claudeExitCode
    }
}
'@

$functionBody = $functionTemplate.Replace('__BASE_URL__', $baseUrlLiteral).Replace('__API_KEY__', $apiKeyLiteral).Replace('__PERMISSION_ARGUMENTS__', $permissionArgumentsLiteral)
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
if ($null -eq $profileText) {
    $profileText = ""
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
$ApiKey = $null

Write-Host "updated PowerShell profile: $ProfilePath"
Write-Host 'embedded the fixed GAC endpoint and provided API key in the managed claude-gac block'
if ($RequirePermissionPrompts) {
    Write-Host 'permission mode: prompts enabled (explicit opt-out)'
}
else {
    Write-Host 'permission mode: --dangerously-skip-permissions (default)'
}
