#!/usr/bin/env bash
# THE GATE (OGDK kit itself) - kit-docs self-check + file integrity.
# (No reference manifest in the kit; tools/README.md is its reference.) Twin: gate.ps1.
set -u
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
total=0
if [ -z "${OGDK_BANNER:-}" ]; then
cat <<'OGDKART'
   ___   ____ ____  _  __
  / _ \ / ___|  _ \| |/ /
 | | | | |  _| | | | ' /
 | |_| | |_| | |_| | . \
  \___/ \____|____/|_|\_\
OGDKART
fi
export OGDK_BANNER=1
echo "=== GATE: kit docs ==="
bash "$DIR/check-kit-docs.sh" || total=$((total+$?))
echo; echo "=== GATE: file integrity ==="
bash "$DIR/verify-file-integrity.sh" || total=$((total+$?))
echo; echo "======================================"
if [ "$total" -eq 0 ]; then echo "  GATE PASSED - safe to commit"; else echo "  GATE FAILED ($total) - do not commit"; fi
exit "$total"
