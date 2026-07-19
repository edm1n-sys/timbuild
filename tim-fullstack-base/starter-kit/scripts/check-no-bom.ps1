# check-no-bom.ps1
# Fail on UTF-8 BOM in source files. Wire into npm verify or CI.
# Usage: powershell -File scripts/check-no-bom.ps1 [-Path <dir>] [-Strict]
# Exit 0 = clean; exit 1 = BOM found
#
# For PowerShell 5.1 (Windows PowerShell): use -Encoding Byte for byte-level read.
# The UTF-8 BOM is bytes 239 187 191 (hex EF BB BF).

param(
    [string[]]$Path = @("src", "test", "app", "lib"),
    [switch]$Strict
)

$ErrorActionPreference = "Stop"
$failures = 0
$extensions = @("*.ts", "*.tsx", "*.scala", "*.sc", "*.mdc", "*.md", "*.json", "*.js")

Write-Host "=== BOM Check ===" -ForegroundColor Cyan

foreach ($dir in $Path) {
    if (-not (Test-Path -LiteralPath $dir -PathType Container)) {
        Write-Host "  SKIP: $dir not found" -ForegroundColor Yellow
        continue
    }

    $files = Get-ChildItem -LiteralPath $dir -Recurse -Include $extensions -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "node_modules|dist|\.git" }

    foreach ($file in $files) {
        $bytes = Get-Content -LiteralPath $file.FullName -Encoding Byte -TotalCount 3
        if ($bytes.Count -ge 3 -and $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191) {
            Write-Host "  FAIL: BOM found in $($file.FullName)" -ForegroundColor Red
            $failures++
        }
    }
}

if ($failures -gt 0) {
    Write-Host "`n=== $failures file(s) with UTF-8 BOM ===" -ForegroundColor Red
    Write-Host "Fix: [System.IO.File]::WriteAllText('path', [System.IO.File]::ReadAllText('path'), [System.Text.UTF8Encoding]::new(`$false))" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n=== No BOM found ===" -ForegroundColor Green
exit 0
