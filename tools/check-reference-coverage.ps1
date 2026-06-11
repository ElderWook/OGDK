# Reference coverage check (OGDK) - makes the documentation graduation rule mechanical.
# Reads docs/reference/COVERAGE.md and verifies pages exist + staleness vs git history.
# Twin: check-reference-coverage.sh (keep behavior identical).
$ErrorActionPreference = 'Continue'
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot
$manifest = 'docs/reference/COVERAGE.md'
$issues = 0; $backlog = 0; $stale = 0

Write-Host '======================================' -ForegroundColor Cyan
Write-Host '  Reference Coverage Check (OGDK)     ' -ForegroundColor Cyan
Write-Host '======================================' -ForegroundColor Cyan

if (-not (Test-Path $manifest)) {
    Write-Host "[FAIL] no $manifest - reference tier not initialized" -ForegroundColor Red
    exit 1
}
git rev-parse --git-dir 2>&1 | Out-Null
$haveGit = ($LASTEXITCODE -eq 0)
if (-not $haveGit) { Write-Host '[WARN] not a git repo - staleness checks skipped' -ForegroundColor Yellow }

function Get-LastCommitTime([string]$p) {
    $t = git log -1 --format=%ct -- $p 2>$null
    if ($t) { return [long]$t } else { return 0 }
}

foreach ($line in (Get-Content $manifest -Encoding UTF8)) {
    if ($line -notmatch '^\|') { continue }
    $cells = $line.Trim('|').Split('|') | ForEach-Object { $_.Trim() }
    if ($cells.Count -lt 4) { continue }
    $comp = $cells[0]; $src = $cells[1]; $page = $cells[2]; $status = $cells[3].ToLower()
    if ($comp -eq '' -or $comp -eq 'Component' -or $comp -like '_none*' -or $comp -like ':---*' -or $comp -like '---*') { continue }
    if ($status -eq 'planned') { continue }
    if ($status -eq 'missing') {
        $backlog++
        Write-Host "[WARN] MISSING page: $comp (source: $src)" -ForegroundColor Yellow
        continue
    }
    if ($status -ne 'current' -and $status -ne 'stale') {
        Write-Host "[FAIL] ${comp}: unknown status '$status' in COVERAGE.md" -ForegroundColor Red
        $issues++; continue
    }
    $pageFile = "docs/reference/$page"
    if (-not (Test-Path $pageFile)) {
        Write-Host "[FAIL] ${comp}: page $page listed as $status but file does not exist" -ForegroundColor Red
        $issues++; continue
    }
    if ($haveGit) {
        $pageTs = Get-LastCommitTime $pageFile
        $srcTs = 0
        foreach ($sp in $src.Split(';')) {
            $sp = $sp.Trim(); if ($sp -eq '') { continue }
            $t = Get-LastCommitTime $sp
            if ($t -gt $srcTs) { $srcTs = $t }
        }
        if ($srcTs -gt $pageTs -and $pageTs -ne 0) {
            $stale++
            Write-Host "[WARN] STALE: $comp - source committed after page $page (update page or justify)" -ForegroundColor Yellow
        } else {
            Write-Host "[PASS] $comp -> $page" -ForegroundColor Green
        }
    } else {
        Write-Host "[PASS] $comp -> $page (existence only)" -ForegroundColor Green
    }
}

Write-Host '--------------------------------------' -ForegroundColor Cyan
Write-Host "  backlog (missing pages): $backlog   stale: $stale   hard issues: $issues"
if ($issues -eq 0) {
    Write-Host '  COVERAGE OK' -ForegroundColor Green
} else {
    Write-Host '  FIX COVERAGE before archiving any plan' -ForegroundColor Red
}
exit $issues
