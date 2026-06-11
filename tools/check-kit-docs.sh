#!/usr/bin/env bash
# Kit docs self-check (OGDK only - not propagated to projects).
# Mechanically enforces:
#   1. Twin rule: every tools/*.ps1 has a *.sh twin and vice versa
#   2. user-notes.md mentions every tools script (the crib sheet cannot go stale)
#   3. tools/README.md mentions every tools script
#   4. user-notes/README do not mention scripts that no longer exist
# Build commands cannot be checked mechanically - process rule in AGENTS.md covers them.
# Twin: check-kit-docs.ps1.
set -u
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$KIT"
issues=0
pass() { printf '[PASS] %s\n' "$1"; }
warn() { printf '[WARN] %s\n' "$1"; }
fail() { printf '[FAIL] %s\n' "$1"; issues=$((issues+1)); }

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
ghost_ok=1
for doc in user-notes.md tools/README.md; do
    for name in $(grep -oE '[a-z][a-z0-9-]+\.(ps1|sh)' "$doc" | sort -u); do
        base="${name%.*}"
        if [ ! -f "tools/${base}.ps1" ] && [ ! -f "tools/${base}.sh" ]; then
            warn "$doc mentions '$name' which does not exist in tools/ (removed? update the doc)"
            ghost_ok=0
        fi
    done
done
[ "$ghost_ok" = 1 ] && pass "no ghost script references in docs"

echo "--------------------------------------"
if [ "$issues" -eq 0 ]; then
    echo "  KIT DOCS OK"
else
    echo "  $issues ISSUE(S) - update user-notes.md / tools/README.md in this commit"
fi
exit "$issues"
