#!/usr/bin/env bash
# OGDK - one-command setup for a fresh clone. A friendly orchestrator: it runs the
# safety checks in the right order and tells a newcomer exactly what to do next, so
# the first five minutes are one command instead of six stages of copy-paste.
# Read-only: it never commits and never sets your git identity for you. Twin: bootstrap.ps1.
#
# Usage (from inside the cloned kit):  ./tools/bootstrap.sh
set -u
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$DIR/.." && pwd)"
cd "$ROOT"

cat <<'OGDKART'
   ___   ____ ____  _  __
  / _ \ / ___|  _ \| |/ /
 | | | | |  _| | | | ' /
 | |_| | |_| | |_| | . \
  \___/ \____|____/|_|\_\
OGDKART
export OGDK_BANNER=1
echo "  Bootstrap - first-run setup (OGDK)"
echo "======================================"

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
    echo "[NOTE] macOS is experimental here (the scripts assume GNU tools). If a check"
    echo "       acts strangely, install GNU userland:  brew install coreutils gnu-sed grep"
fi

echo
echo "Step 1/4: checking git..."
if ! command -v git >/dev/null 2>&1; then
    echo "[ACTION] git is not installed yet. Install it, then run this again:"
    echo "         Linux (Arch):  sudo pacman -S git"
    echo "         macOS:         xcode-select --install   (or: brew install git)"
    exit 1
fi
echo "[OK] git present ($(git --version))"
if [ -z "$(git config user.email 2>/dev/null)" ]; then
    echo "[ACTION] git does not know who you are yet. Set it once (use YOUR details):"
    echo "         git config --global user.name \"Your Name\""
    echo "         git config --global user.email \"you@example.com\""
    echo "         Tip: a GitHub noreply email keeps your address private."
    echo "         Then run this script again."
    exit 1
fi
echo "[OK] git identity: $(git config user.email)"

echo
echo "Step 2/4: environment health..."
if ! bash "$DIR/verify-path-health.sh"; then
    echo "[STOP] fix the health issues above, then run bootstrap again."
    exit 1
fi

echo
echo "Step 3/4: the gate (proves the kit works on YOUR machine)..."
if ! bash "$DIR/gate.sh"; then
    echo "[STOP] the gate did not pass. Copy everything above and report it - that is a real finding."
    exit 1
fi

echo
echo "Step 4/4: arming the optional privacy git hooks..."
bash "$DIR/install-hooks.sh" >/dev/null 2>&1 || true
echo "[OK] done."

echo
echo "======================================"
echo "  YOU ARE READY."
echo "  Build something:   ./tools/new-project.sh -n MyIdea -t App"
echo "  Then open the new folder with your AI agent and say:  run session-start"
echo "  New to all this?   read START-BUILDING.md"
echo "======================================"
exit 0
