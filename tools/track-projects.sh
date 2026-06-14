#!/usr/bin/env bash
# OGDK - track-projects. Register OGDK projects into the kit's gitignored tools/TARGETS.list
# so fleet-status and propagate-tools --all pick them up. An OGDK project = a git repo that
# carries tools/KIT-VERSION (stamped by new-project / propagate-tools). The kit itself has no
# KIT-VERSION, so it is never added. Idempotent: an entry is never duplicated.
#
# This is how a project cloned on ANOTHER machine gets tracked: TARGETS.list is per-machine
# and gitignored, so each machine maintains its own. Clone your projects, then run this once.
# (new-project already auto-registers projects on the machine that scaffolds them.)
#
#   ./tools/track-projects.sh                  # scan the kit's parent dir, register all found
#   ./tools/track-projects.sh --scan <dir>     # scan a specific directory's immediate children
#   ./tools/track-projects.sh <path> [<path>]  # register specific project root(s)
#
# Only writes tools/TARGETS.list (a local, gitignored file). Kit-only (not propagated).
# Twin: track-projects.ps1 (keep behavior identical - see tools/README.md).
set -u
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGETS="$KIT/tools/TARGETS.list"

if [ -z "${OGDK_BANNER:-}" ]; then
cat <<'OGDKART'
   ___   ____ ____  _  __
  / _ \ / ___|  _ \| |/ /
 | | | | |  _| | | | ' /
 | |_| | |_| | |_| | . \
  \___/ \____|____/|_|\_\
OGDKART
fi
echo "======================================"
echo "  Track Projects - fleet registry     "
echo "======================================"

is_ogdk_project() { [ -d "$1/.git" ] && [ -f "$1/tools/KIT-VERSION" ]; }
already_tracked() { [ -f "$TARGETS" ] && grep -Fxq "$1" "$TARGETS"; }

added=0
register() { # $1 = absolute project root
    if already_tracked "$1"; then
        echo "  = already tracked: $1"
    else
        printf '%s\n' "$1" >> "$TARGETS"
        echo "  + registered:      $1"
        added=$((added+1))
    fi
}

mode_scan=1
scan_root="$(dirname "$KIT")"
explicit=""
while [ "$#" -gt 0 ]; do
    case "$1" in
        --scan) scan_root="${2:-}"; shift 2 ;;
        -h|--help)
            echo "usage: track-projects.sh [--scan <dir>] | [<project-path> ...]"
            exit 0 ;;
        *) explicit="$explicit
$1"; mode_scan=0; shift ;;
    esac
done

if [ "$mode_scan" -eq 1 ]; then
    echo "Scanning $scan_root for OGDK projects (git repo + tools/KIT-VERSION)..."
    found=0
    for d in "$scan_root"/*/; do
        [ -d "$d" ] || continue
        d="${d%/}"
        if is_ogdk_project "$d"; then
            found=$((found+1))
            register "$(cd "$d" && pwd)"
        fi
    done
    [ "$found" -eq 0 ] && echo "  (no OGDK projects found under $scan_root)"
else
    oldifs="$IFS"; IFS='
'
    for p in $explicit; do
        [ -n "$p" ] || continue
        if [ ! -d "$p" ]; then echo "  ! not found:       $p"; continue; fi
        abs="$(cd "$p" && pwd)"
        if is_ogdk_project "$abs"; then
            register "$abs"
        else
            echo "  ! not an OGDK project (no .git or tools/KIT-VERSION): $abs"
        fi
    done
    IFS="$oldifs"
fi

echo "--------------------------------------"
echo "  $added newly registered. tools/TARGETS.list now drives fleet-status +"
echo "  propagate-tools --all. Run ./tools/fleet-status.sh to see the fleet."
exit 0
# EOF
