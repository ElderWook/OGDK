# OGDK - one-command setup for a fresh clone. A friendly orchestrator: it runs the
# safety checks in the right order and tells a newcomer exactly what to do next, so
# the first five minutes are one command instead of six stages of copy-paste.
# Read-only: it never commits and never sets your git identity for you. Twin: bootstrap.sh.
#
# Usage (from inside the cloned kit):  .\tools\bootstrap.ps1
$ErrorActionPreference = 'Continue'
$dir = $PSScriptRoot
$root = Split-Path -Parent $dir
Set-Location $root

Write-Host '   ___   ____ ____  _  __' -ForegroundColor Cyan
Write-Host '  / _ \ / ___|  _ \| |/ /' -ForegroundColor Cyan
Write-Host ' | | | | |  _| | | | '' /' -ForegroundColor Cyan
Write-Host ' | |_| | |_| | |_| | . \' -ForegroundColor Cyan
Write-Host '  \___/ \____|____/|_|\_\' -ForegroundColor Cyan
$env:OGDK_BANNER = '1'
Write-Host '  Bootstrap - first-run setup (OGDK)' -ForegroundColor Cyan
Write-Host '======================================' -ForegroundColor Cyan

Write-Host ''
Write-Host 'Step 1/4: checking git...' -ForegroundColor Cyan
$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) {
    Write-Host '[ACTION] git is not installed yet. Install it, then run this again:' -ForegroundColor Yellow
    Write-Host '         winget install --id Git.Git -e'
    Write-Host '         (close and reopen PowerShell afterward, then re-run bootstrap)'
    exit 1
}
Write-Host "[OK] git present ($(git --version))" -ForegroundColor Green
$email = git config user.email
if (-not $email) {
    Write-Host '[ACTION] git does not know who you are yet. Set it once (use YOUR details):' -ForegroundColor Yellow
    Write-Host '         git config --global user.name "Your Name"'
    Write-Host '         git config --global user.email "you@example.com"'
    Write-Host '         Tip: a GitHub noreply email keeps your address private.'
    Write-Host '         Then run this script again.'
    exit 1
}
Write-Host "[OK] git identity: $email" -ForegroundColor Green

Write-Host ''
Write-Host 'Step 2/4: environment health...' -ForegroundColor Cyan
& (Join-Path $dir 'verify-path-health.ps1')
if ($LASTEXITCODE -ne 0) {
    Write-Host '[STOP] fix the health issues above, then run bootstrap again.' -ForegroundColor Red
    exit 1
}

Write-Host ''
Write-Host 'Step 3/4: the gate (proves the kit works on YOUR machine)...' -ForegroundColor Cyan
& (Join-Path $dir 'gate.ps1')
if ($LASTEXITCODE -ne 0) {
    Write-Host '[STOP] the gate did not pass. Copy everything above and report it - that is a real finding.' -ForegroundColor Red
    exit 1
}

Write-Host ''
Write-Host 'Step 4/4: arming the optional privacy git hooks...' -ForegroundColor Cyan
& (Join-Path $dir 'install-hooks.ps1') | Out-Null
Write-Host '[OK] done.' -ForegroundColor Green

Write-Host ''
Write-Host '======================================' -ForegroundColor Cyan
Write-Host '  YOU ARE READY.' -ForegroundColor Green
Write-Host '  Build something:   .\tools\new-project.ps1 -Name MyIdea -Type App'
Write-Host '  Then open the new folder with your AI agent and say:  run session-start'
Write-Host '  New to all this?   read START-BUILDING.md'
Write-Host '======================================' -ForegroundColor Cyan
exit 0
