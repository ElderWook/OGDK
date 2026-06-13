#!/usr/bin/env bash
# OGDK - scaffold a new project from the kit. Linux twin of new-project.ps1.
# Usage: ./tools/new-project.sh -n MyProject -t App|Game [-d /path/to/parent] [--no-git]
set -euo pipefail

KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME="" TYPE="" DEST="$(dirname "$KIT")" NOGIT=0

while [ $# -gt 0 ]; do
    case "$1" in
        -n|--name) NAME="$2"; shift 2 ;;
        -t|--type) TYPE="$2"; shift 2 ;;
        -d|--dest) DEST="$2"; shift 2 ;;
        --no-git)  NOGIT=1; shift ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done
[ -n "$NAME" ] || { echo "Missing -n NAME"; exit 1; }
[ "$TYPE" = "App" ] || [ "$TYPE" = "Game" ] || { echo "-t must be App or Game"; exit 1; }
PROJ="$DEST/$NAME"
[ ! -e "$PROJ" ] || { echo "Target already exists: $PROJ"; exit 1; }

if [ -z "${OGDK_BANNER:-}" ]; then
cat <<'OGDKART'
   ___   ____ ____  _  __
  / _ \ / ___|  _ \| |/ /
 | | | | |  _| | | | ' /
 | |_| | |_| | |_| | . \
  \___/ \____|____/|_|\_\
OGDKART
fi
echo "Scaffolding $TYPE project '$NAME' -> $PROJ"
mkdir -p "$PROJ"

# 1. Docs chain
cp -r "$KIT/docs-template" "$PROJ/docs"
mv "$PROJ/docs/STATUS.template.md" "$PROJ/docs/STATUS.md"
mv "$PROJ/docs/README.template.md" "$PROJ/docs/README.md"

# 2. Agent rules + Claude pointer
cp "$KIT/AGENTS.template.md" "$PROJ/AGENTS.md"
cp "$KIT/CLAUDE.template.md" "$PROJ/CLAUDE.md"

# 3. Tools (both platforms' twins travel together; list lives in PROPAGATE.list)
mkdir -p "$PROJ/tools"
while IFS= read -r tname; do
    tname="${tname%%#*}"; tname="${tname%$'\r'}"; tname="$(echo "$tname" | xargs)"  # strip CR: list may be a CRLF checkout (2026-06-11 lesson)
    [ -n "$tname" ] || continue
    cp "$KIT/tools/$tname.ps1" "$KIT/tools/$tname.sh" "$PROJ/tools/"
    if [ -f "$KIT/tools/$tname.bat" ]; then cp "$KIT/tools/$tname.bat" "$PROJ/tools/"; fi
done < "$KIT/tools/PROPAGATE.list"
cp "$KIT/tools/gate.template.ps1" "$PROJ/tools/gate.ps1"
cp "$KIT/tools/gate.template.sh"  "$PROJ/tools/gate.sh"
# 3b. Git hooks (pre-push guard)
mkdir -p "$PROJ/tools/hooks"
if [ -f "$KIT/tools/hooks/pre-push" ]; then
    cp "$KIT/tools/hooks/pre-push" "$PROJ/tools/hooks/"
fi
chmod +x "$PROJ/tools/"*.sh "$PROJ/tools/hooks/"* 2>/dev/null || true
# Provenance stamp: which kit version+commit these tools came from (drift visibility)
kitver="unknown"
if git -C "$KIT" rev-parse --short HEAD >/dev/null 2>&1; then
    kitver="$(git -C "$KIT" rev-parse --short HEAD)"
fi
kitsemver=""
if [ -f "$KIT/VERSION" ]; then
    sv="$(head -1 "$KIT/VERSION" | tr -d '[:space:]')"
    if [ -n "$sv" ]; then kitsemver="v$sv "; fi
fi
printf '%s\n' "$kitsemver$kitver $(date +%Y-%m-%d) (kit version + commit + propagation date - written by propagate-tools/new-project; do not edit)" > "$PROJ/tools/KIT-VERSION"

# 4. Skills for Claude Code
mkdir -p "$PROJ/.claude"
cp -r "$KIT/skills" "$PROJ/.claude/skills"

# 5. Track-specific
if [ "$TYPE" = "Game" ]; then
    cp "$KIT/game/gitignore.game.template"     "$PROJ/.gitignore"
    cp "$KIT/game/gitattributes.game.template" "$PROJ/.gitattributes"
    cp "$KIT/game/STACK.md" "$PROJ/docs/core/game-architecture.md"
    cp -r "$KIT/game/conventions" "$PROJ/docs/core/conventions"
else
    printf 'node_modules/\ndist/\n*.sqlite\n.env\n' > "$PROJ/.gitignore"
    printf '* text=auto\n*.sh text eol=lf\n*.ps1 text eol=crlf\n*.bat text eol=crlf\n' > "$PROJ/.gitattributes"
    cp "$KIT/app/STACK.md" "$PROJ/docs/core/app-architecture.md"
fi

# 5b. Project root README
{
    echo "# $NAME"
    echo
    echo "An Oasis Games LLC project, scaffolded from [OGDK]($KIT)."
    echo
    echo '**Start here:** [docs/00-START-HERE.md](./docs/00-START-HERE.md) - the session chain'
    echo '(AGENTS.md -> docs/STATUS.md -> active plan) for humans and AI alike.'
} > "$PROJ/README.md"

# 6. Token replacement
DATE="$(date +%F)"
find "$PROJ" -name '*.md' -type f -exec sed -i "s/{{PROJECT_NAME}}/$NAME/g; s/{{DATE}}/$DATE/g" {} +

# 7. Git
if [ "$NOGIT" -eq 0 ]; then
    if [ -z "$(git config user.email || true)" ]; then
        echo "WARNING: git identity not set - skipping git init. Init manually after setting it."
    else
        (
            cd "$PROJ"
            git init -b main >/dev/null
            if [ "$TYPE" = "Game" ]; then
                if command -v git-lfs >/dev/null; then git lfs install >/dev/null
                else echo "WARNING: git-lfs not installed - install it BEFORE committing any .uasset."; fi
            fi
            git add -A
            git commit -m "chore: scaffold $NAME from OGDK ($TYPE track)" >/dev/null
            if [ -f tools/install-hooks.sh ]; then
                bash tools/install-hooks.sh >/dev/null 2>&1 || true
            fi
        )
    fi
fi

echo
echo "Done. Next steps:"
echo "  1. Fill in AGENTS.md (architecture, invariants) + tools/gate §project checks"
if [ "$TYPE" = "Game" ]; then
    echo "  2. Create the .uproject + Source/ + Plugins/ per docs/core/game-architecture.md"
else
    echo "  2. Scaffold the app per docs/core/app-architecture.md"
fi
echo "  3. Write your first plan in docs/plans/, update docs/STATUS.md"
echo "  4. See OGDK checklists/new-project.md for the full list"
exit 0
