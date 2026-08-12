<#
.SYNOPSIS
    Set the `model:` field in the frontmatter of the four frontend agent files
    (frontend-developer.md, frontend-acceptance.md, antd-developer.md, antd-acceptance.md)
    under the INSTALLED plugin dir.

.DESCRIPTION
    Windows counterpart of inject-agent-model.sh.

    The model value has the form:  custom:<provider-key>:<model-id>
      - provider-key: read from ~/.zcode/v2/config.json; colons are URL-encoded
        to %3A because ':' is the field separator (e.g. builtin:bigmodel ->
        builtin%3Abigmodel). A UUID key like the default kimi one needs no encoding.
      - model-id: a model key nested under the chosen provider in config.json.

    Defaults to the Kimi K3 model:
      provider = 623553b2-da8a-4b43-9320-90b1ed62a12b
      modelid  = k3

    - If the agent file has a `model:` line, replace it in place.
    - If it has no `model:` line, insert one right before the closing `---` of
      the frontmatter.
    - Backs up each file to <file>.bak before editing.
    - Idempotent: re-running with the same value is a no-op (exit 0).
    - Validates that provider and model exist in config.json before writing.

.PARAMETER Provider
    Provider key from config.json. Defaults to the Kimi provider UUID.

.PARAMETER Model
    Model id under the chosen provider. Defaults to 'k3'.

.PARAMETER Version
    Target a specific installed version. If omitted, newest x.y.z is auto-detected.

.EXAMPLE
    .\inject-agent-model.ps1
    .\inject-agent-model.ps1 -Version 1.0.3
    .\inject-agent-model.ps1 -Provider "builtin:bigmodel-coding-plan" -Model GLM-5.2
#>
[CmdletBinding()]
param(
    [string]$Provider = "623553b2-da8a-4b43-9320-90b1ed62a12b",
    [string]$Model    = "k3",
    [string]$Version
)

$ErrorActionPreference = "Stop"

# ----------------------------- config -----------------------------
$PluginGroup = "annopick-plugin"
$PluginName  = "annopick-plugin"
$InstallRoot = Join-Path $env:USERPROFILE ".zcode\cli\plugins\cache\$PluginGroup\$PluginName"
$ConfigFile  = Join-Path $env:USERPROFILE ".zcode\v2\config.json"
$AgentFiles  = @("frontend-developer.md", "frontend-acceptance.md", "antd-developer.md", "antd-acceptance.md")

# ----------------------------- sanity -----------------------------
if ([string]::IsNullOrWhiteSpace($Provider) -or [string]::IsNullOrWhiteSpace($Model)) {
    Write-Host "Error: -Provider and -Model must both be non-empty." -ForegroundColor Red
    exit 2
}

# ----------------------------- validate against config.json -----------------------------
if (-not (Test-Path -LiteralPath $ConfigFile -PathType Leaf)) {
    Write-Host "Error: config file not found: $ConfigFile" -ForegroundColor Red
    Write-Host "Cannot verify provider/model. Ensure ZCode is initialized."
    exit 1
}

$cfg = Get-Content -LiteralPath $ConfigFile -Raw -Encoding UTF8 | ConvertFrom-Json
$providers = $cfg.provider.PSObject.Properties
$provInfo = $null
foreach ($p in $providers) {
    if ($p.Name -eq $Provider) { $provInfo = $p.Value; break }
}
if (-not $provInfo) {
    Write-Host "Error: provider '$Provider' not found in $ConfigFile" -ForegroundColor Red
    Write-Host "Available providers:"
    foreach ($p in $providers) { Write-Host "   - $($p.Name)" }
    exit 1
}

$modelExists = $false
if ($provInfo.models) {
    foreach ($m in $provInfo.models.PSObject.Properties) {
        if ($m.Name -eq $Model) { $modelExists = $true; break }
    }
}
if (-not $modelExists) {
    Write-Host "Error: model '$Model' not found under provider '$Provider'." -ForegroundColor Red
    Write-Host "Available models for this provider:"
    foreach ($m in $provInfo.models.PSObject.Properties) { Write-Host "   - $($m.Name)" }
    exit 1
}

# ----------------------------- build model value -----------------------------
$providerEnc = $Provider.Replace(':', '%3A')
$modelValue = "custom:${providerEnc}:${Model}"

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
        Write-Host "Pass the version explicitly:  .\inject-agent-model.ps1 -Version 1.0.3"
        exit 1
    }
    $Version = $latest.Name
}

$VersionDir = Join-Path $InstallRoot $Version
$AgentsDir  = Join-Path $VersionDir "agents"

Write-Host "Plugin version: $Version"
Write-Host "Agents dir:     $AgentsDir"
Write-Host "Model value:    $modelValue"
Write-Host ""

if (-not (Test-Path -LiteralPath $AgentsDir)) {
    Write-Host "Error: agents dir not found: $AgentsDir" -ForegroundColor Red
    exit 1
}

# ----------------------------- per-file edit -----------------------------
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Edit-AgentFile {
    param(
        [string]$Path,
        [string]$Value
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Write-Host ("  {0,-28} skip: file not found" -f (Split-Path $Path -Leaf)) -ForegroundColor Yellow
        return $false
    }

    # Read raw text so we can preserve the original newline style (LF vs CRLF)
    # and trailing-newline presence, mirroring bash's readlines()/writelines()
    # which is byte-faithful. WriteAllLines would normalize to CRLF on Windows.
    $raw = [System.IO.File]::ReadAllText($Path)
    if ($raw.Length -eq 0) {
        Write-Host ("  {0,-28} error: file is empty" -f (Split-Path $Path -Leaf)) -ForegroundColor Red
        return $false
    }
    if ($raw.Contains("`r`n")) { $nl = "`r`n" } else { $nl = "`n" }
    $hadTrailingNl = $raw.EndsWith($nl)
    $body = if ($hadTrailingNl) { $raw.Substring(0, $raw.Length - $nl.Length) } else { $raw }

    $lines = [System.Collections.Generic.List[string]]::new()
    foreach ($l in $body.Split($nl)) { $lines.Add($l) }

    $modelLine = "model: `"$Value`""

    # 0) idempotency: already the target value (with or without quotes)
    foreach ($ln in $lines) {
        $trimmed = $ln.Trim()
        if ($trimmed -eq "model: `"$Value`"" -or $trimmed -eq "model: $Value") {
            Write-Host ("  {0,-28} already set, skip" -f (Split-Path $Path -Leaf))
            return $true
        }
    }

    # backup
    Copy-Item -LiteralPath $Path -Destination "$Path.bak" -Force

    # 1) replace existing ^model: line (case-SENSITIVE, matching bash grep -E)
    $replaced = $false
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -cmatch '^model:') {
            $lines[$i] = $modelLine
            $replaced = $true
            break
        }
    }

    # 2) no model line -> insert before the closing '---' of the frontmatter
    if (-not $replaced) {
        if ($lines.Count -eq 0 -or $lines[0].Trim() -ne '---') {
            Write-Host ("  {0,-28} error: no frontmatter opener '---' on line 1" -f (Split-Path $Path -Leaf)) -ForegroundColor Red
            return $false
        }
        $inserted = $false
        for ($i = 1; $i -lt $lines.Count; $i++) {
            if ($lines[$i].Trim() -eq '---') {
                $lines.Insert($i, $modelLine)
                $inserted = $true
                break
            }
        }
        if (-not $inserted) {
            Write-Host ("  {0,-28} error: no closing '---' found in frontmatter" -f (Split-Path $Path -Leaf)) -ForegroundColor Red
            return $false
        }
    }

    # write back with the SAME newline style (UTF-8, no BOM)
    $out = [string]::Join($nl, [string[]]$lines)
    if ($hadTrailingNl) { $out += $nl }
    [System.IO.File]::WriteAllText($Path, $out, $utf8NoBom)
    Write-Host ("  {0,-28} updated -> {1}" -f (Split-Path $Path -Leaf), $Value)
    return $true
}

$exitCode = 0
foreach ($af in $AgentFiles) {
    $full = Join-Path $AgentsDir $af
    if (-not (Edit-AgentFile -Path $full -Value $modelValue)) { $exitCode = 1 }
}

if ($exitCode -ne 0) {
    Write-Host "Completed with errors. See messages above." -ForegroundColor Red
    exit $exitCode
}

Write-Host "Done." -ForegroundColor Green
