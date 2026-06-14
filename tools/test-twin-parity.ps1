# OGDK - twin behavioral-parity harness. The twin rule (check-kit-docs) only
# verifies that a .ps1/.sh PAIR EXISTS; it cannot see when the two halves DRIFT
# apart in behavior (the 2026-06-13 audit found 5 such silent drifts). This
# harness closes that gap in two phases:
#
#   Phase 1 (broad, every twin) - each tools/*.ps1 parses under the PowerShell
#       language parser AND each tools/*.sh parses under 'bash -n'. Generalises
#       the audit's "parse every .ps1 under pwsh" pass to BOTH languages, so a
#       truncated or syntactically-drifted twin is caught for ALL tools cheaply.
#
#   Phase 2 (deep, curated) - safety-critical tools are run through IDENTICAL
#       fixtures in BOTH shells and their EXIT CODES must agree. Exit code is the
#       OS-invariant behavioral contract (0 = clean, nonzero = issues); output
#       TEXT may legitimately differ per OS (documented twin differences), so we
#       assert on exit-code parity and DUMP both outputs on a mismatch.
#
# Needs PowerShell always. The .sh side needs bash - those checks are SKIPPED,
# not failed, when it is absent, because parity can only be judged where both
# shells exist (the operator's working clone has both). Adding a tool to Phase 2
# = add one scenario scriptblock and one Invoke-Scenario line.
# Twin: test-twin-parity.sh (keep behavior identical - see tools/README.md).
#
# Usage: .\tools\test-twin-parity.ps1
$ErrorActionPreference = 'Continue'
$kit = Split-Path -Parent $PSScriptRoot
$script:issues = 0
$script:skips = 0
function Pass($m)   { Write-Host "[PASS] $m" -ForegroundColor Green }
function Failed($m) { Write-Host "[FAIL] $m" -ForegroundColor Red; $script:issues++ }
function Skip($m)   { Write-Host "[SKIP] $m" -ForegroundColor Yellow; $script:skips++ }
function Info($m)   { Write-Host "[INFO] $m" -ForegroundColor Cyan }

if (-not $env:OGDK_BANNER) {
    Write-Host '   ___   ____ ____  _  __' -ForegroundColor Cyan
    Write-Host '  / _ \ / ___|  _ \| |/ /' -ForegroundColor Cyan
    Write-Host ' | | | | |  _| | | | '' /' -ForegroundColor Cyan
    Write-Host ' | |_| | |_| | |_| | . \' -ForegroundColor Cyan
    Write-Host '  \___/ \____|____/|_|\_\' -ForegroundColor Cyan
}
$env:OGDK_BANNER = '1'
Write-Host '======================================' -ForegroundColor Cyan
Write-Host '  Twin Parity Harness (OGDK)          ' -ForegroundColor Cyan
Write-Host '======================================' -ForegroundColor Cyan

# Launchers. We are already in PowerShell, so a PS launcher always exists; bash
# may be absent (e.g. a bare Windows box) - the .sh-side checks skip if so.
$psExe = (Get-Command pwsh -ErrorAction SilentlyContinue).Source
if (-not $psExe) { $psExe = (Get-Command powershell -ErrorAction SilentlyContinue).Source }
$bash = (Get-Command bash -ErrorAction SilentlyContinue).Source

# ---- Phase 1: parse parity (all twins) -------------------------------------
Write-Host ''
Write-Host '--- Phase 1: parse parity (all twins) ---'
$psBad = @()
foreach ($f in (Get-ChildItem (Join-Path $kit 'tools') -Filter *.ps1 -File)) {
    $tokens = $null; $errs = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($f.FullName, [ref]$tokens, [ref]$errs)
    if ($errs -and $errs.Count -gt 0) { $psBad += $f.Name }
}
if ($psBad.Count -gt 0) { Failed ('tools/*.ps1 failed PowerShell parse: ' + ($psBad -join ' ')) }
else { Pass 'all tools/*.ps1 parse (PowerShell parser)' }

if ($bash) {
    $shBad = @()
    foreach ($f in (Get-ChildItem (Join-Path $kit 'tools') -Filter *.sh -File)) {
        & $bash -n $f.FullName 2>$null
        if ($LASTEXITCODE -ne 0) { $shBad += $f.Name }
    }
    if ($shBad.Count -gt 0) { Failed ('tools/*.sh failed bash -n: ' + ($shBad -join ' ')) }
    else { Pass "all tools/*.sh parse (bash -n via $bash)" }
} else {
    Skip 'no bash found - .sh parse + all behavioral parity checks skipped (they run on the operator''s clone, which has both shells)'
}

# ---- Phase 2: behavioral parity (curated, exit-code contract) --------------
Write-Host ''
Write-Host '--- Phase 2: behavioral parity (exit-code contract) ---'

# Fixture builder: a fresh git repo with an isolated noreply identity and the
# tool's BOTH twins copied into tools/ (each tool roots itself at dirname/.. , so
# it must be run from inside the fixture, exactly as test-sync-repo does).
function New-Fixture($tool) {
    $d = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Path $d | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $d 'tools') | Out-Null
    & git -C $d init -q | Out-Null
    & git -C $d config user.email 'parity@users.noreply.github.com' | Out-Null
    & git -C $d config user.name 'Parity Tester' | Out-Null
    & git -C $d config commit.gpgsign false | Out-Null
    Copy-Item (Join-Path $kit "tools/$tool.sh")  (Join-Path $d 'tools') | Out-Null
    Copy-Item (Join-Path $kit "tools/$tool.ps1") (Join-Path $d 'tools') | Out-Null
    return $d
}

# Scenario setups - each scriptblock receives the fixture dir as $d.
$scnVfiClean = {
    param($d)
    Set-Content -Path (Join-Path $d 'readme.md') -Value 'all good'
    & git -C $d add -A | Out-Null
    & git -C $d commit -qm seed | Out-Null
}
$scnVfiNul = {
    param($d)
    [System.IO.File]::WriteAllBytes((Join-Path $d 'bad.txt'), [byte[]](0x67,0x6f,0x6f,0x64,0x00,0x62,0x61,0x64,0x0a))
    & git -C $d add -A | Out-Null
    & git -C $d commit -qm seed | Out-Null
}
$scnVfiNoEof = {
    param($d)
    Set-Content -Path (Join-Path $d 'tools/extra.sh')  -Value @('#!/usr/bin/env bash','echo hi','# trailing comment, not a sentinel')
    Set-Content -Path (Join-Path $d 'tools/extra.ps1') -Value @('# ps stub','Write-Host hi','# trailing comment, not a sentinel')
    & git -C $d add -A | Out-Null
    & git -C $d commit -qm seed | Out-Null
}
$scnIdnClean = {
    param($d)
    Set-Content -Path (Join-Path $d 'tools/PRIVATE-MARKERS.list') -Value 'NOMATCHMARKER'
    Set-Content -Path (Join-Path $d 'f.md') -Value 'x'
    & git -C $d add f.md | Out-Null
    & git -C $d commit -qm seed | Out-Null
}
$scnIdnLeak = {
    param($d)
    Set-Content -Path (Join-Path $d 'tools/PRIVATE-MARKERS.list') -Value 'leakmark'
    Set-Content -Path (Join-Path $d 'f.md') -Value 'x'
    & git -C $d add f.md | Out-Null
    & git -C $d -c user.email='leakmark@example.com' -c user.name='Leak' commit -qm seed | Out-Null
}

function Invoke-Scenario($tool, $label, $setup) {
    if (-not $bash) { Skip "$label (needs bash)"; return }
    $fx = New-Fixture $tool
    & $setup $fx | Out-Null
    Push-Location $fx
    $outSh  = & $bash "tools/$tool.sh" 2>&1
    $codeSh = $LASTEXITCODE
    $outPs  = & $psExe -NoProfile -File "tools/$tool.ps1" 2>&1
    $codePs = $LASTEXITCODE
    Pop-Location
    if ($codeSh -eq $codePs) {
        Pass "$label [exit parity: both $codeSh]"
    } else {
        Failed "$label [DRIFT: .sh exit $codeSh vs .ps1 exit $codePs]"
        Write-Host '------ .sh output ------'
        $outSh | ForEach-Object { Write-Host "    $_" }
        Write-Host '------ .ps1 output -----'
        $outPs | ForEach-Object { Write-Host "    $_" }
    }
    Remove-Item -Recurse -Force $fx -ErrorAction SilentlyContinue
}

# Curated scenarios (mirror test-twin-parity.sh): tool, label, setup.
Invoke-Scenario 'verify-file-integrity' 'verify-file-integrity: clean repo'          $scnVfiClean
Invoke-Scenario 'verify-file-integrity' 'verify-file-integrity: NUL-byte corruption'  $scnVfiNul
Invoke-Scenario 'verify-file-integrity' 'verify-file-integrity: missing EOF sentinel' $scnVfiNoEof
Invoke-Scenario 'check-git-identity'    'check-git-identity: clean identity'          $scnIdnClean
Invoke-Scenario 'check-git-identity'    'check-git-identity: leaked identity'         $scnIdnLeak

Write-Host ''
Write-Host '--------------------------------------' -ForegroundColor Cyan
if ($script:issues -eq 0) { Write-Host "  TWIN PARITY OK ($script:skips skipped)" -ForegroundColor Green }
else { Write-Host "  $script:issues PARITY ISSUE(S) - twins have drifted" -ForegroundColor Red }
Write-Host '--------------------------------------' -ForegroundColor Cyan
exit $script:issues
