<#
.SYNOPSIS
    Replace the ${user_config.zai_api_token} placeholders in the installed plugin's
    .mcp.json with the value of the ZAI_MCP_TOKEN environment variable.

.DESCRIPTION
    Windows counterpart of inject-mcp-token.sh.
    The recommended path is the userConfig field (auto-replaced by ZCode). This
    script is a fallback for environments where userConfig expansion is unavailable.
    It substitutes the placeholder that userConfig would have expanded.

    - Reads token from $env:ZAI_MCP_TOKEN (errors out if missing/empty)
    - Locates the newest installed x.y.z version dir under the plugin cache
      (or uses the one passed via -Version)
    - Backs up .mcp.json to .mcp.json.bak before editing
    - Idempotent: a file with no placeholder is treated as success (no rewrite)
    - Robust to special chars in the token (handled via literal .Replace())

.PARAMETER Version
    Target a specific installed version (e.g. 1.0.3). If omitted, the newest
    x.y.z version directory is auto-detected.

.EXAMPLE
    # Set token first (current session, or persist via setx / System settings)
    $env:ZAI_MCP_TOKEN = "your_zhipu_api_key"
    .\inject-mcp-token.ps1

.EXAMPLE
    .\inject-mcp-token.ps1 -Version 1.0.3
#>
[CmdletBinding()]
param(
    [string]$Version
)

$ErrorActionPreference = "Stop"

# ----------------------------- config -----------------------------
$PluginGroup = "annopick-plugin"
$PluginName  = "annopick-plugin"
$Placeholder = '${user_config.zai_api_token}'
$InstallRoot = Join-Path $env:USERPROFILE ".zcode\cli\plugins\cache\$PluginGroup\$PluginName"

# ----------------------------- validate token -----------------------------
$token = $env:ZAI_MCP_TOKEN
if ([string]::IsNullOrWhiteSpace($token)) {
    Write-Host "Error: env var ZAI_MCP_TOKEN is not set or empty." -ForegroundColor Red
    Write-Host "Run:  `$env:ZAI_MCP_TOKEN = '<your zhipu api key>'"
    Write-Host "(persist it with:  setx ZAI_MCP_TOKEN '<your key>'  , then reopen the terminal)"
    exit 1
}

# ----------------------------- locate plugin dir -----------------------------
if (-not (Test-Path -LiteralPath $InstallRoot)) {
    Write-Host "Error: plugin install dir not found: $InstallRoot" -ForegroundColor Red
    Write-Host "Please install the plugin in the ZCode client first, then re-run this script."
    exit 1
}

if (-not $Version) {
    # Use [version] so 1.10.0 sorts after 1.9.0 (Sort-Property Name would be
    # lexicographic and pick 1.9.0 as "newer").
    $latest = Get-ChildItem -LiteralPath $InstallRoot -Directory |
        Where-Object { $_.Name -match '^\d+\.\d+\.\d+$' } |
        Sort-Object -Property { [version]$_.Name } |
        Select-Object -Last 1
    if (-not $latest) {
        Write-Host "Error: no version directory (x.y.z) found under $InstallRoot" -ForegroundColor Red
        Write-Host "Pass the version explicitly:  .\inject-mcp-token.ps1 -Version 1.0.3"
        exit 1
    }
    $Version = $latest.Name
}

$VersionDir = Join-Path $InstallRoot $Version
$McpFile    = Join-Path $VersionDir ".mcp.json"

if (-not (Test-Path -LiteralPath $McpFile -PathType Leaf)) {
    Write-Host "Error: target file not found: $McpFile" -ForegroundColor Red
    Write-Host "Check that version ($Version) is correct and the plugin is fully installed."
    exit 1
}

Write-Host "Target version: $Version"
Write-Host "Target file:    $McpFile"

# ----------------------------- idempotency check -----------------------------
$content = Get-Content -LiteralPath $McpFile -Raw -Encoding UTF8
if (-not $content.Contains($Placeholder)) {
    Write-Host "Note: placeholder $Placeholder not found; file looks already substituted. Nothing to do." -ForegroundColor Yellow
    Write-Host "Done (no changes)." -ForegroundColor Green
    exit 0
}

# ----------------------------- backup -----------------------------
$Backup = "$McpFile.bak"
Copy-Item -LiteralPath $McpFile -Destination $Backup -Force
Write-Host "Backup:         $Backup"

# ----------------------------- perform replacement -----------------------------
# Use literal string replacement (not regex) so token chars like / & \ are safe.
$newContent = $content.Replace($Placeholder, $token)

# Preserve UTF-8 without BOM (the repo file has no BOM).
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($McpFile, $newContent, $utf8NoBom)

# ----------------------------- verify -----------------------------
$after = Get-Content -LiteralPath $McpFile -Raw -Encoding UTF8
if ($after.Contains($Placeholder)) {
    Write-Host "Error: placeholder still present after substitution; backup kept at $Backup for rollback." -ForegroundColor Red
    exit 1
}

$count = ($after | Select-String -SimpleMatch $token -AllMatches).Matches.Count
Write-Host "Substitution OK: $count occurrence(s) written." -ForegroundColor Green
Write-Host "Done." -ForegroundColor Green
