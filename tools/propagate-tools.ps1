# Propagate kit tools (and optionally skills) into EXISTING project(s).
# (Kit only - new projects get these via new-project.) Windows twin of propagate-tools.sh.
#
# Usage:
#   .\tools\propagate-tools.ps1 -Target C:\MyProject            # tools from PROPAGATE.list
#   .\tools\propagate-tools.ps1 -Target C:\MyProject -Skills    # also sync .claude\skills
#   .\tools\propagate-tools.ps1 -All [-Skills]                  # every repo in TARGETS.list
#
# TARGETS.list (tools\TARGETS.list, GITIGNORED - project paths are personal):
# one absolute project-root path per line, '#' comments.
#
# Copies both twins per PROPAGATE.list entry, verifies each copy is non-empty and
# byte-identical (the 2026-06-11 truncated-propagation lesson), then stamps
# tools\KIT-VERSION in the target (kit commit + date - drift visibility).
# Never runs git in the TARGET repo (read-only rev-parse in the KIT only) -
# review and commit in each target yourself.
param(
    [string]$Target,
    [switch]$All,
    [switch]$Skills
)
$ErrorActionPreference = "Stop"
$kit  = Split-Path -Parent $PSScriptRoot
$list = Join-Path $kit "tools\PROPAGATE.list"
$targetsList = Join-Path $kit "tools\TARGETS.list"
if (-not (Test-Path $list)) { Write-Error "Missing $list"; exit 1 }

if (-not $env:OGDK_BANNER) {
    Write-Host '   ___   ____ ____  _  __' -ForegroundColor Cyan
    Write-Host '  / _ \ / ___|  _ \| |/ /' -ForegroundColor Cyan
    Write-Host ' | | | | |  _| | | | '' /' -ForegroundColor Cyan
    Write-Host ' | |_| | |_| | |_| | . \' -ForegroundColor Cyan
    Write-Host '  \___/ \____|____/|_|\_\' -ForegroundColor Cyan
}

$kitver = "unknown"
try {
    $v = git -C $kit rev-parse --short HEAD 2>$null
    if ($LASTEXITCODE -eq 0 -and $v) { $kitver = $v.Trim() }
} catch { }
$kitSemver = ""
$verFile = Join-Path $kit "VERSION"
if (Test-Path $verFile) {
    $sv = (Get-Content $verFile -Encoding UTF8 | Select-Object -First 1).Trim()
    if ($sv -ne "") { $kitSemver = "v$sv " }
}
$stamp = "$kitSemver$kitver $(Get-Date -Format yyyy-MM-dd) (kit version + commit + propagation date - written by propagate-tools/new-project; do not edit)"

$script:totalFailed = 0

function Propagate-One([string]$t) {
    if (-not (Test-Path $t -PathType Container)) {
        Write-Host "[FAIL] no such directory: $t" -ForegroundColor Red
        $script:totalFailed++; return
    }
    $t = (Resolve-Path $t).Path
    if (-not (Test-Path (Join-Path $t "tools"))) {
        Write-Host "[FAIL] $t\tools missing - is this an OGDK project root?" -ForegroundColor Red
        $script:totalFailed++; return
    }
    if ($t -eq $kit) { Write-Host "[SKIP] target is the kit itself"; return }
    Write-Host "=== $t ===" -ForegroundColor Cyan
    $copied = 0; $failed = 0
    foreach ($raw in (Get-Content $list -Encoding UTF8)) {
        $name = ($raw -split '#')[0].Trim()
        if ($name -eq "") { continue }
        foreach ($ext in @("sh", "ps1")) {
            $src = Join-Path $kit ("tools\" + $name + "." + $ext)
            $dst = Join-Path $t ("tools\" + $name + "." + $ext)
            if (-not (Test-Path $src)) {
                Write-Host "[FAIL] kit is missing $src (PROPAGATE.list stale?)" -ForegroundColor Red
                $failed++; continue
            }
            Copy-Item $src $dst -Force
            $dstLen = (Get-Item $dst).Length
            $srcHash = (Get-FileHash $src -Algorithm SHA256).Hash
            $dstHash = (Get-FileHash $dst -Algorithm SHA256).Hash
            if ($dstLen -eq 0 -or $srcHash -ne $dstHash) {
                Write-Host "[FAIL] $dst does not match source after copy (truncation?) - investigate" -ForegroundColor Red
                $failed++; continue
            }
            Write-Host "[OK]   $name.$ext" -ForegroundColor Green
            $copied++
        }
        # Optional Windows double-click shim (e.g. checkpoint.bat) travels with its pair.
        $batSrc = Join-Path $kit ("tools\" + $name + ".bat")
        if (Test-Path $batSrc) {
            Copy-Item $batSrc (Join-Path $t ("tools\" + $name + ".bat")) -Force
            Write-Host "[OK]   $name.bat" -ForegroundColor Green
            $copied++
        }
    }
    if ($Skills) {
        $skillsSrc = Join-Path $kit "skills"
        if (Test-Path $skillsSrc) {
            # Per-skill replace: remove the existing entry (file OR folder - old
            # flat layouts left leaf files that break a blind recursive copy),
            # then copy fresh. Entries the kit does not know are kept but flagged.
            $dstSkills = Join-Path $t ".claude\skills"
            New-Item -ItemType Directory -Force -Path $dstSkills | Out-Null
            foreach ($sd in (Get-ChildItem $skillsSrc -Directory)) {
                $dstSkill = Join-Path $dstSkills $sd.Name
                if (Test-Path $dstSkill) { Remove-Item $dstSkill -Recurse -Force }
                Copy-Item -Recurse $sd.FullName $dstSkill
            }
            $kitNames = @(Get-ChildItem $skillsSrc -Directory | ForEach-Object { $_.Name })
            foreach ($e in (Get-ChildItem $dstSkills -Force)) {
                if ($kitNames -notcontains $e.Name) {
                    Write-Host "[WARN] unknown entry in .claude\skills (not from kit - relic or custom? delete by hand if relic): $($e.Name)" -ForegroundColor Yellow
                }
            }
            Write-Host "[OK]   skills/ -> .claude\skills\ (per-skill replace)" -ForegroundColor Green
        } else {
            Write-Host "[FAIL] kit skills/ missing" -ForegroundColor Red
            $failed++
        }
    }
    Set-Content -Path (Join-Path $t "tools\KIT-VERSION") -Value $stamp -Encoding ASCII
    Write-Host "[OK]   KIT-VERSION stamped ($kitver)" -ForegroundColor Green
    Write-Host "Propagated $copied file(s); $failed failure(s)."
    $script:totalFailed += $failed
}

if ($All) {
    if (-not (Test-Path $targetsList)) {
        Write-Error "Missing $targetsList - create it (gitignored): one project root per line."; exit 1
    }
    $found = 0
    foreach ($raw in (Get-Content $targetsList -Encoding UTF8)) {
        $t = ($raw -split '#')[0].Trim()
        if ($t -eq "") { continue }
        $found++
        Propagate-One $t
    }
    if ($found -eq 0) { Write-Error "TARGETS.list has no entries."; exit 1 }
} else {
    if (-not $Target) { Write-Error "Usage: propagate-tools.ps1 -Target <path> [-Skills] | -All [-Skills]"; exit 1 }
    Propagate-One $Target
}

Write-Host "--------------------------------------"
if ($script:totalFailed -gt 0) {
    Write-Host "$($script:totalFailed) FAILURE(S) - fix before committing in the target repo(s)." -ForegroundColor Red
    exit 1
}
Write-Host "Next, IN EACH TARGET REPO: run its gate, review the diff, commit"
Write-Host "  (suggested msg: 'chore: propagate kit tools - <names>')."
exit 0
