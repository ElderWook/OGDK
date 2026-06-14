# OGDK - scaffold a new project from the kit
# Usage: .\tools\new-project.ps1 -Name "MyProject" -Type App [-Dest C:\Dev] [-NoGit]
param(
    [Parameter(Mandatory)][string]$Name,
    [Parameter(Mandatory)][ValidateSet('App','Game')][string]$Type,
    [string]$Dest = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)),
    [string]$Features = '',
    [string]$Preset = '',
    [switch]$NoGit
)
$ErrorActionPreference = 'Stop'
$kit  = Split-Path -Parent $PSScriptRoot
$proj = Join-Path $Dest $Name
if (Test-Path $proj) { throw "Target already exists: $proj" }

# Preset name (A-E) -> module set. core + app are added later as the always-present law.
function Expand-Preset([string]$p) {
    switch ($p.ToUpper()) {
        'A' { 'core,store,sync,bridge,render' }
        'B' { 'core,store,api,adapters,jobs' }
        'C' { 'core' }
        'D' { 'core,store' }
        'E' { 'core,store,render' }
        default { '' }
    }
}
# One annotated placeholder dir per chosen module. Language code is GENERATED later by
# the agent per CODE-CONVENTIONS - the kit never stores boilerplate that would rot.
function Write-Module([string]$m, [string]$intent, [string]$boundary) {
    $d = Join-Path $proj "src\$m"
    New-Item -ItemType Directory -Path $d -Force | Out-Null
    $body = @(
        "# $m/ - structural placeholder (generate the real module here)",
        '',
        "@intent $intent",
        "@boundary $boundary",
        '',
        '> This directory marks a module the app needs. Generate its implementation',
        '> in your chosen language per docs/core/app-architecture.md and the kit',
        '> CODE-CONVENTIONS: an annotated header, a mirrored test, gate green BEFORE',
        '> any feature code. Delete this placeholder once the module + its test exist.'
    )
    Set-Content -Path (Join-Path $d '_MODULE.md') -Value $body
}

if (-not $env:OGDK_BANNER) {
    Write-Host '   ___   ____ ____  _  __' -ForegroundColor Cyan
    Write-Host '  / _ \ / ___|  _ \| |/ /' -ForegroundColor Cyan
    Write-Host ' | | | | |  _| | | | '' /' -ForegroundColor Cyan
    Write-Host ' | |_| | |_| | |_| | . \' -ForegroundColor Cyan
    Write-Host '  \___/ \____|____/|_|\_\' -ForegroundColor Cyan
}
# Feature resolution (App track only) - mirrors new-project.sh. -Preset expands to a
# module set; -Features is an explicit csv; with neither, an interactive console gets a
# one-question wizard. Non-interactive with no flags = no modules (a clean blank slate).
if ($Type -eq 'App') {
    if ($Features -eq '' -and $Preset -ne '') {
        $Features = Expand-Preset $Preset
        if ($Features -eq '') { throw "Unknown preset '$Preset' (use A-E)" }
    }
    if ($Features -eq '' -and $Preset -eq '' -and [Environment]::UserInteractive -and -not [Console]::IsInputRedirected) {
        Write-Host 'Pick a starting shape for your app (you can change it later):'
        Write-Host '  A) local-first, multi-device      (core + store + sync + bridge + render)'
        Write-Host '  B) web service / API              (core + store + api + adapters + jobs)'
        Write-Host '  C) command-line tool              (core)'
        Write-Host '  D) simple web app                 (core + store)'
        Write-Host '  E) single desktop app  [default]  (core + store + render)'
        $choice = Read-Host 'Your choice [E]'
        if ([string]::IsNullOrWhiteSpace($choice)) { $choice = 'E' }
        $Features = Expand-Preset $choice
        if ($Features -eq '') { throw "Unknown choice '$choice' (use A-E)" }
    }
} elseif ($Features -ne '' -or $Preset -ne '') {
    Write-Host '[note] -Features/-Preset apply to the App track only; ignoring for a Game project.' -ForegroundColor Yellow
    $Features = ''
}

Write-Host "Scaffolding $Type project '$Name' -> $proj"
New-Item -ItemType Directory -Path $proj | Out-Null

# 1. Docs chain
Copy-Item -Recurse (Join-Path $kit 'docs-template') (Join-Path $proj 'docs')
Rename-Item (Join-Path $proj 'docs\STATUS.template.md') 'STATUS.md'
Rename-Item (Join-Path $proj 'docs\README.template.md') 'README.md'

# 2. Agent rules + Claude pointer + Changelog
Copy-Item (Join-Path $kit 'AGENTS.template.md') (Join-Path $proj 'AGENTS.md')
Copy-Item (Join-Path $kit 'CLAUDE.template.md') (Join-Path $proj 'CLAUDE.md')
Copy-Item (Join-Path $kit 'CHANGELOG.template.md') (Join-Path $proj 'CHANGELOG.md')

# 3. Tools (PATH health is mandatory on Windows; list lives in PROPAGATE.list)
New-Item -ItemType Directory -Path (Join-Path $proj 'tools') | Out-Null
foreach ($raw in (Get-Content (Join-Path $kit 'tools\PROPAGATE.list') -Encoding UTF8)) {
    $tname = ($raw -split '#')[0].Trim()
    if ($tname -eq '') { continue }
    Copy-Item (Join-Path $kit ('tools\' + $tname + '.ps1')),(Join-Path $kit ('tools\' + $tname + '.sh')) (Join-Path $proj 'tools')
    $tbat = Join-Path $kit ('tools\' + $tname + '.bat')
    if (Test-Path $tbat) { Copy-Item $tbat (Join-Path $proj 'tools') }
}
Copy-Item (Join-Path $kit 'tools\gate.template.ps1') (Join-Path $proj 'tools\gate.ps1')
Copy-Item (Join-Path $kit 'tools\gate.template.sh')  (Join-Path $proj 'tools\gate.sh')
# 3b. Git hooks (pre-push and pre-commit guards)
New-Item -ItemType Directory -Path (Join-Path $proj 'tools\hooks') | Out-Null
foreach ($hook in @("pre-push", "pre-commit")) {
    $hookSrc = Join-Path $kit "tools\hooks\$hook"
    if (Test-Path $hookSrc) { Copy-Item $hookSrc (Join-Path $proj "tools\hooks\$hook") }
}
# Provenance stamp: which kit version+commit these tools came from (drift visibility)
$kitver = 'unknown'
try { $v = git -C $kit rev-parse --short HEAD 2>$null; if ($LASTEXITCODE -eq 0 -and $v) { $kitver = $v.Trim() } } catch { }
$kitSemver = ''
$verFile = Join-Path $kit 'VERSION'
if (Test-Path $verFile) {
    $sv = (Get-Content $verFile -Encoding UTF8 | Select-Object -First 1).Trim()
    if ($sv -ne '') { $kitSemver = "v$sv " }
}
Set-Content -Path (Join-Path $proj 'tools\KIT-VERSION') -Value "$kitSemver$kitver $(Get-Date -Format yyyy-MM-dd) (kit version + commit + propagation date - written by propagate-tools/new-project; do not edit)" -Encoding ASCII

# 4. Skills for Claude Code
New-Item -ItemType Directory -Path (Join-Path $proj '.claude') | Out-Null
Copy-Item -Recurse (Join-Path $kit 'skills') (Join-Path $proj '.claude\skills')

# 5. Track-specific
if ($Type -eq 'Game') {
    Copy-Item (Join-Path $kit 'game\gitignore.game.template')     (Join-Path $proj '.gitignore')
    Copy-Item (Join-Path $kit 'game\gitattributes.game.template') (Join-Path $proj '.gitattributes')
    Copy-Item (Join-Path $kit 'game\STACK.md') (Join-Path $proj 'docs\core\game-architecture.md')
    Copy-Item -Recurse (Join-Path $kit 'game\conventions') (Join-Path $proj 'docs\core\conventions')
} else {
    Set-Content -Path (Join-Path $proj '.gitignore') -Value @('node_modules/','dist/','*.sqlite','.env')
    Set-Content -Path (Join-Path $proj '.gitattributes') -Value @('* text=auto','*.sh text eol=lf','*.ps1 text eol=crlf','*.bat text eol=crlf')
    Copy-Item (Join-Path $kit 'app\STACK.md') (Join-Path $proj 'docs\core\app-architecture.md')
}

# 5b. Project root README (pointer into the chain)
$kitUrl = $kit -replace '\\','/'
$readme = @(
    "# $Name",
    '',
    "An Oasis Games LLC project, scaffolded from [OGDK]($kitUrl).",
    '',
    '**Start here:** [docs/00-START-HERE.md](./docs/00-START-HERE.md) - the session chain',
    '(AGENTS.md -> docs/STATUS.md -> active plan) for humans and AI alike.'
)
Set-Content -Path (Join-Path $proj 'README.md') -Value $readme

# 5c. Feature modules (App track): one annotated placeholder dir per chosen module.
if ($Type -eq 'App' -and $Features -ne '') {
    New-Item -ItemType Directory -Path (Join-Path $proj 'src') -Force | Out-Null
    $added = @()
    $order = @('core', 'app') + ($Features -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' })
    foreach ($m in $order) {
        if ($added -contains $m) { continue }
        $added += $m
        switch ($m) {
            'core'     { Write-Module 'core'     'pure domain logic, exact math, validation' 'depends on nothing; every other module points here' }
            'app'      { Write-Module 'app'      'composition root - wiring ONLY, one per surface' 'may import any module; nothing imports it' }
            'store'    { Write-Module 'store'    'durable atomic persistence + migrations' 'core has no direct access to the store' }
            'sync'     { Write-Module 'sync'     'multi-device replication + authority model' 'decide conflict/authority policy day one; parity tests mandatory' }
            'bridge'   { Write-Module 'bridge'   'per-platform injection (the platform-bridge pattern)' 'platform code calls pure core through interfaces only' }
            'render'   { Write-Module 'render'   'documents and exports' 'keep themes separate from generation primitives' }
            'jobs'     { Write-Module 'jobs'     'background work queue + status' 'runs async; never blocks the main path' }
            'identity' { Write-Module 'identity' 'sessions, permissions, third-party identity' 'buy-don''t-build the crypto/protocol' }
            'adapters' { Write-Module 'adapters' 'one folder per external service' 'zero inline integration calls inside core' }
            'api'      { Write-Module 'api'      'versioned external surface' 'API versioning decoupled from core changes' }
            default    { Write-Module $m         'custom module' 'declare its boundary before writing code' }
        }
    }
    Write-Host "  src/ modules: $($added -join ', ')"
}

# 6. Token replacement
$date = Get-Date -Format 'yyyy-MM-dd'
Get-ChildItem $proj -Recurse -Include *.md | ForEach-Object {
    $txt = Get-Content $_.FullName -Raw
    $txt = $txt -replace '\{\{PROJECT_NAME\}\}', $Name
    $txt = $txt -replace '\{\{DATE\}\}', $date
    Set-Content -Path $_.FullName -Value $txt -NoNewline
}

# 7. Git
if (-not $NoGit) {
    $gitEmail = git config user.email
    if (-not $gitEmail) {
        Write-Warning 'git identity not set (git config --global user.name / user.email) - skipping git init. Init manually after setting it.'
    } else {
        Push-Location $proj
        $oldEAP = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            git init -b main 2>$null | Out-Null
            if ($Type -eq 'Game') {
                if (Get-Command git-lfs -ErrorAction SilentlyContinue) {
                    git lfs install 2>$null | Out-Null
                } else {
                    Write-Warning 'git-lfs not installed - install it BEFORE committing any .uasset (a binary committed without LFS is permanent repo weight).'
                }
            }
            git add -A 2>$null
            git commit -m "chore: scaffold $Name from OGDK ($Type track)" 2>$null | Out-Null
            $inst = Join-Path $proj "tools\install-hooks.ps1"
            if (Test-Path $inst) { & $inst 2>$null | Out-Null }
        } finally {
            $ErrorActionPreference = $oldEAP
            Pop-Location
        }
    }
}

# 8. Register this project in the kit's fleet list (gitignored tools\TARGETS.list, per-machine)
#    so fleet-status and propagate-tools -All pick it up automatically. Idempotent.
$targetsList = Join-Path $kit 'tools\TARGETS.list'
$projAbs = (Resolve-Path $proj).Path
$already = $false
if (Test-Path $targetsList) {
    foreach ($l in (Get-Content $targetsList -Encoding UTF8)) {
        if ($l.Trim() -eq $projAbs) { $already = $true; break }
    }
}
if (-not $already) {
    Add-Content -Path $targetsList -Value $projAbs -Encoding ASCII
    Write-Host "[INFO] registered in tools\TARGETS.list (fleet tracking): $projAbs"
}

Write-Host ''
Write-Host 'Done. Next steps:' -ForegroundColor Green
Write-Host '  1. Fill in AGENTS.md (architecture, invariants, verification gate)'
if ($Type -eq 'Game') {
    Write-Host '  2. Create the .uproject + Source/ + Plugins/ per docs/core/game-architecture.md'
} else {
    Write-Host '  2. Scaffold the app per docs/core/app-architecture.md'
}
Write-Host '  3. Write your first plan in docs/plans/, update docs/STATUS.md'
Write-Host '  4. See OGDK checklists/new-project.md for the full list'
if ($Type -eq 'App' -and $Features -ne '') {
    Write-Host '  * src/ has annotated module placeholders - ask your agent to generate each'
    Write-Host '    one (real code + a mirrored test), gate green before any feature work.'
}
exit 0
