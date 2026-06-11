#!/usr/bin/env bash
# Environment health check (OGDK) - Linux twin of verify-path-health.ps1
# The Windows script guards against MSYS2/WSL PATH poisoning. On Linux the
# equivalent hazard is the reverse: writing to a shared NTFS partition from
# Linux. Run at the START of every AI agent session.
set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
issues=0
pass() { printf '[PASS] %s\n' "$1"; }
warn() { printf '[WARN] %s\n' "$1"; }
fail() { printf '[FAIL] %s\n' "$1"; issues=$((issues+1)); }

echo "======================================"
echo "  Environment Health Check (OGDK)     "
echo "======================================"
echo

# Check 1: repo filesystem - NTFS from Linux is the dual-boot corruption hazard
fstype="$(stat -f -c %T "$REPO_ROOT" 2>/dev/null || echo unknown)"
case "$fstype" in
    ntfs|fuseblk|ntfs3)
        fail "Repo is on an NTFS mount ($fstype). Do NOT run agent file writes here from Linux - work on a native (ext4/btrfs) clone and sync via git push/pull." ;;
    unknown)
        warn "Could not determine filesystem type for $REPO_ROOT" ;;
    *)
        pass "Repo filesystem: $fstype (native)" ;;
esac

# Check 2: git present + identity
if ! command -v git >/dev/null; then
    fail "git not found in PATH"
else
    pass "git -> $(command -v git)"
    if [ -z "$(git config user.email || true)" ]; then
        fail "git identity not set (git config --global user.name / user.email)"
    else
        pass "git identity: $(git config user.email)"
    fi
fi

# Check 3: git-lfs (required for game-track repos)
if command -v git-lfs >/dev/null; then
    pass "git-lfs -> $(command -v git-lfs)"
else
    warn "git-lfs not installed (required before committing any .uasset in game repos). Arch: sudo pacman -S git-lfs && git lfs install"
fi

# Check 4: line-ending config - on Linux, autocrlf must NOT be true
autocrlf="$(git config core.autocrlf || echo unset)"
if [ "$autocrlf" = "true" ]; then
    fail "core.autocrlf=true on Linux will mangle files. Use: git config --global core.autocrlf input (line-ending policy belongs in .gitattributes anyway)"
else
    pass "core.autocrlf: $autocrlf"
fi

# Check 5: node (app track only)
if command -v node >/dev/null; then
    pass "node -> $(command -v node) ($(node --version))"
else
    warn "node not found (only matters for app-track projects)"
fi

echo
echo "--------------------------------------"
if [ "$issues" -eq 0 ]; then
    echo "  ALL CHECKS PASSED - safe to run AI agents"
else
    echo "  $issues ISSUE(S) FOUND - resolve before running AI agents"
fi
echo "--------------------------------------"
exit "$issues"
