#!/usr/bin/env bash
# Install the OGDK git hooks for THIS clone by pointing core.hooksPath at the
# tracked tools/hooks directory, and make the hook executable. The pre-push hook
# then runs check-git-identity before every push. Per-clone and idempotent
# (core.hooksPath is local config). Undo: git config --unset core.hooksPath.
# Twin: install-hooks.ps1.
set -u
repoRoot="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repoRoot" || exit 1

echo "======================================"
echo "  Install Git Hooks (OGDK)            "
echo "======================================"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "[FAIL] not a git repository - run from inside the repo"
    exit 1
fi
if [ ! -f tools/hooks/pre-push ]; then
    echo "[FAIL] tools/hooks/pre-push not found - nothing to install"
    exit 1
fi
chmod +x tools/hooks/pre-push 2>/dev/null || true
if git config core.hooksPath tools/hooks; then
    echo "[PASS] core.hooksPath -> tools/hooks (pre-push identity guard active)"
    echo "       Test it: git push   (the guard runs first). Undo: git config --unset core.hooksPath"
    code=0
else
    echo "[FAIL] could not set core.hooksPath"
    code=1
fi
exit "$code"
# EOF
