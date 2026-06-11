# Kit docs self-check (OGDK only - not propagated to projects).
# Enforces: twin rule; user-notes.md + tools/README.md mention every tools script;
# no ghost references; .ps1 hygiene (ASCII, no here-strings); no hardcoded user
# paths in tools/; relative links in non-template .md resolve; no private markers
# (tools/PRIVATE-MARKERS.list, gitignored, per-owner). Twin: check-kit-docs.sh.
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

# 5. .ps1 hygiene: ASCII only + no here-strings (PS 5.1 with LF endings)
$psOk = $true
foreach ($f in (Get-ChildItem tools -Filter *.ps1)) {
    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
    $nonAscii = $false
    foreach ($byte in $bytes) { if ($byte -gt 127) { $nonAscii = $true; break } }
    if ($nonAscii) {
        Write-Host "[FAIL] non-ASCII byte(s) in tools/$($f.Name) - PS 5.1 hazard (tools/README.md rule 2)" -ForegroundColor Red
        $issues++; $psOk = $false
    }
    $text = Get-Content $f.FullName -Raw -Encoding UTF8
    if ($text -match '@["'']') {
        Write-Host "[FAIL] here-string in tools/$($f.Name) - breaks PS 5.1 parsing with LF endings" -ForegroundColor Red
        $issues++; $psOk = $false
    }
}
if ($psOk) { Write-Host '[PASS] .ps1 hygiene: ASCII-only, no here-strings' -ForegroundColor Green }

# 6. hardcoded user paths in tools/ (kit must work on ANY machine)
$hardOk = $true
$hardPat = 'C:\\Users\\[A-Za-z]|/home/[a-z]|/Users/[A-Za-z]'
foreach ($f in (Get-ChildItem tools -File)) {
    $lineNum = 0
    foreach ($line in (Get-Content $f.FullName -Encoding UTF8)) {
        $lineNum++
        if ($line -match $hardPat) {
            Write-Host "[FAIL] hardcoded user path in tools/$($f.Name):${lineNum}: $($line.Trim())" -ForegroundColor Red
            $issues++; $hardOk = $false
        }
    }
}
if ($hardOk) { Write-Host '[PASS] no hardcoded user paths in tools/' -ForegroundColor Green }

# 7. relative markdown links resolve (non-template .md only)
$linkOk = $true
$mdFiles = Get-ChildItem -Recurse -Filter *.md -File | Where-Object {
    $_.FullName -notmatch '\\\.git\\' -and
    $_.FullName -notmatch '\\docs-template\\' -and
    $_.FullName -notmatch '/\.git/' -and
    $_.FullName -notmatch '/docs-template/' -and
    $_.Name -notmatch 'template'
}
foreach ($f in $mdFiles) {
    $text = Get-Content $f.FullName -Raw -Encoding UTF8
    $links = [regex]::Matches($text, '\]\(([^)]+)\)') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
    foreach ($link in $links) {
        if ($link -match '^(http://|https://|mailto:|#)') { continue }
        $target = ($link -split '#')[0]
        if ($target -eq '') { continue }
        if ($target -notmatch '[A-Za-z0-9]') { continue }
        $resolved = Join-Path $f.DirectoryName $target
        if (-not (Test-Path $resolved)) {
            $rel = $f.FullName.Substring($kit.Length + 1)
            Write-Host "[FAIL] ${rel}: broken relative link -> $link" -ForegroundColor Red
            $issues++; $linkOk = $false
        }
    }
}
if ($linkOk) { Write-Host '[PASS] all relative links in non-template .md files resolve' -ForegroundColor Green }

# 8. private markers (tools/PRIVATE-MARKERS.list - gitignored, per-owner).
#    Reports marker INDEX only, never the marker text, so output stays shareable.
$markFile = 'tools/PRIVATE-MARKERS.list'
if (Test-Path $markFile) {
    $markers = @()
    foreach ($line in (Get-Content $markFile -Encoding UTF8)) {
        $t = $line.Trim()
        if ($t -ne '' -and -not $t.StartsWith('#')) { $markers += $t }
    }
    $markOk = $true
    if ($markers.Count -gt 0) {
        $scanFiles = Get-ChildItem -Recurse -File | Where-Object {
            $_.FullName -notmatch '\\\.git\\' -and
            $_.Name -ne 'user-notes.local.md' -and
            $_.Name -ne 'PRIVATE-MARKERS.list' -and
            $_.Length -lt 1048576
        }
        foreach ($f in $scanFiles) {
            $text = Get-Content $f.FullName -Raw -Encoding UTF8
            if ($null -eq $text) { continue }
            $lower = $text.ToLower()
            $mIdx = 0
            foreach ($m in $markers) {
                $mIdx++
                if ($lower.Contains($m.ToLower())) {
                    $rel = $f.FullName.Substring($kit.Length + 1)
                    Write-Host "[FAIL] private marker #$mIdx found in: $rel (text withheld - marker #$mIdx in your PRIVATE-MARKERS.list)" -ForegroundColor Red
                    $issues++; $markOk = $false
                }
            }
        }
    }
    if ($markOk) { Write-Host "[PASS] no private markers in scanned files ($($markers.Count) marker(s) checked)" -ForegroundColor Green }
} else {
    Write-Host '[WARN] tools/PRIVATE-MARKERS.list not found - private-marker scan skipped (seed yours: see tools/README.md)' -ForegroundColor Yellow
}

Write-Host '--------------------------------------' -ForegroundColor Cyan
if ($issues -eq 0) {
    Write-Host '  KIT DOCS OK' -ForegroundColor Green
} else {
    Write-Host "  $issues ISSUE(S) - update user-notes.md / tools/README.md in this commit" -ForegroundColor Red
}
exit $issues
