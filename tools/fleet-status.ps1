# OGDK - fleet status. READ-ONLY multi-repo health sweep: for the kit and every repo in
# tools/TARGETS.list, fetch and report branch / ahead / behind / dirty / stash / state /
# KIT-VERSION in one table. This is the C0 multi-repo ARRIVE check of the git lifecycle
# (docs/workflow/GIT-LIFECYCLE.md) - run it before a propagation session so you never
# propagate onto a stale or tangled base. A leading '*' marks any repo that needs attention
# (not clean / not in sync / mid-operation / no upstream).
#
# Changes NOTHING: 'git fetch' only updates remote-tracking refs; everything else is a read.
# Run it in a NATIVE shell (it runs git) - a synced-mount agent narrates it for the human.
# Twin: fleet-status.sh (keep behavior identical - see tools/README.md).
#
# Usage: .\tools\fleet-status.ps1
$ErrorActionPreference = 'Continue'
$kit = Split-Path -Parent $PSScriptRoot
$targets = Join-Path $kit 'tools/TARGETS.list'

if (-not $env:OGDK_BANNER) {
    Write-Host '   ___   ____ ____  _  __' -ForegroundColor Cyan
    Write-Host '  / _ \ / ___|  _ \| |/ /' -ForegroundColor Cyan
    Write-Host ' | | | | |  _| | | | '' /' -ForegroundColor Cyan
    Write-Host ' | |_| | |_| | |_| | . \' -ForegroundColor Cyan
    Write-Host '  \___/ \____|____/|_|\_\' -ForegroundColor Cyan
}
Write-Host '======================================' -ForegroundColor Cyan
Write-Host '  Fleet Status - read-only (OGDK)     ' -ForegroundColor Cyan
Write-Host '======================================' -ForegroundColor Cyan

function Report-Repo($d, $label) {
    if (-not (Test-Path (Join-Path $d '.git'))) {
        Write-Host ('{0,1} {1,-15} {2}' -f ' ', $label, '(not a git repo / missing)')
        return
    }
    Push-Location $d
    git fetch -q --all 2>$null | Out-Null
    # symbolic-ref gives the branch name even on an unborn HEAD (no fatal noise);
    # fall back to a short hash for detached HEAD, '?' only if truly indeterminate.
    $br = (git symbolic-ref --short -q HEAD 2>$null)
    if (-not $br) { $br = (git rev-parse --short HEAD 2>$null) }
    if (-not $br) { $br = '?' }
    $null = git rev-parse --abbrev-ref '@{upstream}' 2>$null
    if ($LASTEXITCODE -eq 0) {
        $c = (git rev-list --left-right --count 'HEAD...@{upstream}' 2>$null)
        $parts = ($c -split '\s+') | Where-Object { $_ -ne '' }
        $ahead = $parts[0]; $behind = $parts[1]
    } else {
        $ahead = '?'; $behind = 'noUP'
    }
    $dirty = @(git status --porcelain 2>$null).Count
    $stash = @(git stash list 2>$null).Count
    $gd = (git rev-parse --git-dir 2>$null)
    $state = 'ok'
    if (Test-Path (Join-Path $gd 'MERGE_HEAD')) { $state = 'MERGING' }
    elseif ((Test-Path (Join-Path $gd 'rebase-merge')) -or (Test-Path (Join-Path $gd 'rebase-apply'))) { $state = 'REBASING' }
    $kv = '-'
    if (Test-Path 'tools/KIT-VERSION') { $kv = (Get-Content 'tools/KIT-VERSION' -TotalCount 1) }
    $kv = $kv -replace ' \(.*$', ''   # drop the "(kit version + commit ...; do not edit)" annotation

    $att = $false
    if ($state -ne 'ok') { $att = $true }
    if ($dirty -ne 0) { $att = $true }
    if ($ahead -match '^\d+$' -and [int]$ahead -gt 0) { $att = $true }
    if ($behind -eq 'noUP') { $att = $true } elseif ($behind -match '^\d+$' -and [int]$behind -gt 0) { $att = $true }
    $mark = ' '; if ($att) { $mark = '*' }

    $line = '{0,1} {1,-15} {2,-7} {3,5} {4,6} {5,5} {6,5}  {7,-9} {8}' -f $mark, $label, $br, $ahead, $behind, $dirty, $stash, $state, $kv
    if ($att) { Write-Host $line -ForegroundColor Yellow } else { Write-Host $line }
    Pop-Location
}

Write-Host ('{0,1} {1,-15} {2,-7} {3,5} {4,6} {5,5} {6,5}  {7,-9} {8}' -f ' ', 'REPO', 'BRANCH', 'AHEAD', 'BEHIND', 'DIRTY', 'STASH', 'STATE', 'KIT-VERSION')
Write-Host '------------------------------------------------------------------------------'

Report-Repo $kit ((Split-Path -Leaf $kit) + ' (kit)')

if (Test-Path $targets) {
    foreach ($line in (Get-Content $targets -Encoding UTF8)) {
        $t = $line.Trim()
        if ($t -eq '' -or $t.StartsWith('#')) { continue }
        Report-Repo $t (Split-Path -Leaf $t)
    }
} else {
    Write-Host '  (no tools/TARGETS.list - add one project root per line to sweep your fleet)'
}

Write-Host '------------------------------------------------------------------------------'
Write-Host "  Read-only: nothing changed. '*' = needs attention - resolve via the"
Write-Host '  GIT-LIFECYCLE.md sub-flows (S1-S6) BEFORE propagating.'
exit 0
