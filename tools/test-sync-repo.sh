#!/usr/bin/env bash
# OGDK - sync-repo classifier smoke test. Drives the safe-arrival tool through each
# state against a throwaway local bare remote and asserts the documented exit code
# (0 = safe to work, 2 = action required). Linux twin of test-sync-repo.ps1.
set -u
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
issues=0
fail() { echo "[FAIL] $1"; issues=$((issues+1)); }
pass() { echo "[PASS] $1"; }

echo "======================================"
echo "  sync-repo Classifier Smoke Test     "
echo "======================================"

TEST_DIR="$KIT/sandbox sync test"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"

# Isolate from the operator's real git config/identity.
export GIT_CONFIG_GLOBAL="$TEST_DIR/gitconfig"
export GIT_CONFIG_NOSYSTEM=1
: > "$GIT_CONFIG_GLOBAL"
git config --global user.email "synctester@users.noreply.github.com"
git config --global user.name "Sync Tester"
git config --global init.defaultBranch main
git config --global commit.gpgsign false

REMOTE="$TEST_DIR/remote.git"
git init -q --bare "$REMOTE"

setup_clone() {  # $1 = target dir
    git clone -q "$REMOTE" "$1"
    mkdir -p "$1/tools"
    cp "$KIT/tools/sync-repo.ps1" "$KIT/tools/sync-repo.sh" "$1/tools/"
}

assert_sync() {  # $1 dir, $2 expected_code, $3 label, $4 keyword(optional)
    out="$(cd "$1" && bash tools/sync-repo.sh 2>&1)"
    code=$?
    if [ "$code" -ne "$2" ]; then
        fail "$3 (expected exit $2, got $code)"
        return
    fi
    if [ -n "${4:-}" ] && ! printf '%s' "$out" | grep -qi -- "$4"; then
        fail "$3 (exit $2 ok, but output missing '$4')"
        return
    fi
    pass "$3"
}

# A: primary working clone; seed and push so it has an upstream.
setup_clone "$TEST_DIR/A"
(
    cd "$TEST_DIR/A"
    echo "seed" > file.txt
    git add -A
    git commit -q -m "seed"
    git push -q -u origin HEAD
)

# 1. IN-SYNC -> exit 0
assert_sync "$TEST_DIR/A" 0 "in-sync -> exit 0 (safe to work)" "no new remote commits"

# 2. BEHIND -> auto fast-forward -> exit 0. Advance the remote from a 2nd clone.
setup_clone "$TEST_DIR/B"
(
    cd "$TEST_DIR/B"
    echo "from B" >> file.txt
    git commit -q -am "b-commit"
    git push -q origin HEAD
)
assert_sync "$TEST_DIR/A" 0 "behind -> auto fast-forward (safe)" "fast-forwarded"

# 3. AHEAD -> exit 0 (local commit not pushed yet)
(
    cd "$TEST_DIR/A"
    echo "local only" >> file.txt
    git commit -q -am "a-local"
)
assert_sync "$TEST_DIR/A" 0 "ahead -> exit 0 (push when ready)" "not pushed"

# 4. DIVERGED -> exit 2. Remote gains a different commit while A holds its unpushed one.
(
    cd "$TEST_DIR/B"
    git pull -q --ff-only
    echo "b diverge" >> file.txt
    git commit -q -am "b-diverge"
    git push -q origin HEAD
)
assert_sync "$TEST_DIR/A" 2 "diverged -> exit 2 (STOP)" "DIVERGED"

# 5. DIRTY + BEHIND -> exit 2. Fresh clone, advance the remote, leave an uncommitted edit.
setup_clone "$TEST_DIR/C"
(
    cd "$TEST_DIR/B"
    git pull -q --ff-only
    echo "newer" >> file.txt
    git commit -q -am "b-newer"
    git push -q origin HEAD
)
(
    cd "$TEST_DIR/C"
    echo "uncommitted edit" >> file.txt
)
assert_sync "$TEST_DIR/C" 2 "dirty + behind -> exit 2 (STOP)" "uncommitted"

# 6. MERGE in progress -> exit 2 (detected before fetch).
setup_clone "$TEST_DIR/D"
(
    cd "$TEST_DIR/D"
    : > "$(git rev-parse --git-dir)/MERGE_HEAD"
)
assert_sync "$TEST_DIR/D" 2 "merge in progress -> exit 2 (STOP)" "MERGE is in progress"

rm -rf "$TEST_DIR"

echo "--------------------------------------"
if [ "$issues" -eq 0 ]; then
    echo "  SYNC-REPO CLASSIFIER TESTS PASSED"
    exit 0
else
    echo "  $issues ISSUE(S) DETECTED"
    exit 1
fi
# EOF
