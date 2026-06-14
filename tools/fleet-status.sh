#!/usr/bin/env bash
# OGDK - fleet status. READ-ONLY multi-repo health sweep: for the kit and every repo in
# tools/TARGETS.list, fetch and report branch / ahead / behind / dirty / stash / state /
# KIT-VERSION in one table. This is the C0 multi-repo ARRIVE check of the git lifecycle
# (docs-template/workflow/GIT-LIFECYCLE.md) - run it before a propagation session so you
# never propagate onto a stale or tangled base. A leading '*' marks any repo that needs
# attention (not clean / not in sync / mid-operation / no upstream).
#
# Changes NOTHING: 'git fetch' only updates remote-tracking refs; everything else is a read.
# Run it in a NATIVE shell (it runs git) - a synced-mount agent narrates it for the human.
# Twin: fleet-status.ps1 (keep behavior identical - see tools/README.md).
#
# Usage: ./tools/fleet-status.sh
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
echo "  Fleet Status - read-only (OGDK)     "
echo "======================================"

report_repo() { # $1 = repo dir, $2 = label
    d="$1"; label="$2"
    if [ ! -d "$d/.git" ]; then
        printf '%1s %-15s %s\n' ' ' "$label" "(not a git repo / missing)"
        return
    fi
    (
        cd "$d" 2>/dev/null || { printf '%1s %-15s %s\n' ' ' "$label" "(unreadable)"; exit 0; }
        git fetch -q --all 2>/dev/null
        # symbolic-ref gives the branch name even on an unborn HEAD (no fatal noise);
        # fall back to a short hash for detached HEAD, '?' only if truly indeterminate.
        br="$(git symbolic-ref --short -q HEAD 2>/dev/null || true)"
        [ -n "$br" ] || br="$(git rev-parse --short HEAD 2>/dev/null || echo '?')"
        if git rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1; then
            c="$(git rev-list --left-right --count 'HEAD...@{upstream}' 2>/dev/null || echo '0	0')"
            ahead="$(printf '%s' "$c" | awk '{print $1}')"
            behind="$(printf '%s' "$c" | awk '{print $2}')"
        else
            ahead='?'; behind='noUP'
        fi
        dirty="$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
        stash="$(git stash list 2>/dev/null | wc -l | tr -d ' ')"
        gd="$(git rev-parse --git-dir 2>/dev/null)"
        state='ok'
        [ -f "$gd/MERGE_HEAD" ] && state='MERGING'
        { [ -d "$gd/rebase-merge" ] || [ -d "$gd/rebase-apply" ]; } && state='REBASING'
        kv="$(head -1 tools/KIT-VERSION 2>/dev/null || echo '-')"
        kv="${kv%% (*}"   # drop the "(kit version + commit ...; do not edit)" annotation

        att=0
        [ "$state" != ok ] && att=1
        [ "$dirty" != 0 ] && att=1
        case "$ahead"  in ''|*[!0-9]*) : ;; *) [ "$ahead"  -gt 0 ] && att=1 ;; esac
        case "$behind" in noUP) att=1 ;; ''|*[!0-9]*) : ;; *) [ "$behind" -gt 0 ] && att=1 ;; esac
        mark=' '; [ "$att" = 1 ] && mark='*'

        printf '%1s %-15s %-7s %5s %6s %5s %5s  %-9s %s\n' \
            "$mark" "$label" "$br" "$ahead" "$behind" "$dirty" "$stash" "$state" "$kv"
    )
}

printf '%1s %-15s %-7s %5s %6s %5s %5s  %-9s %s\n' ' ' REPO BRANCH AHEAD BEHIND DIRTY STASH STATE KIT-VERSION
echo "------------------------------------------------------------------------------"

report_repo "$KIT" "$(basename "$KIT") (kit)"

if [ -f "$TARGETS" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        line="${line%$'\r'}"
        t="$(printf '%s' "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
        case "$t" in ''|'#'*) continue ;; esac
        report_repo "$t" "$(basename "$t")"
    done < "$TARGETS"
else
    echo "  (no tools/TARGETS.list - add one project root per line to sweep your fleet)"
fi

echo "------------------------------------------------------------------------------"
echo "  Read-only: nothing changed. '*' = needs attention - resolve via the"
echo "  GIT-LIFECYCLE.md sub-flows (S1-S6) BEFORE propagating."
exit 0
# EOF
