# Kit docs self-check (OGDK only - not propagated to projects).
# Enforces: twin rule; user-notes.md + tools/README.md mention every tools script;
# no ghost references to deleted scripts. Twin: check-kit-docs.sh.
$ErrorActionPreference = 'Continue'
$kit = Split-Path -Parent $PSScriptRoot
Set-Location $kit
$issues = 0

Write-Host '======================================' -ForegroundColor Cyan
Write-Host '  Kit Docs Self-Check (OGDK)          ' -ForegroundColor Cyan
Write-Host '======================================' -ForegroundColor Cyan

# 1. Twin rule
$twinOk = $true
foreach ($f in (Get-ChildItem tools -Filter *.ps1)) {
    $b = $f.BaseName
    if (-not (Test-Path "tools/$b.sh")) {
        Write-Host "[FAIL] twin missing: tools/$($f.Name) has no tools/$b.sh" -ForegroundColor Red
        $issues++; $twinOk = $false
    }
}
foreach ($f in (Get-ChildItem tools -Filter *.sh)) {
    $b = $f.BaseName
    if (-not (Test-Path "tools/$b.ps1")) {
        Write-Host "[FAIL] twin missing: tools/$($f.Name) has no tools/$b.ps1" -ForegroundColor Red
        $issues++; $twinOk = $false
    }
}
if ($twinOk) { Write-Host '[PASS] twin rule: every script has its pair' -ForegroundColor Green }

# 2+3. every script mentioned in user-notes.md and tools/README.md
foreach ($doc in @('user-notes.md', 'tools/README.md')) {
    $docText = Get-Content $doc -Raw -Encoding UTF8
    $docOk = $true
    foreach ($f in (Get-ChildItem tools -Filter *.ps1)) {
        if ($docText -notmatch [regex]::Escape($f.BaseName)) {
            Write-Host "[FAIL] $doc does not mention script '$($f.BaseName)'" -ForegroundColor Red
            $issues++; $docOk = $false
        }
    }
    if ($docOk) { Write-Host "[PASS] $doc covers all tools scripts" -ForegroundColor Green }
}

# 4. ghost references (mentioned but deleted)
$ghostOk = $true
foreach ($doc in @('user-notes.md', 'tools/README.md')) {
    $docText = Get-Content $doc -Raw -Encoding UTF8
    $names = [regex]::Matches($docText, '[a-z][a-z0-9-]+\.(ps1|sh)') | ForEach-Object { $_.Value } | Sort-Object -Unique
    foreach ($name in $names) {
        $base = $name -replace '\.(ps1|sh)$', ''
        if (-not (Test-Path "tools/$base.ps1") -and -not (Test-Path "tools/$base.sh")) {
            Write-Host "[WARN] $doc mentions '$name' which does not exist in tools/ (removed? update the doc)" -ForegroundColor Yellow
            $ghostOk = $false
        }
    }
}
if ($ghostOk) { Write-Host '[PASS] no ghost script references in docs' -ForegroundColor Green }

Write-Host '--------------------------------------' -ForegroundColor Cyan
if ($issues -eq 0) {
    Write-Host '  KIT DOCS OK' -ForegroundColor Green
} else {
    Write-Host "  $issues ISSUE(S) - update user-notes.md / tools/README.md in this commit" -ForegroundColor Red
}
exit $issues
