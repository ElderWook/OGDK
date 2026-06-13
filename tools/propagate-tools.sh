#!/usr/bin/env bash
# Propagate kit tools (and optionally skills) into EXISTING project(s).
# (Kit only - new projects get these via new-project.) Twin: propagate-tools.ps1.
#
# Usage (native shell, NEVER through a sync-layer mount - AI-PARITY.md SS4):
#   ./tools/propagate-tools.sh /path/to/project            # tools from PROPAGATE.list
#   ./tools/propagate-tools.sh /path/to/project --skills   # also sync .claude/skills
#   ./tools/propagate-tools.sh --all [--skills]            # every repo in TARGETS.list
#
# TARGETS.list (tools/TARGETS.list, GITIGNORED - project paths are personal):
# one absolute project-root path per line, '#' comments.
#
# Copies both twins per PROPAGATE.list entry, verifies each copy is non-empty and
# byte-identical (the 2026-06-11 truncated-propagation lesson), chmod +x on .sh,
# then stamps tools/KIT-VERSION in the target (kit commit + date - drift visibility).
# Never runs git in the TARGET repo (read-only rev-parse in the KIT only) -
# review and commit in each target yourself.
set -euo pipefail

KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIST="$KIT/tools/PROPAGATE.list"
TARGETS_LIST="$KIT/tools/TARGETS.list"
[ -f "$LIST" ] || { echo "Missing $LIST" >&2; exit 1; }

ALL=0
SKILLS=0
TARGET_ARG=""
for arg in "$@"; do
    case "$arg" in
        --all) ALL=1 ;;
        --skills) SKILLS=1 ;;
        *) TARGET_ARG="$arg" ;;
    esac
done

if [ -z "${OGDK_BANNER:-}" ]; then
cat <<'OGDKART'
   ___   ____ ____  _  __
  / _ \ / ___|  _ \| |/ /
 | | | | |  _| | | | ' /
 | |_| | |_| | |_| | . \
  \___/ \____|____/|_|\_\
OGDKART
fi

kitver="unknown"
if git -C "$KIT" rev-parse --short HEAD >/dev/null 2>&1; then
    kitver="$(git -C "$KIT" rev-parse --short HEAD)"
fi
kitsemver=""
if [ -f "$KIT/VERSION" ]; then
    sv="$(head -1 "$KIT/VERSION" | tr -d '[:space:]')"
    [ -n "$sv" ] && kitsemver="v$sv "
fi
stamp="$kitsemver$kitver $(date +%Y-%m-%d) (kit version + commit + propagation date - written by propagate-tools/new-project; do not edit)"

total_failed=0

propagate_one() {
    target="$1"
    target="$(cd "$target" 2>/dev/null && pwd)" || { echo "[FAIL] no such directory: $1"; total_failed=$((total_failed+1)); return; }
    [ -d "$target/tools" ] || { echo "[FAIL] $target/tools missing - is this an OGDK project root?"; total_failed=$((total_failed+1)); return; }
    [ "$target" != "$KIT" ] || { echo "[SKIP] target is the kit itself"; return; }
    echo "=== $target ==="
    copied=0; failed=0
    while IFS= read -r name; do
        name="${name%%#*}"; name="${name%$'\r'}"; name="$(echo "$name" | xargs)"  # strip CR: list may be a CRLF checkout (2026-06-11 lesson)
        [ -n "$name" ] || continue
        for ext in sh ps1; do
            src="$KIT/tools/$name.$ext"
            dst="$target/tools/$name.$ext"
            if [ ! -f "$src" ]; then
                echo "[FAIL] kit is missing $src (PROPAGATE.list stale?)"; failed=$((failed+1)); continue
            fi
            cp "$src" "$dst"
            if [ ! -s "$dst" ] || ! cmp -s "$src" "$dst"; then
                echo "[FAIL] $dst does not match source after copy (truncation?) - investigate"
                failed=$((failed+1)); continue
            fi
            [ "$ext" = "sh" ] && chmod +x "$dst"
            echo "[OK]   $name.$ext"
            copied=$((copied+1))
        done
        # Optional Windows double-click shim (e.g. checkpoint.bat) travels with its pair.
        if [ -f "$KIT/tools/$name.bat" ]; then
            cp "$KIT/tools/$name.bat" "$target/tools/$name.bat"
            echo "[OK]   $name.bat"
            copied=$((copied+1))
        fi
    done < "$LIST"
    # Copy pre-push hook (infrastructure)
    if [ -f "$KIT/tools/hooks/pre-push" ]; then
        mkdir -p "$target/tools/hooks"
        cp "$KIT/tools/hooks/pre-push" "$target/tools/hooks/pre-push"
        if [ ! -s "$target/tools/hooks/pre-push" ] || ! cmp -s "$KIT/tools/hooks/pre-push" "$target/tools/hooks/pre-push"; then
            echo "[FAIL] tools/hooks/pre-push does not match source after copy (truncation?) - investigate"
            failed=$((failed+1))
        else
            chmod +x "$target/tools/hooks/pre-push" 2>/dev/null || true
            echo "[OK]   hooks/pre-push"
            copied=$((copied+1))
        fi
    fi
    if [ "$SKILLS" = 1 ]; then
        if [ -d "$KIT/skills" ]; then
            # Per-skill replace: remove the existing entry (file OR folder - old
            # flat layouts left leaf files that break a blind recursive copy),
            # then copy fresh. Entries the kit does not know are kept but flagged.
            mkdir -p "$target/.claude/skills"
            for sd in "$KIT/skills"/*/; do
                [ -d "$sd" ] || continue
                sname="$(basename "$sd")"
                rm -rf "$target/.claude/skills/$sname"
                cp -r "$sd" "$target/.claude/skills/$sname"
            done
            for e in "$target/.claude/skills"/* "$target/.claude/skills"/.[!.]*; do
                [ -e "$e" ] || continue
                ename="$(basename "$e")"
                [ -d "$KIT/skills/$ename" ] || echo "[WARN] unknown entry in .claude/skills (not from kit - relic or custom? delete by hand if relic): $ename"
            done
            echo "[OK]   skills/ -> .claude/skills/ (per-skill replace)"
        else
            echo "[FAIL] kit skills/ missing"; failed=$((failed+1))
        fi
    fi
    printf '%s\n' "$stamp" > "$target/tools/KIT-VERSION"
    echo "[OK]   KIT-VERSION stamped ($kitver)"
    echo "Propagated $copied file(s); $failed failure(s)."
    total_failed=$((total_failed+failed))
}

if [ "$ALL" = 1 ]; then
    [ -f "$TARGETS_LIST" ] || { echo "Missing $TARGETS_LIST - create it (gitignored): one project root per line." >&2; exit 1; }
    found=0
    while IFS= read -r t; do
        t="${t%%#*}"; t="${t%$'\r'}"; t="$(echo "$t" | xargs)"  # strip CR (CRLF checkout)
        [ -n "$t" ] || continue
        found=$((found+1))
        propagate_one "$t"
    done < "$TARGETS_LIST"
    [ "$found" -gt 0 ] || { echo "TARGETS.list has no entries." >&2; exit 1; }
else
    [ -n "$TARGET_ARG" ] || { echo "Usage: $0 /path/to/project [--skills] | --all [--skills]" >&2; exit 1; }
    propagate_one "$TARGET_ARG"
fi

echo "--------------------------------------"
if [ "$total_failed" -gt 0 ]; then
    echo "$total_failed FAILURE(S) - fix before committing in the target repo(s)."
    exit 1
fi
echo "Next, IN EACH TARGET REPO: run its gate, review the diff, commit"
echo "  (suggested msg: 'chore: propagate kit tools - <names>')."
exit 0
