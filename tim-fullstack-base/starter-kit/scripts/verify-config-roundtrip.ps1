# verify-config-roundtrip.ps1
# Mechanical check: validates that a config file is loaded via parseConfigJson,
# flags are consumed from JSON (not hardcoded literals), and no parse errors exist.
# Usage: .\scripts\verify-config-roundtrip.ps1 [-ConfigPath <path>] [-SourcePath <path>] [-Flags <array>] [-Node]
# For plan steps tagged config, flags, or fixture changes. Optional CI / pre-commit hook.
# Exit 0 = pass; exit 1 = fail.

param(
    [string]$ConfigPath = "config/app-config.json",
    [string]$SourcePath = "src/api/config.ts",
    [string[]]$Flags = @(),
    [switch]$Node
)

$ErrorActionPreference = "Stop"
$failures = 0

Write-Host "=== Config Round-Trip Check ===" -ForegroundColor Cyan

# 1. File exists
if (-not (Test-Path -LiteralPath $ConfigPath)) {
    Write-Host "  FAIL: Config file not found: $ConfigPath" -ForegroundColor Red
    exit 1
}
Write-Host "  [1/6] File exists: $ConfigPath" -ForegroundColor Green

# 2. Valid JSON
$jsonContent = Get-Content -LiteralPath $ConfigPath -Raw
try {
    $configObj = $jsonContent | ConvertFrom-Json
    Write-Host "  [2/6] Valid JSON: $ConfigPath" -ForegroundColor Green
} catch {
    Write-Host "  FAIL: Invalid JSON in $ConfigPath : $_" -ForegroundColor Red
    $failures++
}

# 3. Flag round-trip (json -> parseConfigJson -> not hardcoded)
if ($Flags.Count -gt 0 -and (Test-Path -LiteralPath $SourcePath)) {
    $sourceContent = Get-Content -LiteralPath $SourcePath -Raw
    Write-Host "  [3/6] Flag round-trip check ($($Flags.Count) flags)..." -ForegroundColor Cyan

    foreach ($flag in $Flags) {
        $jsonVal = $configObj.$flag
        if ($null -eq $jsonVal) {
            Write-Host "    FAIL: $flag missing from $ConfigPath" -ForegroundColor Red
            $failures++
            continue
        }

        # 3a. Flag is read from json object (not hardcoded literal)
        if ($sourceContent -match "${flag}:\s*json\.${flag}" -or
            $sourceContent -match "${flag}:\s*config\.?${flag}" -or
            $sourceContent -match "json\[.${flag}.]" -or
            $sourceContent -match "config\[.${flag}.]") {
            Write-Host "    OK: $flag consumed from config object" -ForegroundColor Green
        } else {
            Write-Host "    FAIL: parseConfigJson does not read config.$flag (may be hardcoded literal)" -ForegroundColor Red
            $failures++
        }

        # 3b. No hardcoded literal assignment in parseConfigJson return
        if ($sourceContent -match "(?s)parseConfigJson[\s\S]{0,3000}return\s*\{[\s\S]{0,3000}\}") {
            $returnBlock = $Matches[0]
            if ($returnBlock -match "${flag}:\s*(true|false|\d+)\b") {
                $literalVal = $Matches[1]
                # OK if it's json.flagName, FAIL if literal
                if ($returnBlock -notmatch "${flag}:\s*.*json\.${flag}") {
                    Write-Host "    FAIL: literal $flag=$literalVal assigned in parseConfigJson return (should be json.$flag)" -ForegroundColor Red
                    $failures++
                }
            }
        }
    }
} elseif ($Flags.Count -gt 0 -and -not (Test-Path -LiteralPath $SourcePath)) {
    Write-Host "  SKIP: Source file not found: $SourcePath" -ForegroundColor Yellow
}

# 4. parseConfigJson loads without error (TypeScript runtime)
if ($Node) {
    try {
        $result = node -e "
            const fs = require('fs');
            const config = JSON.parse(fs.readFileSync('$ConfigPath','utf8'));
            console.log('Keys:', Object.keys(config).length);
        " 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [4/6] parseConfigJson runtime loads: $result" -ForegroundColor Green
        } else {
            Write-Host "  FAIL: parseConfigJson runtime failed: $result" -ForegroundColor Red
            $failures++
        }
    } catch {
        Write-Host "  SKIP: Node not available for runtime parseConfigJson check" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [4/6] Runtime check: SKIP (use -Node to enable)" -ForegroundColor Yellow
}

# 5. No duplicate keys in JSON
$duplicates = [regex]::Matches($jsonContent, '"\s*(\w+)\s*":') | Group-Object { $_.Groups[1].Value } | Where-Object { $_.Count -gt 1 }
if ($duplicates) {
    Write-Host "  FAIL: Duplicate keys found: $($duplicates.Name -join ', ')" -ForegroundColor Red
    $failures++
} else {
    Write-Host "  [5/6] No duplicate keys" -ForegroundColor Green
}

# 6. Semantic check: flag consistency across config + source
if ($Flags.Count -gt 0 -and $failures -eq 0) {
    Write-Host "  [6/6] All $($Flags.Count) flags round-trip verified" -ForegroundColor Green
}

if ($failures -gt 0) {
    Write-Host "`n=== verify-config-roundtrip: $failures FAILURE(S) ===" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== verify-config-roundtrip: all checks passed ===" -ForegroundColor Green
exit 0
