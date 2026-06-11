# Propagate kit tools (and optionally skills) into an EXISTING project.
# (Kit only - new projects get these via new-project.) Windows twin of propagate-tools.sh.
#
# Usage:
#   .\tools\propagate-tools.ps1 -Target C:\DevKitGhost            # tools from PROPAGATE.list
#   .\tools\propagate-tools.ps1 -Target C:\DevKitGhost -Skills    # also sync .claude\skills
#
# Copies both twins per PROPAGATE.list entry, verifies each copy is non-empty and
# byte-identical (the 2026-06-11 truncated-propagation lesson).
# Does NOT run git anywhere - review and commit in the target repo yourself.
param(
    [Parameter(Mandatory=$true)][string]$Target,
    [switch]$Skills
)
$ErrorActionPreference = "Stop"
$kit  = Split-Path -Parent $PSScriptRoot
$list = Join-Path $kit "tools\PROPAGATE.list"

if (-not (Test-Path $Target -PathType Container)) { Write-Error "No such directory: $Target"; exit 1 }
$Target = (Resolve-Path $Target).Path
if (-not (Test-Path (Join-Path $Target "tools"))) { Write-Error "$Target\tools missing - is this an OGDK project root?"; exit 1 }
if (-not (Test-Path $list)) { Write-Error "Missing $list"; exit 1 }
if ($Target -eq $kit) { Write-Error "Target is the kit itself - nothing to do"; exit 1 }

$copied = 0; $failed = 0
foreach ($raw in (Get-Content $list -Encoding UTF8)) {
    $name = ($raw -split '#')[0].Trim()
    if ($name -eq "") { continue }
    foreach ($ext in @("sh", "ps1")) {
        $src = Join-Path $kit ("tools\" + $name + "." + $ext)
        $dst = Join-Path $Target ("tools\" + $name + "." + $ext)
        if (-not (Test-Path $src)) {
            Write-Host "[FAIL] kit is missing $src (PROPAGATE.list stale?)" -ForegroundColor Red
            $failed++; continue
        }
        Copy-Item $src $dst -Force
        $srcLen = (Get-Item $src).Length
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
}

if ($Skills) {
    $skillsSrc = Join-Path $kit "skills"
    if (Test-Path $skillsSrc) {
        $dotClaude = Join-Path $Target ".claude"
        if (-not (Test-Path $dotClaude)) { New-Item -ItemType Directory -Path $dotClaude | Out-Null }
        Copy-Item -Recurse -Force (Join-Path $skillsSrc "*") (Join-Path $dotClaude "skills")
        Write-Host "[OK]   skills/ -> .claude\skills\" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] kit skills/ missing" -ForegroundColor Red
        $failed++
    }
}

Write-Host "--------------------------------------"
Write-Host "Propagated $copied file(s) to $Target$(if ($Skills) { ' (+skills)' })."
if ($failed -gt 0) {
    Write-Host "$failed FAILURE(S) - fix before committing in the target repo." -ForegroundColor Red
    exit 1
}
Write-Host "Next, IN THE TARGET REPO: run its gate, review the diff, commit"
Write-Host "  (suggested msg: 'chore: propagate kit tools - <names>')."
exit 0
