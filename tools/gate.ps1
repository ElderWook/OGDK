# THE GATE (OGDK kit itself) - kit-docs self-check + file integrity.
# (No reference manifest in the kit; tools/README.md is its reference.) Twin: gate.sh.
$ErrorActionPreference = 'Continue'
$dir = $PSScriptRoot
$total = 0
if (-not $env:OGDK_BANNER) {
    Write-Host '   ___   ____ ____  _  __' -ForegroundColor Cyan
    Write-Host '  / _ \ / ___|  _ \| |/ /' -ForegroundColor Cyan
    Write-Host ' | | | | |  _| | | | '' /' -ForegroundColor Cyan
    Write-Host ' | |_| | |_| | |_| | . \' -ForegroundColor Cyan
    Write-Host '  \___/ \____|____/|_|\_\' -ForegroundColor Cyan
}
$env:OGDK_BANNER = '1'
Write-Host '=== GATE: kit docs ===' -ForegroundColor Cyan
& "$dir\check-kit-docs.ps1"; $total += $LASTEXITCODE
Write-Host ''; Write-Host '=== GATE: file integrity ===' -ForegroundColor Cyan
& "$dir\verify-file-integrity.ps1"; $total += $LASTEXITCODE
Write-Host ''; Write-Host '=== GATE: git identity ===' -ForegroundColor Cyan
& "$dir\check-git-identity.ps1"; $total += $LASTEXITCODE
Write-Host ''; Write-Host '======================================'
if ($total -eq 0) { Write-Host '  GATE PASSED - safe to commit' -ForegroundColor Green }
else { Write-Host "  GATE FAILED ($total) - do not commit" -ForegroundColor Red }
Remove-Item Env:\OGDK_BANNER -ErrorAction SilentlyContinue
exit $total
