#!/usr/bin/env bash
# Kit docs self-check (OGDK only - not propagated to projects).
# Mechanically enforces:
#   1. Twin rule: every tools/*.ps1 has a *.sh twin and vice versa
#   2. user-notes.md mentions every tools script (the crib sheet cannot go stale)
#   3. tools/README.md mentions every tools script
#   4. user-notes/README do not mention scripts that no longer exist
#   5. .ps1 hygiene: ASCII only, no here-strings (PS 5.1 + LF parse-bomb lesson)
#   6. no hardcoded user paths in tools/ (the launch-claude-clean lesson)
#   7. relative links in non-template .md files resolve (AGENTS gate, now mechanical)
#   8. no private markers (tools/PRIVATE-MARKERS.list, gitignored, per-owner)
# Build commands cannot be checked mechanically - process rule in AGENTS.md covers them.
# Twin: check-kit-docs.ps1.
set -u
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$KIT"
issues=0
pass() { printf '[PASS] %s\n' "$1"; }
warn() { printf '[WARN] %s\n' "$1"; }
fail() { printf '[FAIL] %s\n' "$1"; issues=$((issues+1)); }

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
echo "  Kit Docs Self-Check (OGDK)          "
echo "======================================"

# 1. Twin rule
twin_ok=1
for f in tools/*.ps1; do
    b="$(basename "$f" .ps1)"
    [ -f "tools/$b.sh" ] || { fail "twin missing: $f has no tools/$b.sh"; twin_ok=0; }
done
for f in tools/*.sh; do
    b="$(basename "$f" .sh)"
    [ -f "tools/$b.ps1" ] || { fail "twin missing: $f has no tools/$b.ps1"; twin_ok=0; }
done
[ "$twin_ok" = 1 ] && pass "twin rule: every script has its pair"

# 2+3. every script mentioned in user-notes.md and tools/README.md
for doc in user-notes.md tools/README.md; do
    doc_ok=1
    for f in tools/*.ps1; do
        b="$(basename "$f" .ps1)"
        grep -q "$b" "$doc" || { fail "$doc does not mention script '$b'"; doc_ok=0; }
    done
    [ "$doc_ok" = 1 ] && pass "$doc covers all tools scripts"
done

# 4. mentioned-but-deleted scripts (scan doc for tool-like names not on disk)
#    - docs AND skills (skills name scripts too; a renamed tool must not leave
#    skills pointing at a ghost)
ghost_ok=1
ghost_docs="user-notes.md tools/README.md"
if [ -d skills ]; then
    ghost_docs="$ghost_docs $(find skills -name 'SKILL.md' -type f | sort)"
fi
for doc in $ghost_docs; do
    for name in $(grep -oE '[a-z][a-z0-9-]+\.(ps1|sh)' "$doc" | sort -u); do
        base="${name%.*}"
        if [ ! -f "tools/${base}.ps1" ] && [ ! -f "tools/${base}.sh" ]; then
            warn "$doc mentions '$name' which does not exist in tools/ (removed? update the doc)"
            ghost_ok=0
        fi
    done
done
[ "$ghost_ok" = 1 ] && pass "no ghost script references in docs"

# 5. .ps1 hygiene: ASCII only + no here-strings (Windows PowerShell 5.1 with LF endings)
ps_ok=1
for f in tools/*.ps1; do
    if LC_ALL=C grep -qP '[^\x00-\x7F]' "$f"; then
        fail "non-ASCII byte(s) in $f - PS 5.1 hazard (tools/README.md rule 2)"; ps_ok=0
    fi
    if grep -qE "@[\"']" "$f"; then
        fail "here-string in $f - breaks PS 5.1 parsing with LF endings"; ps_ok=0
    fi
done
[ "$ps_ok" = 1 ] && pass ".ps1 hygiene: ASCII-only, no here-strings"

# 6. hardcoded user paths in tools/ (kit must work on ANY machine)
hard_ok=1
hardpat='C:\\Users\\[A-Za-z]|/home/[a-z]|/Users/[A-Za-z]'
for f in tools/*; do
    [ -f "$f" ] || continue
    hits="$(grep -nE "$hardpat" "$f" 2>/dev/null || true)"
    if [ -n "$hits" ]; then
        fail "hardcoded user path in $f:"
        printf '%s\n' "$hits" | sed 's/^/  /'
        hard_ok=0
    fi
done
[ "$hard_ok" = 1 ] && pass "no hardcoded user paths in tools/"

# 7. relative markdown links resolve (non-template .md only; templates resolve
#    post-scaffold and are excluded - verified by the scaffold throwaway test)
link_ok=1
while IFS= read -r f; do
    dir="$(dirname "$f")"
    for link in $(grep -oE '\]\([^)]+\)' "$f" 2>/dev/null | sed -e 's/^](//' -e 's/)$//' | sort -u); do
        case "$link" in
            http://*|https://*|mailto:*|\#*) continue ;;
        esac
        target="${link%%#*}"
        [ -n "$target" ] || continue
        # skip non-path artifacts (e.g. the literal "](...)" examples in prose)
        printf '%s' "$target" | grep -q '[A-Za-z0-9]' || continue
        [ -e "$dir/$target" ] || { fail "$f: broken relative link -> $link"; link_ok=0; }
    done
done < <(find . -name '*.md' -type f \
            ! -path './.git/*' ! -path './docs-template/*' ! -name '*template*' | sed 's|^\./||')
[ "$link_ok" = 1 ] && pass "all relative links in non-template .md files resolve"

# 8. private markers (tools/PRIVATE-MARKERS.list - gitignored, per-owner).
#    Reports marker INDEX only, never the marker text, so output stays shareable.
markfile="tools/PRIVATE-MARKERS.list"
if [ -f "$markfile" ]; then
    mark_ok=1
    midx=0
    while IFS= read -r m || [ -n "$m" ]; do
        m="$(printf '%s' "$m" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
        case "$m" in ''|'#'*) continue ;; esac
        midx=$((midx+1))
        hits="$(grep -rliIF --exclude-dir=.git \
                  --exclude='user-notes.local.md' --exclude='PRIVATE-MARKERS.list' \
                  --exclude='TARGETS.list' \
                  -- "$m" . 2>/dev/null || true)"
        if [ -n "$hits" ]; then
            fail "private marker #$midx found in: (text withheld - marker #$midx in your PRIVATE-MARKERS.list)"
            printf '%s\n' "$hits" | sed -e 's|^\./||' -e 's/^/  /'
            mark_ok=0
        fi
    done < "$markfile"
    [ "$mark_ok" = 1 ] && pass "no private markers in scanned files ($midx marker(s) checked)"
else
    warn "tools/PRIVATE-MARKERS.list not found - private-marker scan skipped (seed yours: see tools/README.md)"
fi

# 9. learning-loop nudge: OPEN lessons in the kit's LESSONS.md (kit-retro trigger)
if [ -f "LESSONS.md" ]; then
    open_lessons=$(grep -c 'Status:.*OPEN' LESSONS.md 2>/dev/null || true)  # no '|| echo 0': grep -c prints 0 AND exits 1 on no match (2026-06-11 lesson)
    open_lessons=${open_lessons:-0}
    if [ "$open_lessons" -ge 5 ]; then
        warn "$open_lessons OPEN lesson(s) in LESSONS.md - run the kit-retro skill (threshold: 5)"
    elif [ "$open_lessons" -gt 0 ]; then
        printf '[INFO] %s OPEN lesson(s) in LESSONS.md (kit-retro at 5)\n' "$open_lessons"
    fi
fi

echo "--------------------------------------"
if [ "$issues" -eq 0 ]; then
    echo "  KIT DOCS OK"
else
    echo "  $issues ISSUE(S) - update user-notes.md / tools/README.md in this commit"
fi
exit "$issues"
