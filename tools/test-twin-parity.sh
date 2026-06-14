#!/usr/bin/env bash
# OGDK - twin behavioral-parity harness. The twin rule (check-kit-docs) only
# verifies that a .ps1/.sh PAIR EXISTS; it cannot see when the two halves DRIFT
# apart in behavior (the 2026-06-13 audit found 5 such silent drifts). This
# harness closes that gap in two phases:
#
#   Phase 1 (broad, every twin) - each tools/*.sh parses under 'bash -n' AND each
#       tools/*.ps1 parses under the PowerShell language parser. Generalises the
#       audit's "parse every .ps1 under pwsh" pass to BOTH languages, so a
#       truncated or syntactically-drifted twin is caught for ALL tools cheaply.
#
#   Phase 2 (deep, curated) - safety-critical tools are run through IDENTICAL
#       fixtures in BOTH shells and their EXIT CODES must agree. Exit code is the
#       OS-invariant behavioral contract (0 = clean, nonzero = issues); output
#       TEXT may legitimately differ per OS (documented twin differences), so we
#       assert on exit-code parity and DUMP both outputs on a mismatch.
#
# Needs bash always. The .ps1 side needs PowerShell (pwsh/powershell) - those
# checks are SKIPPED, not failed, when it is absent, because parity can only be
# judged where both shells exist (the operator's working clone has both). Adding
# a tool to Phase 2 = add one 'scn_*' setup function and one SCENARIOS line.
# Twin: test-twin-parity.ps1 (keep behavior identical - see tools/README.md).
#
# Usage: ./tools/test-twin-parity.sh
set -u
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
issues=0
skips=0
pass(){ printf '[PASS] %s\n' "$1"; }
fail(){ printf '[FAIL] %s\n' "$1"; issues=$((issues+1)); }
skip(){ printf '[SKIP] %s\n' "$1"; skips=$((skips+1)); }
info(){ printf '[INFO] %s\n' "$1"; }

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
echo "======================================"
echo "  Twin Parity Harness (OGDK)          "
echo "======================================"

# Locate a PowerShell interpreter (pwsh 7+ preferred, powershell 5.1 fallback).
PWSH=""
if command -v pwsh >/dev/null 2>&1; then PWSH=pwsh
elif command -v powershell >/dev/null 2>&1; then PWSH=powershell
fi

# Parse a single .ps1 with the PowerShell parser only (no execution). The file
# path is passed via the environment so no shell quoting can corrupt it.
ps_parse() { # $1 = file ; returns 0 if it parses clean
    PARSE_FILE="$1" "$PWSH" -NoProfile -Command \
'$t=$null;$e=$null;[void][System.Management.Automation.Language.Parser]::ParseFile($env:PARSE_FILE,[ref]$t,[ref]$e);if($e -and $e.Count -gt 0){exit 1}else{exit 0}' \
        >/dev/null 2>&1
}

# ---- Phase 1: parse parity (all twins) -------------------------------------
echo
echo "--- Phase 1: parse parity (all twins) ---"
sh_bad=""
for f in "$KIT"/tools/*.sh; do
    [ -f "$f" ] || continue
    bash -n "$f" 2>/dev/null || sh_bad="$sh_bad ${f##*/}"
done
if [ -n "$sh_bad" ]; then fail "tools/*.sh failed bash -n:$sh_bad"; else pass "all tools/*.sh parse (bash -n)"; fi

if [ -n "$PWSH" ]; then
    ps_bad=""
    for f in "$KIT"/tools/*.ps1; do
        [ -f "$f" ] || continue
        ps_parse "$f" || ps_bad="$ps_bad ${f##*/}"
    done
    if [ -n "$ps_bad" ]; then fail "tools/*.ps1 failed PowerShell parse:$ps_bad"; else pass "all tools/*.ps1 parse (PowerShell parser via $PWSH)"; fi
else
    skip "no PowerShell found - .ps1 parse + all behavioral parity checks skipped (install pwsh to run them; they run on the operator's clone)"
fi

# ---- Phase 2: behavioral parity (curated, exit-code contract) --------------
echo
echo "--- Phase 2: behavioral parity (exit-code contract) ---"

# Fixture builder: a fresh git repo with an isolated noreply identity and the
# tool's BOTH twins copied into tools/ (each tool roots itself at dirname/.. , so
# it must be run from inside the fixture, exactly as test-sync-repo does).
new_fixture() { # $1 = tool basename ; echoes the fixture dir
    d="$(mktemp -d)"
    git -C "$d" init -q
    git -C "$d" config user.email "parity@users.noreply.github.com"
    git -C "$d" config user.name "Parity Tester"
    git -C "$d" config commit.gpgsign false
    mkdir -p "$d/tools"
    cp "$KIT/tools/$1.sh" "$KIT/tools/$1.ps1" "$d/tools/"
    printf '%s' "$d"
}

# --- scenario setups (each receives the fixture dir as $1) ---
scn_vfi_clean() { echo "all good" > "$1/readme.md"; git -C "$1" add -A; git -C "$1" commit -qm seed; }
scn_vfi_nul()   { printf 'good\000bad\n' > "$1/bad.txt"; git -C "$1" add -A; git -C "$1" commit -qm seed; }
scn_vfi_noeof() {
    printf '#!/usr/bin/env bash\necho hi\n# trailing comment, not a sentinel\n' > "$1/tools/extra.sh"
    printf '# ps stub\nWrite-Host hi\n# trailing comment, not a sentinel\n'      > "$1/tools/extra.ps1"
    git -C "$1" add -A; git -C "$1" commit -qm seed
}
scn_idn_clean() {
    printf 'NOMATCHMARKER\n' > "$1/tools/PRIVATE-MARKERS.list"
    echo x > "$1/f.md"; git -C "$1" add f.md; git -C "$1" commit -qm seed
}
scn_idn_leak() {
    printf 'leakmark\n' > "$1/tools/PRIVATE-MARKERS.list"
    echo x > "$1/f.md"; git -C "$1" add f.md
    git -C "$1" -c user.email="leakmark@example.com" -c user.name="Leak" commit -qm seed
}

# Run one scenario: build fixture, set it up, run BOTH twins, compare exit codes.
run_scn() { # $1 tool  $2 label  $3 setup_fn
    if [ -z "$PWSH" ]; then skip "$2 (needs PowerShell)"; return; fi
    fx="$(new_fixture "$1")"
    "$3" "$fx" >/dev/null 2>&1
    out_sh="$(cd "$fx" && bash "tools/$1.sh" 2>&1)"; code_sh=$?
    out_ps="$(cd "$fx" && "$PWSH" -NoProfile -File "tools/$1.ps1" 2>&1)"; code_ps=$?
    if [ "$code_sh" -eq "$code_ps" ]; then
        pass "$2 [exit parity: both $code_sh]"
    else
        fail "$2 [DRIFT: .sh exit $code_sh vs .ps1 exit $code_ps]"
        echo "------ .sh output ------"; printf '%s\n' "$out_sh" | sed 's/^/    /'
        echo "------ .ps1 output -----"; printf '%s\n' "$out_ps" | sed 's/^/    /'
    fi
    rm -rf "$fx"
}

# Curated scenarios: tool | label | setup function.
run_scn verify-file-integrity "verify-file-integrity: clean repo"          scn_vfi_clean
run_scn verify-file-integrity "verify-file-integrity: NUL-byte corruption"  scn_vfi_nul
run_scn verify-file-integrity "verify-file-integrity: missing EOF sentinel" scn_vfi_noeof
run_scn check-git-identity    "check-git-identity: clean identity"          scn_idn_clean
run_scn check-git-identity    "check-git-identity: leaked identity"         scn_idn_leak

echo
echo "--------------------------------------"
if [ "$issues" -eq 0 ]; then
    echo "  TWIN PARITY OK (${skips} skipped)"
else
    echo "  $issues PARITY ISSUE(S) - twins have drifted"
fi
echo "--------------------------------------"
exit "$issues"
# EOF
