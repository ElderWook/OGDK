#!/usr/bin/env bash
# OGDK - scaffold a new project from the kit. Linux twin of new-project.ps1.
# Usage: ./tools/new-project.sh -n MyProject -t App|Game [-d /path/to/parent] [--no-git]
set -euo pipefail

KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME="" TYPE="" DEST="$(dirname "$KIT")" NOGIT=0 FEATURES="" PRESET=""

while [ $# -gt 0 ]; do
    case "$1" in
        -n|--name)     NAME="$2"; shift 2 ;;
        -t|--type)     TYPE="$2"; shift 2 ;;
        -d|--dest)     DEST="$2"; shift 2 ;;
        -f|--features) FEATURES="$2"; shift 2 ;;
        -p|--preset)   PRESET="$2"; shift 2 ;;
        --no-git)      NOGIT=1; shift ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

# Preset name (A-E) -> module set. core + app are added later as the always-present law.
expand_preset() {
    case "$(printf '%s' "$1" | tr '[:lower:]' '[:upper:]')" in
        A) printf 'core,store,sync,bridge,render' ;;
        B) printf 'core,store,api,adapters,jobs' ;;
        C) printf 'core' ;;
        D) printf 'core,store' ;;
        E) printf 'core,store,render' ;;
        *) printf '' ;;
    esac
}

# One annotated placeholder dir per chosen module. Language code is GENERATED later by
# the agent per CODE-CONVENTIONS - the kit never stores boilerplate that would rot.
write_module() {
    _m="$1"; _intent="$2"; _boundary="$3"
    mkdir -p "$PROJ/src/$_m"
    {
        printf '# %s/ - structural placeholder (generate the real module here)\n\n' "$_m"
        printf '@intent %s\n' "$_intent"
        printf '@boundary %s\n' "$_boundary"
        printf '\n'
        printf '> This directory marks a module the app needs. Generate its implementation\n'
        printf '> in your chosen language per docs/core/app-architecture.md and the kit\n'
        printf '> CODE-CONVENTIONS: an annotated header, a mirrored test, gate green BEFORE\n'
        printf '> any feature code. Delete this placeholder once the module + its test exist.\n'
    } > "$PROJ/src/$_m/_MODULE.md"
}
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
# Feature resolution (App track only): -p/--preset expands to a module set; -f/--features
# is an explicit csv; with neither, an interactive terminal gets a one-question wizard.
# Non-interactive with no flags = no modules (today's behavior - a clean blank slate).
if [ "$TYPE" = "App" ]; then
    if [ -z "$FEATURES" ] && [ -n "$PRESET" ]; then
        FEATURES="$(expand_preset "$PRESET")"
        [ -n "$FEATURES" ] || { echo "Unknown preset '$PRESET' (use A-E)"; exit 1; }
    fi
    if [ -z "$FEATURES" ] && [ -z "$PRESET" ] && [ -t 0 ]; then
        echo "Pick a starting shape for your app (you can change it later):"
        echo "  A) local-first, multi-device      (core + store + sync + bridge + render)"
        echo "  B) web service / API              (core + store + api + adapters + jobs)"
        echo "  C) command-line tool              (core)"
        echo "  D) simple web app                 (core + store)"
        echo "  E) single desktop app  [default]  (core + store + render)"
        printf 'Your choice [E]: '
        read -r choice || true
        [ -n "${choice:-}" ] || choice="E"
        FEATURES="$(expand_preset "$choice")"
        [ -n "$FEATURES" ] || { echo "Unknown choice '$choice' (use A-E)"; exit 1; }
    fi
elif [ -n "$FEATURES" ] || [ -n "$PRESET" ]; then
    echo "[note] -Features/-Preset apply to the App track only; ignoring for a Game project."
    FEATURES=""
fi

echo "Scaffolding $TYPE project '$NAME' -> $PROJ"
mkdir -p "$PROJ"

# 1. Docs chain
cp -r "$KIT/docs-template" "$PROJ/docs"
mv "$PROJ/docs/STATUS.template.md" "$PROJ/docs/STATUS.md"
mv "$PROJ/docs/README.template.md" "$PROJ/docs/README.md"

# 2. Agent rules + Claude pointer + Changelog
cp "$KIT/AGENTS.template.md" "$PROJ/AGENTS.md"
cp "$KIT/CLAUDE.template.md" "$PROJ/CLAUDE.md"
cp "$KIT/CHANGELOG.template.md" "$PROJ/CHANGELOG.md"

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
# 3b. Git hooks (pre-push and pre-commit guards)
mkdir -p "$PROJ/tools/hooks"
for hook in pre-push pre-commit; do
    if [ -f "$KIT/tools/hooks/$hook" ]; then
        cp "$KIT/tools/hooks/$hook" "$PROJ/tools/hooks/"
    fi
done
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

# 5c. Feature modules (App track): one annotated placeholder dir per chosen module.
if [ "$TYPE" = "App" ] && [ -n "$FEATURES" ]; then
    mkdir -p "$PROJ/src"
    seen=","
    for m in core app $(printf '%s' "$FEATURES" | tr ',' ' '); do
        m="$(printf '%s' "$m" | xargs)"; [ -n "$m" ] || continue
        case "$seen" in *",$m,"*) continue ;; esac
        seen="$seen$m,"
        case "$m" in
            core)     write_module core     "pure domain logic, exact math, validation" "depends on nothing; every other module points here" ;;
            app)      write_module app      "composition root - wiring ONLY, one per surface" "may import any module; nothing imports it" ;;
            store)    write_module store    "durable atomic persistence + migrations" "core has no direct access to the store" ;;
            sync)     write_module sync     "multi-device replication + authority model" "decide conflict/authority policy day one; parity tests mandatory" ;;
            bridge)   write_module bridge   "per-platform injection (the platform-bridge pattern)" "platform code calls pure core through interfaces only" ;;
            render)   write_module render   "documents and exports" "keep themes separate from generation primitives" ;;
            jobs)     write_module jobs     "background work queue + status" "runs async; never blocks the main path" ;;
            identity) write_module identity "sessions, permissions, third-party identity" "buy-don't-build the crypto/protocol" ;;
            adapters) write_module adapters "one folder per external service" "zero inline integration calls inside core" ;;
            api)      write_module api      "versioned external surface" "API versioning decoupled from core changes" ;;
            *)        write_module "$m"     "custom module" "declare its boundary before writing code" ;;
        esac
    done
    echo "  src/ modules: $(printf '%s' "$seen" | sed -e 's/^,//' -e 's/,$//')"
fi

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

# 8. Register this project in the kit's fleet list (gitignored tools/TARGETS.list, per-machine)
#    so fleet-status and propagate-tools --all pick it up automatically. Idempotent.
TARGETS_LIST="$KIT/tools/TARGETS.list"
proj_abs="$(cd "$PROJ" 2>/dev/null && pwd || printf '%s' "$PROJ")"
if [ -f "$TARGETS_LIST" ] && grep -Fxq "$proj_abs" "$TARGETS_LIST"; then
    :
else
    printf '%s\n' "$proj_abs" >> "$TARGETS_LIST"
    echo "[INFO] registered in tools/TARGETS.list (fleet tracking): $proj_abs"
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
if [ "$TYPE" = "App" ] && [ -n "$FEATURES" ]; then
    echo "  * src/ has annotated module placeholders - ask your agent to generate each"
    echo "    one (real code + a mirrored test), gate green before any feature work."
fi
exit 0
