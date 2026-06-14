# tools/safe-agent-push.ps1
# Automated, gate-verified git commit & push wrapper for AI agents.
$ErrorActionPreference = 'Stop'
$dir = $PSScriptRoot

# 1. Run Path Health Check
Write-Host "=== Step 1: Checking Path Health ===" -ForegroundColor Cyan
& "$dir\verify-path-health.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Path health check failed. Aborting commit/push."
}

# 2. Check Remote Sync Status
Write-Host "=== Step 2: Checking Repository Sync ===" -ForegroundColor Cyan
& "$dir\sync-repo.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Repository sync check failed or diverged. Aborting commit/push."
}

# 3. Run Gate Checks
Write-Host "=== Step 3: Running Project Gates ===" -ForegroundColor Cyan
& "$dir\gate.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Project gate checks failed. Aborting commit/push."
}

# Get commit message from argument
$msg = $args[0]
if (-not $msg) {
    $msg = "Auto-commit from agent: green gate verified"
}

# 4. Execute Git Commit & Push
Write-Host "=== Step 4: Committing & Pushing ===" -ForegroundColor Cyan
git add .
git commit -m $msg
git push origin main
Write-Host "=== PUSH SUCCESSFUL ===" -ForegroundColor Green
# EOF
