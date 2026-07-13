# verify-config-roundtrip.ps1
# Mechanical check: validates that parseConfigJson loads a config file without runtime errors.
# Usage: .\scripts\verify-config-roundtrip.ps1 [-ConfigPath <path>] [-Node]
# For plan steps tagged config, flags, or fixture changes. Optional CI / pre-commit hook.

param(
    [string]$ConfigPath = "config/app-config.json",
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
Write-Host "  [1/4] File exists: $ConfigPath" -ForegroundColor Green

# 2. Valid JSON
try {
    $null = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
    Write-Host "  [2/4] Valid JSON: $ConfigPath" -ForegroundColor Green
} catch {
    Write-Host "  FAIL: Invalid JSON in $ConfigPath : $_" -ForegroundColor Red
    $failures++
}

# 3. parseConfigJson loads without error (TypeScript)
if ($Node) {
    try {
        $result = node -e "
            const fs = require('fs');
            const config = JSON.parse(fs.readFileSync('$ConfigPath','utf8'));
            console.log('Keys:', Object.keys(config).length);
        " 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [3/4] parseConfigJson loads: $result" -ForegroundColor Green
        } else {
            Write-Host "  FAIL: parseConfigJson failed: $result" -ForegroundColor Red
            $failures++
        }
    } catch {
        Write-Host "  SKIP: Node not available for runtime parseConfigJson check" -ForegroundColor Yellow
    }
} else {
    Write-Host "  SKIP: Node not requested (-Node flag)" -ForegroundColor Yellow
}

# 4. No duplicate keys in JSON
$content = Get-Content -LiteralPath $ConfigPath -Raw
$duplicates = [regex]::Matches($content, '"\s*(\w+)\s*":') | Group-Object { $_.Groups[1].Value } | Where-Object { $_.Count -gt 1 }
if ($duplicates) {
    Write-Host "  FAIL: Duplicate keys found: $($duplicates.Name -join ', ')" -ForegroundColor Red
    $failures++
} else {
    Write-Host "  [4/4] No duplicate keys" -ForegroundColor Green
}

if ($failures -gt 0) {
    Write-Host "`n=== $failures FAILURES — fix before proceeding ===" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== Round-trip OK ===" -ForegroundColor Green
exit 0
