#!/usr/bin/env bash
# tools/safe-agent-push.sh
# Automated, gate-verified git commit & push wrapper for AI agents.
set -euo pipefail
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Run Path Health Check
echo "=== Step 1: Checking Path Health ==="
"$dir/verify-path-health.sh"

# 2. Check Remote Sync Status
echo "=== Step 2: Checking Repository Sync ==="
"$dir/sync-repo.sh"

# 3. Run Gate Checks
echo "=== Step 3: Running Project Gates ==="
"$dir/gate.sh"

# Get commit message
msg="${1:-Auto-commit from agent: green gate verified}"

# 4. Execute Git Commit & Push
echo "=== Step 4: Committing & Pushing ==="
git add .
git commit -m "$msg"
git push origin main
echo "=== PUSH SUCCESSFUL ==="
# EOF
