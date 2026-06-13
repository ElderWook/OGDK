#!/usr/bin/env bash
# OGDK - run the hostile environment test suite. Linux twin of test-hostile-env.ps1.
# Ensures that verify-path-health, gate, and new-project work under adverse conditions.
set -euo pipefail

KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
issues=0

fail() { echo "[FAIL] $1"; issues=$((issues+1)); }
pass() { echo "[PASS] $1"; }

echo "======================================"
echo "  Hostile Environment Smoke Test      "
echo "======================================"

# Create sandboxed dir with spaces
TEST_DIR="$KIT/sandbox hostile spaces dir"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"

# Clean git config variables
export GIT_CONFIG_GLOBAL="$TEST_DIR/gitconfig"
export GIT_CONFIG_NOSYSTEM=1

# 1. Test clone & run health check with NO git config set
(
    cd "$TEST_DIR"
    git clone "$KIT" OGDK >/dev/null 2>&1 || true
    cd OGDK
    # Should FAIL because no identity is set
    if ./tools/verify-path-health.sh >/dev/null 2>&1; then
        fail "verify-path-health passed when git identity was not set"
    else
        pass "verify-path-health correctly fails when git identity is missing"
    fi
)

# 2. Test path-health and project creation with git config set
(
    cd "$TEST_DIR/OGDK"
    git config --global user.name "Test Friend"
    git config --global user.email "123+friend@users.noreply.github.com"
    
    if ./tools/verify-path-health.sh >/dev/null 2>&1; then
        pass "verify-path-health passes after setting identity"
    else
        fail "verify-path-health failed after setting identity"
    fi
    
    # Run gate check on kit
    if ./tools/gate.sh >/dev/null 2>&1; then
        pass "kit gate.sh passes inside sandbox with spaces"
    else
        fail "kit gate.sh fails inside sandbox with spaces"
    fi
    
    # Scaffold a new project
    if ./tools/new-project.sh -n TestProj -t App -d "$TEST_DIR" >/dev/null 2>&1; then
        pass "new-project.sh successfully scaffolds App in spaces-in-path directory"
    else
        fail "new-project.sh fails scaffolding in spaces-in-path directory"
    fi
    
    # Verify scaffolded gate passes
    cd "$TEST_DIR/TestProj"
    if ./tools/gate.sh >/dev/null 2>&1; then
        pass "scaffolded project gate passes successfully"
    else
        fail "scaffolded project gate fails to pass"
    fi
)

# 3. Identity-leak guard: check-git-identity must FAIL on a leaked author identity
#    in history and PASS when no marker matches. (Requires the new files to be
#    committed first - the sandbox is a fresh clone, which only carries tracked files.)
(
    cd "$TEST_DIR/OGDK"
    if [ -f ./tools/check-git-identity.sh ]; then
        printf 'leaktoken9000\n' > tools/PRIVATE-MARKERS.list
        git -c user.name=Leaker -c user.email=leaktoken9000@example.com \
            commit --allow-empty -m "test: simulated identity leak" >/dev/null 2>&1 || true
        if ./tools/check-git-identity.sh >/dev/null 2>&1; then
            fail "check-git-identity passed despite a leaked author identity in history"
        else
            pass "check-git-identity correctly fails on a leaked author identity"
        fi
        printf 'zzz_absent_marker_xyz\n' > tools/PRIVATE-MARKERS.list
        if ./tools/check-git-identity.sh >/dev/null 2>&1; then
            pass "check-git-identity passes when no marker appears in history"
        else
            fail "check-git-identity failed on clean history"
        fi
        rm -f tools/PRIVATE-MARKERS.list
    else
        fail "check-git-identity.sh absent from clone - commit the new guard before smoke-testing"
    fi
)

# Clean up
rm -rf "$TEST_DIR"

echo "--------------------------------------"
if [ "$issues" -eq 0 ]; then
    echo "  HOSTILE ENVIRONMENT TESTS PASSED"
    exit 0
else
    echo "  $issues ISSUE(S) DETECTED"
    exit 1
fi

# EOF
