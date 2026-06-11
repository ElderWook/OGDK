# LESSONS — the learning loop's capture buffer (OGDK kit-level)

> Append-only. Every session that hits **friction the system didn't prevent** logs it
> here before ending (session-end skill, step 4). Entries are raw material for the
> `kit-retro` skill, which periodically converts them into permanent upgrades to
> skills, AGENTS rules, gate scripts, and reference docs — then marks them CODIFIED.

Format: see docs-template/LESSONS.md.

---

## 2026-06-10 PS 5.1 here-strings parse-bomb with LF endings
**What happened:** new-project.ps1 failed to parse on the user's machine; cause was here-strings in a file written with LF line endings.
**Root cause:** no constraint existed on .ps1 authoring style for sandbox-written files.
**Proposed fix:** ASCII-only / no-here-strings rule for all .ps1.
**Status:** CODIFIED 2026-06-10, AGENTS.md twin rule + tools/README.md §Rules.

## 2026-06-11 Sync-layer mount corrupted files via shell append
**What happened:** a trailing-newline sweep appended through stale mount views, overwriting one byte mid-file in ~35 files across all repos.
**Root cause:** no rule against partial/offset-dependent shell writes through the mount; stale views made the operation land at wrong offsets.
**Proposed fix:** ban all shell-side file mutation through mounts except whole-file writes; file tools are authoritative.
**Status:** CODIFIED 2026-06-11, AI-PARITY.md §4 + AGENTS templates + memory.

## 2026-06-11 Coverage checker propagated truncated via mount cp
**What happened:** check-reference-coverage.ps1 copies shipped truncated to all three projects (parse error at gate time).
**Root cause:** cp from the kit mount reads stale views of host-written files — propagation itself was an unsafe mount read.
**Proposed fix:** propagate kit files via host file tools or freshly bash-written content only; size/parse-verify after copy.
**Status:** CODIFIED 2026-06-11, AI-PARITY.md §4 (reads lag too) + this retro buffer.

## 2026-06-11 UE freshness check compared plugin sources to game DLL
**What happened:** DevSandbox gate failed forever after plugin-only rebuilds; plugin code never updates the game DLL.
**Root cause:** gate design assumed one DLL; modular architecture compiles per-plugin.
**Proposed fix:** compare against newest editor DLL across game + plugins.
**Status:** CODIFIED 2026-06-11, DevSandbox tools/gate.{ps1,sh}.

## 2026-06-11 Broken Python stub read as file corruption
**What happened:** integrity check FAILed every .py file because the machine's python was a broken launcher stub (0x800702E4) — the checker blamed the files.
**Root cause:** scripts trusted Get-Command without verifying the interpreter launches.
**Proposed fix:** probe python/py/python3 with --version before use; distinct env-vs-file messaging.
**Status:** CODIFIED 2026-06-11, verify-file-integrity.ps1 + DevKitGhost gate.ps1.

## 2026-06-11 Global agent config silently overrode a read-only repo instruction
**What happened:** during the first cross-vendor parity test (Gemini, explicitly read-only), the agent ran a global agy "unified session" script (`update_unified_history.ps1`) — an instruction layer neither the prompt nor the repo could see. The chain-following itself scored perfectly.
**Root cause:** the parity contract governed repo-level config but never declared precedence over user-global agent config (agy, ~/.gemini, IDE rules); globals are invisible context.
**Proposed fix:** precedence clause in AI-PARITY §1 (repo wins on process; globals = preferences only; conflicts must be disclosed + logged); user audits agy globals to strip process directives or add an "AGENTS.md repos: defer" guard.
**Status:** CODIFIED 2026-06-11, AI-PARITY.md (kit + projects); agy global cleanup is the user's follow-up.

## 2026-06-11 Kit shipped user-hardcoded launcher for months-of-future use
**What happened:** launch-claude-clean.ps1 carried C:\Users\operator\... paths from OpenBook into every scaffolded project; would break on any other machine.
**Root cause:** day-1 copy was never re-audited against kit rule 3 (zero-context usability); no check covers hardcoded user paths.
**Proposed fix (open part):** consider a check-kit-docs rule flagging `C:\\Users\\` in tools/.
**Status:** CODIFIED 2026-06-11 (script genericized, all repos); checker shipped same day — check-kit-docs check 6 (C:\Users\, /home/, /Users/ scan over tools/).

## 2026-06-11 Full kit review found latent drift hazards before they fired
**What happened:** an intensive review (modularity/stability/automation) found: a duplicate hand-maintained reference Index next to the machine-checked COVERAGE.md; DOCUMENTATION-VERSIONING-GUIDE shipping OpenBook/WyeR specifics into every project (kit rule 3 violation) and a second, conflicting plan-lifecycle vocabulary — file was also truncated mid-sentence since import; tools/README claiming macOS support the GNU-only scripts don't have; new-reference-page mangling titles containing sed metacharacters (& #); verify-file-integrity.sh silently skipping the .py check when python3 is absent; tool propagation hardcoded in two scaffolders with no path to existing projects.
**Root cause:** rules existed as prose faster than checks existed as scripts; day-1 imports never re-audited against kit rule 3.
**Proposed fix:** single manifest (Index deleted); guide rewritten generic with ONE lifecycle (Proposed→Active→Completed→Archived); honest Linux-only claim; sed-escape hardening; explicit skip WARN; PROPAGATE.list + propagate-tools.{ps1,sh} consumed by both scaffolders.
**Status:** CODIFIED 2026-06-11, this commit set.

## 2026-06-12 Truncated .ps1 sat committed and undetected for a day
**What happened:** DevKitGhost's verify-path-health.ps1 was truncated mid-string at its final line (corruption-era propagation, pre propagate-tools) and lived in git unnoticed until the user ran it after the Linux trip — first parse error on invocation.
**Root cause:** detection gap — integrity checks compiled .py but never parsed .ps1/.sh; the gate doesn't invoke path-health; propagation predated byte-verification.
**Proposed fix:** verify-file-integrity gains script-syntax checks (PowerShell parser for *.ps1 on Windows twin; `bash -n` for *.sh on Linux twin — documented platform difference); repair delivered via propagate-tools (its first real mission).
**Status:** CODIFIED 2026-06-12, verify-file-integrity.{ps1,sh} + propagate run.

## 2026-06-11 Pre-commit hook for THE GATE considered, declined
**What happened:** review flagged that the gate is honor-system — nothing mechanically stops an ungated commit.
**Root cause:** by design; surfaced as a conscious decision rather than a defect.
**Proposed fix:** evaluated a core.hooksPath pre-commit hook (full or cheap-checks-only).
**Status:** CODIFIED 2026-06-11, declined — the checkpoint protocol depends on fast `wip:` emergency commits; a hook blocks them at the worst moment. Session-end skill + muscle memory carry it. Do not re-litigate unless an ungated commit actually ships breakage.
