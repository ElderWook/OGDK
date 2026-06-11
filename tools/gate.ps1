# THE GATE (OGDK kit itself) - kit-docs self-check + file integrity.
# (No reference manifest in the kit; tools/README.md is its reference.) Twin: gate.sh.
$ErrorActionPreference = 'Continue'
$dir = $PSScriptRoot
$total = 0
Write-Host '=== GATE: kit docs ===' -ForegroundColor Cyan
& "$dir\check-kit-docs.ps1"; $total += $LASTEXITCODE
Write-Host ''; Write-Host '=== GATE: file integrity ===' -ForegroundColor Cyan
& "$dir\verify-file-integrity.ps1"; $total += $LASTEXITCODE
Write-Host ''; Write-Host '======================================'
if ($total -eq 0) { Write-Host '  GATE PASSED - safe to commit' -ForegroundColor Green }
else { Write-Host "  GATE FAILED ($total) - do not commit" -ForegroundColor Red }
exit $total
