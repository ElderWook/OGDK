# THE GATE - one command answers "did I break it?". Copied into each project by
# new-project; fill in the project section. Twin: gate.template.sh.
# Exit 0 = safe to commit. Anything else = fix first.
$ErrorActionPreference = 'Continue'
$dir = $PSScriptRoot
$total = 0
function Step([string]$name) { Write-Host ''; Write-Host "=== GATE: $name ===" -ForegroundColor Cyan }

Step 'file integrity'
& "$dir\verify-file-integrity.ps1"; $total += $LASTEXITCODE

Step 'reference coverage'
& "$dir\check-reference-coverage.ps1"; $total += $LASTEXITCODE

Step 'project checks'
# FILL IN: this project's tests + builds, each followed by:  $total += $LASTEXITCODE
# App example:   npm test; $total += $LASTEXITCODE
# Python example: python -m unittest discover tests; $total += $LASTEXITCODE
Write-Host '(none defined yet - fill in tools\gate.ps1)'

Write-Host ''
Write-Host '======================================'
if ($total -eq 0) { Write-Host '  GATE PASSED - safe to commit' -ForegroundColor Green }
else { Write-Host "  GATE FAILED ($total) - do not commit" -ForegroundColor Red }
exit $total
