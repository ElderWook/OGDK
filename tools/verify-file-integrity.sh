#!/usr/bin/env bash
# File integrity check (OGDK) - detects the corruption signatures we have actually seen:
#   1. NUL bytes inside tracked text files  (MSYS2/NTFS zero-filled-tail corruption)
#   2. Truncated source files               (sync-layer truncation; .py checked by compile)
#   3. Git object-store corruption          (git fsck)
# Run BEFORE committing after heavy agent writes, and any time files look suspicious.
# Twin: verify-file-integrity.ps1 (keep behavior identical - see tools/README.md).
set -u
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"
issues=0
pass() { printf '[PASS] %s\n' "$1"; }
warn() { printf '[WARN] %s\n' "$1"; }
fail() { printf '[FAIL] %s\n' "$1"; issues=$((issues+1)); }

echo "======================================"
echo "  File Integrity Check (OGDK)         "
echo "======================================"

# Check 1: git object store
if [ -d .git ]; then
    if git fsck --no-progress >/dev/null 2>&1; then
        pass "git fsck: object store healthy"
    else
        fail "git fsck reports corruption - do NOT commit; investigate .git"
    fi
else
    warn "not a git repo - skipping fsck"
fi

# Check 2: NUL bytes in tracked text files (zero-filled tails)
TEXT_RE='\.(md|txt|py|js|ts|jsx|tsx|json|ps1|sh|bat|cs|cpp|c|h|hpp|ini|yml|yaml|toml|svelte|dart|cjs|mjs|html|css|xml|sql|uproject|uplugin|gitignore|gitattributes)$'
nul_hits=""
while IFS= read -r f; do
    [ -f "$f" ] || continue
    if LC_ALL=C grep -qaP '\x00' "$f" 2>/dev/null; then
        nul_hits="$nul_hits  $f"$'\n'
    fi
done < <(git ls-files 2>/dev/null | grep -E "$TEXT_RE" || true)
if [ -n "$nul_hits" ]; then
    fail "NUL bytes found in text files (zero-fill corruption signature):"
    printf '%s' "$nul_hits"
else
    pass "no NUL bytes in tracked text files"
fi

# Check 3: Python files compile (catches mid-file truncation of .py)
py_bad=""
if command -v python3 >/dev/null; then
    while IFS= read -r f; do
        [ -f "$f" ] || continue
        python3 -m py_compile "$f" 2>/dev/null || py_bad="$py_bad  $f"$'\n'
    done < <(git ls-files '*.py' 2>/dev/null || true)
    if [ -n "$py_bad" ]; then
        fail "Python files do not compile (possible truncation):"
        printf '%s' "$py_bad"
    else
        pass "all tracked .py files compile"
    fi
fi

# Check 4: tracked text files ending mid-line (no trailing newline = truncation smell)
noeol=""
while IFS= read -r f; do
    [ -f "$f" ] && [ -s "$f" ] || continue
    [ "$(tail -c 1 "$f" | od -An -tx1 | tr -d ' \n')" != "0a" ] && noeol="$noeol  $f"$'\n'
done < <(git ls-files 2>/dev/null | grep -E '\.(py|sh|md)$' || true)
if [ -n "$noeol" ]; then
    warn "files lacking trailing newline (verify they are complete):"
    printf '%s' "$noeol"
else
    pass "all checked files end with newline"
fi

echo "--------------------------------------"
if [ "$issues" -eq 0 ]; then
    echo "  INTEGRITY OK - safe to commit"
else
    echo "  $issues ISSUE(S) - do NOT commit until resolved"
fi
exit "$issues"
