
<#
.SYNOPSIS
    Launches claude.exe from a guaranteed-clean PATH (no MSYS2, WSL, or Cygwin injection).

.DESCRIPTION
    The truncation/corruption issue was traced to MSYS2 (C:\msys64\ucrt64\bin) being injected
    into the process PATH when Claude Code or agy is launched from an MSYS2 terminal.
    MSYS2 coreutils (sed, cp, mv, git) use POSIX file APIs against NTFS, which can produce
    zero-filled tails and truncation — especially during rapid in-place writes.

    This script sanitizes the PATH to only Windows-native tools before launching claude,
    ensuring no Linux-emulation binaries can corrupt files.

.USAGE
    Right-click → "Run with PowerShell"   (or pin as a shortcut)
    Or from a plain PowerShell terminal:  .\tools\launch-claude-clean.ps1
#>

# ── 1. Build a clean PATH (Windows-native tools only) ──────────────────────────
$CLEAN_PATH = @(
    "$env:SystemRoot\system32",
    "$env:SystemRoot",
    "$env:SystemRoot\System32\Wbem",
    "$env:SystemRoot\System32\WindowsPowerShell\v1.0",
    "$env:SystemRoot\System32\OpenSSH",
    "C:\Program Files\Git\cmd",
    "C:\Program Files\Git\usr\bin",        # git's bundled Unix tools (safe on Windows)
    "C:\Program Files\nodejs",
    "C:\Users\operator\AppData\Local\agy\bin",
    "C:\Users\operator\.cargo\bin",
    "C:\Users\operator\.local\bin",            # claude.exe lives here
    "C:\Users\operator\AppData\Roaming\npm",
    "C:\Users\operator\AppData\Local\Programs\Antigravity IDE\bin",
    "C:\Users\operator\AppData\Local\Microsoft\WindowsApps",
    "C:\Users\operator\AppData\Local\Microsoft\WinGet\Links"
) -join ';'

$env:PATH = $CLEAN_PATH

# ── 2. Sanity-check: confirm MSYS2 is gone ─────────────────────────────────────
$msysInPath = ($env:PATH -split ';') | Where-Object { $_ -match 'msys|ucrt|mingw|cygwin' }
if ($msysInPath) {
    Write-Warning "MSYS2 still detected in PATH after cleanup — aborting!"
    $msysInPath | ForEach-Object { Write-Warning "  $_" }
    exit 1
}

# ── 3. Verify git resolves to Windows Git, not MSYS2 ──────────────────────────
$gitPath = (Get-Command git -ErrorAction SilentlyContinue).Source
if ($gitPath -and $gitPath -notmatch 'Program Files\\Git') {
    Write-Warning "git resolves to '$gitPath' — not Windows Git! Check your PATH."
} else {
    Write-Host "[OK] git -> $gitPath" -ForegroundColor Green
}

# ── 4. Confirm sed is NOT MSYS2 sed (it shouldn't exist in clean PATH) ─────────
$sedPath = (Get-Command sed -ErrorAction SilentlyContinue).Source
if ($sedPath -and $sedPath -match 'msys|ucrt|mingw') {
    Write-Warning "sed resolves to MSYS2 sed: '$sedPath'"
} elseif ($sedPath) {
    Write-Host "[OK] sed -> $sedPath" -ForegroundColor Green
} else {
    Write-Host "[OK] sed not in PATH (expected — no MSYS2)" -ForegroundColor Green
}

# ── 5. Launch claude ───────────────────────────────────────────────────────────
$claudeExe = "C:\Users\operator\.local\bin\claude.exe"
if (-not (Test-Path $claudeExe)) {
    Write-Error "claude.exe not found at $claudeExe"
    exit 1
}

Write-Host ""
Write-Host "Launching claude from clean Windows-native PATH..." -ForegroundColor Cyan
Write-Host "Working directory: $PWD" -ForegroundColor DarkGray
Write-Host ""

& $claudeExe @args
