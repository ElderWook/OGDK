# OGDK - track-projects. Register OGDK projects into the kit's gitignored tools\TARGETS.list
# so fleet-status and propagate-tools -All pick them up. An OGDK project = a git repo that
# carries tools\KIT-VERSION (stamped by new-project / propagate-tools). The kit itself has no
# KIT-VERSION, so it is never added. Idempotent: an entry is never duplicated.
#
# This is how a project cloned on ANOTHER machine gets tracked: TARGETS.list is per-machine
# and gitignored, so each machine maintains its own. Clone your projects, then run this once.
# (new-project already auto-registers projects on the machine that scaffolds them.)
#
#   .\tools\track-projects.ps1                  # scan the kit's parent dir, register all found
#   .\tools\track-projects.ps1 --scan <dir>     # scan a specific directory's immediate children
#   .\tools\track-projects.ps1 <path> [<path>]  # register specific project root(s)
#
# Only writes tools\TARGETS.list (a local, gitignored file). Kit-only (not propagated).
# Twin: track-projects.sh (keep behavior identical - see tools/README.md).
$ErrorActionPreference = 'Continue'
$kit = Split-Path -Parent $PSScriptRoot
$targets = Join-Path $kit 'tools\TARGETS.list'

if (-not $env:OGDK_BANNER) {
    Write-Host '   ___   ____ ____  _  __' -ForegroundColor Cyan
    Write-Host '  / _ \ / ___|  _ \| |/ /' -ForegroundColor Cyan
    Write-Host ' | | | | |  _| | | | '' /' -ForegroundColor Cyan
    Write-Host ' | |_| | |_| | |_| | . \' -ForegroundColor Cyan
    Write-Host '  \___/ \____|____/|_|\_\' -ForegroundColor Cyan
}
Write-Host '======================================' -ForegroundColor Cyan
Write-Host '  Track Projects - fleet registry     ' -ForegroundColor Cyan
Write-Host '======================================' -ForegroundColor Cyan

function Test-OgdkProject($p) {
    return (Test-Path (Join-Path $p '.git')) -and (Test-Path (Join-Path (Join-Path $p 'tools') 'KIT-VERSION'))
}
function Test-AlreadyTracked($p) {
    if (-not (Test-Path $targets)) { return $false }
    foreach ($l in (Get-Content $targets -Encoding UTF8)) { if ($l.Trim() -eq $p) { return $true } }
    return $false
}
$script:added = 0
function Register-Project($p) {
    if (Test-AlreadyTracked $p) {
        Write-Host "  = already tracked: $p"
    } else {
        Add-Content -Path $targets -Value $p -Encoding ASCII
        Write-Host "  + registered:      $p"
        $script:added++
    }
}

$scanRoot = Split-Path -Parent $kit
$explicit = @()
$modeScan = $true
for ($i = 0; $i -lt $args.Count; $i++) {
    $a = $args[$i]
    if ($a -eq '--scan') { $scanRoot = $args[$i + 1]; $i++ }
    elseif ($a -eq '-h' -or $a -eq '--help') {
        Write-Host 'usage: track-projects.ps1 [--scan <dir>] | [<project-path> ...]'
        exit 0
    }
    else { $explicit += $a; $modeScan = $false }
}

if ($modeScan) {
    Write-Host "Scanning $scanRoot for OGDK projects (git repo + tools/KIT-VERSION)..."
    $found = 0
    foreach ($d in (Get-ChildItem -Path $scanRoot -Directory -ErrorAction SilentlyContinue)) {
        if (Test-OgdkProject $d.FullName) {
            $found++
            Register-Project $d.FullName
        }
    }
    if ($found -eq 0) { Write-Host "  (no OGDK projects found under $scanRoot)" }
} else {
    foreach ($p in $explicit) {
        if (-not (Test-Path $p -PathType Container)) { Write-Host "  ! not found:       $p"; continue }
        $abs = (Resolve-Path $p).Path
        if (Test-OgdkProject $abs) { Register-Project $abs }
        else { Write-Host "  ! not an OGDK project (no .git or tools\KIT-VERSION): $abs" }
    }
}

Write-Host '--------------------------------------'
Write-Host "  $script:added newly registered. tools\TARGETS.list now drives fleet-status +"
Write-Host '  propagate-tools -All. Run .\tools\fleet-status.ps1 to see the fleet.'
exit 0
