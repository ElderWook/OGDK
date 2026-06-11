#!/usr/bin/env bash
# Propagate kit tools (and optionally skills) into an EXISTING project.
# (Kit only - new projects get these via new-project.) Twin: propagate-tools.ps1.
#
# Usage (native shell, NEVER through a sync-layer mount - AI-PARITY.md SS4):
#   ./tools/propagate-tools.sh /path/to/project            # tools from PROPAGATE.list
#   ./tools/propagate-tools.sh /path/to/project --skills   # also sync .claude/skills
#
# Copies both twins per PROPAGATE.list entry, verifies each copy is non-empty and
# byte-identical (the 2026-06-11 truncated-propagation lesson), chmod +x on .sh.
# Does NOT run git anywhere - review and commit in the target repo yourself.
set -euo pipefail

KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIST="$KIT/tools/PROPAGATE.list"
TARGET="${1:-}"
SKILLS=0
[ "${2:-}" = "--skills" ] && SKILLS=1

[ -n "$TARGET" ] || { echo "Usage: $0 /path/to/project [--skills]" >&2; exit 1; }
TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" || { echo "No such directory: ${1}" >&2; exit 1; }
[ -d "$TARGET/tools" ] || { echo "$TARGET/tools missing - is this an OGDK project root?" >&2; exit 1; }
[ -f "$LIST" ] || { echo "Missing $LIST" >&2; exit 1; }
[ "$TARGET" != "$KIT" ] || { echo "Target is the kit itself - nothing to do" >&2; exit 1; }

copied=0; failed=0
while IFS= read -r name; do
    name="${name%%#*}"; name="$(echo "$name" | xargs)"
    [ -n "$name" ] || continue
    for ext in sh ps1; do
        src="$KIT/tools/$name.$ext"
        dst="$TARGET/tools/$name.$ext"
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
done < "$LIST"

if [ "$SKILLS" = 1 ]; then
    if [ -d "$KIT/skills" ]; then
        mkdir -p "$TARGET/.claude"
        cp -r "$KIT/skills/." "$TARGET/.claude/skills/"
        echo "[OK]   skills/ -> .claude/skills/"
    else
        echo "[FAIL] kit skills/ missing"; failed=$((failed+1))
    fi
fi

echo "--------------------------------------"
echo "Propagated $copied file(s) to $TARGET$( [ $SKILLS = 1 ] && echo ' (+skills)')."
if [ "$failed" -gt 0 ]; then
    echo "$failed FAILURE(S) - fix before committing in the target repo."
    exit 1
fi
echo "Next, IN THE TARGET REPO: run its gate, review the diff, commit"
echo "  (suggested msg: 'chore: propagate kit tools - <names>')."
