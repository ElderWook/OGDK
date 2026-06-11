# OGDK - scaffold a new project from the kit
# Usage: .\tools\new-project.ps1 -Name "MyProject" -Type App [-Dest C:\Dev] [-NoGit]
param(
    [Parameter(Mandatory)][string]$Name,
    [Parameter(Mandatory)][ValidateSet('App','Game')][string]$Type,
    [string]$Dest = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)),
    [switch]$NoGit
)
$ErrorActionPreference = 'Stop'
$kit  = Split-Path -Parent $PSScriptRoot
$proj = Join-Path $Dest $Name
if (Test-Path $proj) { throw "Target already exists: $proj" }

Write-Host "Scaffolding $Type project '$Name' -> $proj"
New-Item -ItemType Directory -Path $proj | Out-Null

# 1. Docs chain
Copy-Item -Recurse (Join-Path $kit 'docs-template') (Join-Path $proj 'docs')
Rename-Item (Join-Path $proj 'docs\STATUS.template.md') 'STATUS.md'
Rename-Item (Join-Path $proj 'docs\README.template.md') 'README.md'

# 2. Agent rules + Claude pointer
Copy-Item (Join-Path $kit 'AGENTS.template.md') (Join-Path $proj 'AGENTS.md')
Copy-Item (Join-Path $kit 'CLAUDE.template.md') (Join-Path $proj 'CLAUDE.md')

# 3. Tools (PATH health is mandatory on Windows)
New-Item -ItemType Directory -Path (Join-Path $proj 'tools') | Out-Null
Copy-Item (Join-Path $kit 'tools\verify-path-health.ps1'),(Join-Path $kit 'tools\launch-claude-clean.ps1'),(Join-Path $kit 'tools\verify-file-integrity.ps1'),(Join-Path $kit 'tools\check-reference-coverage.ps1'),(Join-Path $kit 'tools\verify-path-health.sh'),(Join-Path $kit 'tools\launch-claude-clean.sh'),(Join-Path $kit 'tools\verify-file-integrity.sh'),(Join-Path $kit 'tools\check-reference-coverage.sh') (Join-Path $proj 'tools')

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
        try {
            git init -b main | Out-Null
            if ($Type -eq 'Game') {
                if (Get-Command git-lfs -ErrorAction SilentlyContinue) {
                    git lfs install | Out-Null
                } else {
                    Write-Warning 'git-lfs not installed - install it BEFORE committing any .uasset (a binary committed without LFS is permanent repo weight).'
                }
            }
            git add -A
            git commit -m "chore: scaffold $Name from OGDK ($Type track)" | Out-Null
        } finally {
            Pop-Location
        }
    }
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
