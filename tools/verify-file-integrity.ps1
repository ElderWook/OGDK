# File integrity check (OGDK) - detects the corruption signatures we have actually seen:
#   1. NUL bytes inside tracked text files  (MSYS2/NTFS zero-filled-tail corruption)
#   2. Truncated source files               (.py checked by compile, if python present)
#   3. Git object-store corruption          (git fsck)
# Run BEFORE committing after heavy agent writes. Twin: verify-file-integrity.sh.
$ErrorActionPreference = 'Continue'
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot
$issues = 0

Write-Host '======================================' -ForegroundColor Cyan
Write-Host '  File Integrity Check (OGDK)         ' -ForegroundColor Cyan
Write-Host '======================================' -ForegroundColor Cyan

# Check 1: git object store
if (Test-Path '.git') {
    git fsck --no-progress 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host '[PASS] git fsck: object store healthy' -ForegroundColor Green
    } else {
        Write-Host '[FAIL] git fsck reports corruption - do NOT commit; investigate .git' -ForegroundColor Red
        $issues++
    }
} else {
    Write-Host '[WARN] not a git repo - skipping fsck' -ForegroundColor Yellow
}

# Check 2: NUL bytes in tracked text files
$textExt = '\.(md|txt|py|js|ts|jsx|tsx|json|ps1|sh|bat|cs|cpp|c|h|hpp|ini|yml|yaml|toml|svelte|dart|cjs|mjs|html|css|xml|sql|uproject|uplugin|gitignore|gitattributes)$'
$tracked = git ls-files 2>$null | Where-Object { $_ -match $textExt }
$nulHits = @()
foreach ($f in $tracked) {
    if (-not (Test-Path $f)) { continue }
    $fi = Get-Item $f
    if ($fi.Length -eq 0 -or $fi.Length -gt 5MB) { continue }
    $bytes = [System.IO.File]::ReadAllBytes($fi.FullName)
    if ($bytes -contains 0) { $nulHits += $f }
}
if ($nulHits.Count -gt 0) {
    Write-Host '[FAIL] NUL bytes found in text files (zero-fill corruption signature):' -ForegroundColor Red
    $nulHits | ForEach-Object { Write-Host "       $_" -ForegroundColor Yellow }
    $issues++
} else {
    Write-Host '[PASS] no NUL bytes in tracked text files' -ForegroundColor Green
}

# Check 3: Python files compile (catches mid-file truncation)
$py = Get-Command python -ErrorAction SilentlyContinue
if (-not $py) { $py = Get-Command python3 -ErrorAction SilentlyContinue }
if ($py) {
    $pyBad = @()
    foreach ($f in (git ls-files '*.py' 2>$null)) {
        if (-not (Test-Path $f)) { continue }
        & $py.Source -m py_compile $f 2>$null
        if ($LASTEXITCODE -ne 0) { $pyBad += $f }
    }
    if ($pyBad.Count -gt 0) {
        Write-Host '[FAIL] Python files do not compile (possible truncation):' -ForegroundColor Red
        $pyBad | ForEach-Object { Write-Host "       $_" -ForegroundColor Yellow }
        $issues++
    } else {
        Write-Host '[PASS] all tracked .py files compile' -ForegroundColor Green
    }
}

# Check 4: trailing-newline smell test on source/docs
$noEol = @()
foreach ($f in (git ls-files 2>$null | Where-Object { $_ -match '\.(py|sh|md)$' })) {
    if (-not (Test-Path $f)) { continue }
    $fi = Get-Item $f
    if ($fi.Length -eq 0) { continue }
    $fs = [System.IO.File]::Open($fi.FullName, 'Open', 'Read')
    $fs.Seek(-1, 'End') | Out-Null
    $last = $fs.ReadByte()
    $fs.Close()
    if ($last -ne 10) { $noEol += $f }
}
if ($noEol.Count -gt 0) {
    Write-Host '[WARN] files lacking trailing newline (verify they are complete):' -ForegroundColor Yellow
    $noEol | ForEach-Object { Write-Host "       $_" -ForegroundColor Yellow }
} else {
    Write-Host '[PASS] all checked files end with newline' -ForegroundColor Green
}

Write-Host '--------------------------------------' -ForegroundColor Cyan
if ($issues -eq 0) {
    Write-Host '  INTEGRITY OK - safe to commit' -ForegroundColor Green
} else {
    Write-Host "  $issues ISSUE(S) - do NOT commit until resolved" -ForegroundColor Red
}
exit $issues
