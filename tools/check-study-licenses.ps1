#!/usr/bin/env pwsh
# Study license checker (OGDK) - classifies every external study clone's license and
# flags copyleft / unknown sources that already have a fold-in (the code-vs-idea risk).
# Studies live OUTSIDE the kit (study-repo/study/<name>); this is a KIT tool, NOT
# propagated to projects. Run during a repo-study sweep and before any code-shaped ADOPT.
#   Permissive  (MIT/BSD/Apache/ISC) -> ideas AND code reusable with attribution
#   weak-copyleft (LGPL/MPL)         -> ideas free; shipping the lib has obligations
#   strong-copyleft (GPL/AGPL)       -> IDEAS ONLY; never port algorithm/implementation
# Usage: check-study-licenses.ps1 [StudyDir]   (default: ..\study-repo\study)
# Twin: check-study-licenses.sh
param([string]$StudyDir)
$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot
$DevRoot  = Split-Path -Parent $RepoRoot
if (-not $StudyDir) { $StudyDir = Join-Path $DevRoot 'study-repo/study' }
if (-not (Test-Path $StudyDir)) { Write-Host "[skip] no study dir at $StudyDir (nothing to check)"; exit 0 }

function Classify([string]$t) {
    $u = $t.ToUpper()
    if ($u -match 'AFFERO|AGPL') { return 'AGPL|strong-copyleft' }
    if ($u -match 'LESSER GENERAL PUBLIC|LGPL') { return 'LGPL|weak-copyleft' }
    if ($u -match 'GENERAL PUBLIC LICENSE|GPL-2|GPL-3|GPLV| GPL|^GPL') { return 'GPL|strong-copyleft' }
    if ($u -match 'MOZILLA PUBLIC|MPL-') { return 'MPL|weak-copyleft' }
    if ($u -match 'APACHE') { return 'Apache-2.0|permissive' }
    if ($u -match 'PERMISSION IS HEREBY GRANTED|MIT LICENSE|^MIT') { return 'MIT|permissive' }
    if ($u -match 'REDISTRIBUTION AND USE IN SOURCE|BSD') { return 'BSD|permissive' }
    if ($u -match 'ISC LICENSE|^ISC') { return 'ISC|permissive' }
    if ($u -match 'UNLICENSE|PUBLIC DOMAIN') { return 'Unlicense|permissive' }
    return 'UNKNOWN|unknown'
}

function Detect([string]$d) {
    $lf = Get-ChildItem -LiteralPath $d -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '^(?i)(license|licence|copying)(\.|$)' } | Select-Object -First 1
    if ($lf) { $txt = (Get-Content -LiteralPath $lf.FullName -TotalCount 60 -ErrorAction SilentlyContinue) -join ' '; return (Classify $txt) + '|LICENSE' }
    $ld = Join-Path $d 'LICENSES'
    if (Test-Path $ld) { $ids = ((Get-ChildItem -LiteralPath $ld -File).BaseName) -join '+'; return (Classify $ids) + "|LICENSES/($ids)" }
    $pj = Join-Path $d 'package.json'
    if (Test-Path $pj) { $m = Select-String -LiteralPath $pj -Pattern '"license"' | Select-Object -First 1
        if ($m -and $m.Line -match '"license"\s*:\s*"([^"]+)"') { return (Classify $Matches[1]) + "|pkg:$($Matches[1])" } }
    foreach ($pf in @('pyproject.toml','setup.cfg','setup.py')) { $p = Join-Path $d $pf
        if (Test-Path $p) { $m = Select-String -LiteralPath $p -Pattern '(?i)licen[sc]e' | Select-Object -First 1
            if ($m) { return (Classify $m.Line) + '|pyproject' } } }
    $rd = Get-ChildItem -LiteralPath $d -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '^(?i)readme' } | Select-Object -First 1
    if ($rd) { $m = Select-String -LiteralPath $rd.FullName -Pattern '(?i)licen[sc]e' | Select-Object -First 1
        if ($m) { return (Classify $m.Line) + '|README' } }
    return 'UNKNOWN|unknown|none'
}

function Folded([string]$n) {
    $files = @((Join-Path $RepoRoot 'LESSONS.md'), (Join-Path $DevRoot 'STUDY-FOLD-IN-MAP.md'))
    $files += (Get-ChildItem -Path $DevRoot -Directory -ErrorAction SilentlyContinue |
        ForEach-Object { Join-Path $_.FullName 'docs/LESSONS.md' })
    foreach ($f in $files) { if (Test-Path $f) { if (Select-String -LiteralPath $f -Pattern ([regex]::Escape($n)) -Quiet) { return 'yes' } } }
    return 'no'
}

Write-Host "Study license check - $StudyDir"
("{0,-30} {1,-11} {2,-16} {3,-7} {4}" -f 'CLONE','LICENSE','CLASS','FOLDED','SRC')
Write-Host ('-' * 80)
$high = 0; $med = 0; $total = 0
foreach ($dir in (Get-ChildItem -LiteralPath $StudyDir -Directory)) {
    $total++
    $parts = (Detect $dir.FullName).Split('|')
    $id = $parts[0]; $class = $parts[1]; $src = $parts[2]
    $fold = Folded $dir.Name
    ("{0,-30} {1,-11} {2,-16} {3,-7} {4}" -f $dir.Name, $id, $class, $fold, $src)
    if ($fold -eq 'yes') {
        if ($class -eq 'strong-copyleft') { $high++ }
        elseif ($class -eq 'weak-copyleft' -or $class -eq 'unknown') { $med++ }
    }
}
Write-Host ('-' * 80)
Write-Host "Scanned $total clone(s). Fold-in risk: $high strong-copyleft, $med weak/unknown."
if ($high -gt 0) {
    Write-Host "[FAIL] strong-copyleft (GPL/AGPL) source(s) have a fold-in - confirm IDEAS ONLY,"
    Write-Host "       no algorithm/implementation was ported, and cite the license in the entry."
    exit 1
}
if ($med -gt 0) { Write-Host "[WARN] weak-copyleft/unknown source(s) folded - verify license posture." }
exit 0
# EOF
