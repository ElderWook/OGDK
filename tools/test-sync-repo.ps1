# OGDK - sync-repo classifier smoke test. Drives the safe-arrival tool through each
# state against a throwaway local bare remote and asserts the documented exit code
# (0 = safe to work, 2 = action required). Windows twin of test-sync-repo.sh.
$kit = Split-Path -Parent $PSScriptRoot
$issues = 0
function Fail-Test($m) { Write-Host "[FAIL] $m" -ForegroundColor Red; $script:issues = $script:issues + 1 }
function Pass-Test($m) { Write-Host "[PASS] $m" -ForegroundColor Green }

Write-Host '======================================' -ForegroundColor Cyan
Write-Host '  sync-repo Classifier Smoke Test     ' -ForegroundColor Cyan
Write-Host '======================================' -ForegroundColor Cyan

$testDir = Join-Path $kit 'sandbox sync test'
if (Test-Path $testDir) { Remove-Item -Recurse -Force $testDir }
$null = New-Item -ItemType Directory -Path $testDir

# Isolate from the operator's real git config/identity.
$oldGlobal = $env:GIT_CONFIG_GLOBAL
$oldNoSystem = $env:GIT_CONFIG_NOSYSTEM
$env:GIT_CONFIG_GLOBAL = Join-Path $testDir 'gitconfig'
$env:GIT_CONFIG_NOSYSTEM = '1'
$null = New-Item -ItemType File -Path $env:GIT_CONFIG_GLOBAL
git config --global user.email "synctester@users.noreply.github.com"
git config --global user.name "Sync Tester"
git config --global init.defaultBranch main
git config --global commit.gpgsign false

$remote = Join-Path $testDir 'remote.git'
git init -q --bare $remote

function Setup-Clone($dir) {
    git clone -q $remote $dir
    $null = New-Item -ItemType Directory -Force -Path (Join-Path $dir 'tools')
    Copy-Item (Join-Path $kit 'tools\sync-repo.ps1') (Join-Path $dir 'tools\')
    Copy-Item (Join-Path $kit 'tools\sync-repo.sh') (Join-Path $dir 'tools\')
}

function Assert-Sync($dir, $expected, $label, $keyword) {
    Push-Location $dir
    # sync-repo prints via Write-Host (PowerShell information stream, 6) - capture ALL
    # streams with *>&1 or the banner/check lines are invisible here and keyword checks
    # miss. (The .sh twin uses echo -> stdout, so its 2>&1 capture is already complete -
    # a documented platform difference, not a behavior divergence.)
    $out = (& '.\tools\sync-repo.ps1' *>&1 | Out-String)
    $code = $LASTEXITCODE
    Pop-Location
    if ($code -ne $expected) {
        Fail-Test "$label (expected exit $expected, got $code)"
        return
    }
    if ($keyword -and ($out -notmatch [regex]::Escape($keyword))) {
        Fail-Test "$label (exit $expected ok, but output missing '$keyword')"
        return
    }
    Pass-Test $label
}

# A: primary working clone; seed and push so it has an upstream.
$A = Join-Path $testDir 'A'
Setup-Clone $A
Push-Location $A
Set-Content -Path 'file.txt' -Value 'seed'
git add -A
git commit -q -m "seed"
git push -q -u origin HEAD
Pop-Location

# 1. IN-SYNC -> exit 0
Assert-Sync $A 0 "in-sync -> exit 0 (safe to work)" "no new remote commits"

# 2. BEHIND -> auto fast-forward -> exit 0.
$B = Join-Path $testDir 'B'
Setup-Clone $B
Push-Location $B
Add-Content -Path 'file.txt' -Value 'from B'
git commit -q -am "b-commit"
git push -q origin HEAD
Pop-Location
Assert-Sync $A 0 "behind -> auto fast-forward (safe)" "fast-forwarded"

# 3. AHEAD -> exit 0 (local commit not pushed yet)
Push-Location $A
Add-Content -Path 'file.txt' -Value 'local only'
git commit -q -am "a-local"
Pop-Location
Assert-Sync $A 0 "ahead -> exit 0 (push when ready)" "not pushed"

# 4. DIVERGED -> exit 2.
Push-Location $B
git pull -q --ff-only
Add-Content -Path 'file.txt' -Value 'b diverge'
git commit -q -am "b-diverge"
git push -q origin HEAD
Pop-Location
Assert-Sync $A 2 "diverged -> exit 2 (STOP)" "DIVERGED"

# 5. DIRTY + BEHIND -> exit 2.
$C = Join-Path $testDir 'C'
Setup-Clone $C
Push-Location $B
git pull -q --ff-only
Add-Content -Path 'file.txt' -Value 'newer'
git commit -q -am "b-newer"
git push -q origin HEAD
Pop-Location
Push-Location $C
Add-Content -Path 'file.txt' -Value 'uncommitted edit'
Pop-Location
Assert-Sync $C 2 "dirty + behind -> exit 2 (STOP)" "uncommitted"

# 6. MERGE in progress -> exit 2 (detected before fetch).
$D = Join-Path $testDir 'D'
Setup-Clone $D
Push-Location $D
$gd = (git rev-parse --git-dir)
$null = New-Item -ItemType File -Force -Path (Join-Path $gd 'MERGE_HEAD')
Pop-Location
Assert-Sync $D 2 "merge in progress -> exit 2 (STOP)" "MERGE is in progress"

# Restore environment + clean up.
$env:GIT_CONFIG_GLOBAL = $oldGlobal
$env:GIT_CONFIG_NOSYSTEM = $oldNoSystem
if (Test-Path $testDir) { Remove-Item -Recurse -Force $testDir }

Write-Host '--------------------------------------' -ForegroundColor Cyan
if ($issues -eq 0) {
    Write-Host '  SYNC-REPO CLASSIFIER TESTS PASSED' -ForegroundColor Green
    exit 0
} else {
    Write-Host "  $issues ISSUE(S) DETECTED" -ForegroundColor Red
    exit 1
}
# EOF
