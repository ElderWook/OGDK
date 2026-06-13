# OGDK - run the hostile environment test suite. Windows PowerShell twin of test-hostile-env.sh.
# Ensures that verify-path-health, gate, and new-project work under adverse conditions.

$repoRoot = Split-Path -Parent $PSScriptRoot
$issues = 0

function Fail-Test($msg) {
    Write-Host "[FAIL] $msg" -ForegroundColor Red
    $script:issues = $script:issues + 1
}

function Pass-Test($msg) {
    Write-Host "[PASS] $msg" -ForegroundColor Green
}

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  Hostile Environment Smoke Test      " -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$testDir = Join-Path $repoRoot "sandbox hostile spaces dir"
if (Test-Path $testDir) {
    Remove-Item -Recurse -Force $testDir
}
$null = New-Item -ItemType Directory -Path $testDir

# Save current git environment and configuration variables if any
$oldGitGlobal = $env:GIT_CONFIG_GLOBAL
$oldGitNoSystem = $env:GIT_CONFIG_NOSYSTEM

$mockConfigPath = Join-Path $testDir "gitconfig"
$null = New-Item -ItemType File -Path $mockConfigPath
$env:GIT_CONFIG_GLOBAL = $mockConfigPath
$env:GIT_CONFIG_NOSYSTEM = "1"

# 1. Test clone & run health check with NO git config set
$ogdkDir = Join-Path $testDir "OGDK"
$null = git clone $repoRoot $ogdkDir 2>&1

Push-Location $ogdkDir
# Should FAIL because no identity is set
$null = .\tools\verify-path-health.ps1 2>&1
$exitCode = $LASTEXITCODE

if ($exitCode -eq 0) {
    Fail-Test "verify-path-health passed when git identity was not set"
} else {
    Pass-Test "verify-path-health correctly fails when git identity is missing"
}
Pop-Location

# 2. Test path-health and project creation with git config set
Push-Location $ogdkDir
$null = git config --global user.name "Test Friend"
$null = git config --global user.email "123+friend@users.noreply.github.com"

$null = .\tools\verify-path-health.ps1 2>&1
$exitCode2 = $LASTEXITCODE

if ($exitCode2 -eq 0) {
    Pass-Test "verify-path-health passes after setting identity"
} else {
    Fail-Test "verify-path-health failed after setting identity"
}

# Run gate check on kit
$null = .\tools\gate.ps1 2>&1
$gateExitCode = $LASTEXITCODE

if ($gateExitCode -eq 0) {
    Pass-Test "kit gate.ps1 passes inside sandbox with spaces"
} else {
    Fail-Test "kit gate.ps1 fails inside sandbox with spaces"
}

# Scaffold a new project
$projDir = Join-Path $testDir "TestProj"
$null = .\tools\new-project.ps1 -Name "TestProj" -Type "App" -Dest $testDir 2>&1
$scaffoldExitCode = $LASTEXITCODE

if ($scaffoldExitCode -eq 0) {
    Pass-Test "new-project.ps1 successfully scaffolds App in spaces-in-path directory"
} else {
    Fail-Test "new-project.ps1 fails scaffolding in spaces-in-path directory"
}

# Verify scaffolded gate passes
Push-Location $projDir
$null = .\tools\gate.ps1 2>&1
$projGateExitCode = $LASTEXITCODE

if ($projGateExitCode -eq 0) {
    Pass-Test "scaffolded project gate passes successfully"
} else {
    Fail-Test "scaffolded project gate fails to pass"
}
Pop-Location # projDir
Pop-Location # ogdkDir

# 3. Identity-leak guard: check-git-identity must FAIL on a leaked author identity
#    in history and PASS when no marker matches. (Requires the new files to be
#    committed first - the sandbox is a fresh clone, which only carries tracked files.)
Push-Location $ogdkDir
if (Test-Path ".\tools\check-git-identity.ps1") {
    Set-Content -Path "tools\PRIVATE-MARKERS.list" -Value "leaktoken9000"
    $null = git -c user.name=Leaker -c user.email=leaktoken9000@example.com commit --allow-empty -m "test: simulated identity leak" 2>&1
    $null = .\tools\check-git-identity.ps1 2>&1
    if ($LASTEXITCODE -ne 0) {
        Pass-Test "check-git-identity correctly fails on a leaked author identity"
    } else {
        Fail-Test "check-git-identity passed despite a leaked author identity in history"
    }
    Set-Content -Path "tools\PRIVATE-MARKERS.list" -Value "zzz_absent_marker_xyz"
    $null = .\tools\check-git-identity.ps1 2>&1
    if ($LASTEXITCODE -eq 0) {
        Pass-Test "check-git-identity passes when no marker appears in history"
    } else {
        Fail-Test "check-git-identity failed on clean history"
    }
    Remove-Item "tools\PRIVATE-MARKERS.list" -ErrorAction SilentlyContinue
} else {
    Fail-Test "check-git-identity.ps1 absent from clone - commit the new guard before smoke-testing"
}
Pop-Location # ogdkDir (identity test)

# Restore git environment variables
$env:GIT_CONFIG_GLOBAL = $oldGitGlobal
$env:GIT_CONFIG_NOSYSTEM = $oldGitNoSystem

# Clean up
if (Test-Path $testDir) {
    Remove-Item -Recurse -Force $testDir
}

Write-Host "--------------------------------------" -ForegroundColor Cyan
if ($script:issues -eq 0) {
    Write-Host "  HOSTILE ENVIRONMENT TESTS PASSED" -ForegroundColor Green
    exit 0
} else {
    Write-Host "  $script:issues ISSUE(S) DETECTED" -ForegroundColor Red
    exit 1
}

# EOF
