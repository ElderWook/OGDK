# Install the OGDK git hooks for THIS clone by pointing core.hooksPath at the
# tracked tools/hooks directory. The pre-push hook then runs check-git-identity
# before every push. Per-clone and idempotent (core.hooksPath is local config, not
# committed). Undo any time: git config --unset core.hooksPath. Twin: install-hooks.sh.
$ErrorActionPreference = 'Continue'
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

Write-Host '======================================' -ForegroundColor Cyan
Write-Host '  Install Git Hooks (OGDK)            ' -ForegroundColor Cyan
Write-Host '======================================' -ForegroundColor Cyan

$null = git rev-parse --git-dir 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host '[FAIL] not a git repository - run from inside the repo' -ForegroundColor Red
    exit 1
}
if (-not (Test-Path 'tools/hooks/pre-push')) {
    Write-Host '[FAIL] tools/hooks/pre-push not found - nothing to install' -ForegroundColor Red
    exit 1
}
git config core.hooksPath tools/hooks
$code = $LASTEXITCODE
if ($code -eq 0) {
    Write-Host '[PASS] core.hooksPath -> tools/hooks (pre-push identity guard active)' -ForegroundColor Green
    Write-Host '       Test it: git push   (the guard runs first). Undo: git config --unset core.hooksPath' -ForegroundColor Gray
} else {
    Write-Host '[FAIL] could not set core.hooksPath' -ForegroundColor Red
}
exit $code
