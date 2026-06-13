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
**What happened:** the game repo's gate failed forever after plugin-only rebuilds; plugin code never updates the game DLL.
**Root cause:** gate design assumed one DLL; modular architecture compiles per-plugin.
**Proposed fix:** compare against newest editor DLL across game + plugins.
**Status:** CODIFIED 2026-06-11, the game repo's tools/gate.{ps1,sh}.

## 2026-06-11 Broken Python stub read as file corruption
**What happened:** integrity check FAILed every .py file because the machine's python was a broken launcher stub (0x800702E4) — the checker blamed the files.
**Root cause:** scripts trusted Get-Command without verifying the interpreter launches.
**Proposed fix:** probe python/py/python3 with --version before use; distinct env-vs-file messaging.
**Status:** CODIFIED 2026-06-11, verify-file-integrity.ps1 + the affected project's gate.ps1.

## 2026-06-11 Global agent config silently overrode a read-only repo instruction
**What happened:** during the first cross-vendor parity test (Gemini, explicitly read-only), the agent ran a global agy "unified session" script (`update_unified_history.ps1`) — an instruction layer neither the prompt nor the repo could see. The chain-following itself scored perfectly.
**Root cause:** the parity contract governed repo-level config but never declared precedence over user-global agent config (agy, ~/.gemini, IDE rules); globals are invisible context.
**Proposed fix:** precedence clause in AI-PARITY §1 (repo wins on process; globals = preferences only; conflicts must be disclosed + logged); user audits agy globals to strip process directives or add an "AGENTS.md repos: defer" guard.
**Status:** CODIFIED 2026-06-11, AI-PARITY.md (kit + projects); agy global cleanup is the user's follow-up.

## 2026-06-11 Kit shipped user-hardcoded launcher for months-of-future use
**What happened:** launch-claude-clean.ps1 carried hardcoded `C:\Users\<owner>\...` paths from its origin project into every scaffolded project; would break on any other machine.
**Root cause:** day-1 copy was never re-audited against kit rule 3 (zero-context usability); no check covers hardcoded user paths.
**Proposed fix (open part):** consider a check-kit-docs rule flagging `C:\\Users\\` in tools/.
**Status:** CODIFIED 2026-06-11 (script genericized, all repos); checker shipped same day — check-kit-docs check 6 (C:\Users\, /home/, /Users/ scan over tools/).

## 2026-06-11 Full kit review found latent drift hazards before they fired
**What happened:** an intensive review (modularity/stability/automation) found: a duplicate hand-maintained reference Index next to the machine-checked COVERAGE.md; DOCUMENTATION-VERSIONING-GUIDE shipping origin-project specifics into every project (kit rule 3 violation) and a second, conflicting plan-lifecycle vocabulary — file was also truncated mid-sentence since import; tools/README claiming macOS support the GNU-only scripts don't have; new-reference-page mangling titles containing sed metacharacters (& #); verify-file-integrity.sh silently skipping the .py check when python3 is absent; tool propagation hardcoded in two scaffolders with no path to existing projects.
**Root cause:** rules existed as prose faster than checks existed as scripts; day-1 imports never re-audited against kit rule 3.
**Proposed fix:** single manifest (Index deleted); guide rewritten generic with ONE lifecycle (Proposed→Active→Completed→Archived); honest Linux-only claim; sed-escape hardening; explicit skip WARN; PROPAGATE.list + propagate-tools.{ps1,sh} consumed by both scaffolders.
**Status:** CODIFIED 2026-06-11, this commit set.

## 2026-06-12 Multi-machine drift produced a novice merge conflict
**What happened:** the operator committed on machine A from a kit working copy that was behind origin (machine B had pushed newer commits), then hit a push rejection and an add/add merge conflict on a kit-propagated tool file — exactly the git rabbit hole the kit exists to prevent. The stale propagation source was only spotted because KIT-VERSION stamped an old hash.
**Root cause:** nothing checked remote-vs-local state at session start; git's default pull happily creates conflict states a novice then has to dig out of; conflicts on kit-propagated files LOOK like real merges but never are.
**Proposed fix:** sync-repo.{ps1,sh} safe-arrival classifier (fetch-first; ff-only is the only auto-action; DIVERGED/dirty/mid-merge = STOP with plain-language instructions + the kit-files rule) as session-start step 2; checkpoint.{ps1,sh}+(.bat) panic save so interrupted sessions always leave a wip: commit instead of a dirty tree.
**Status:** CODIFIED 2026-06-12, tools/sync-repo.{ps1,sh} + tools/checkpoint.{ps1,sh,bat} + session-start/session-end skills + PROPAGATE.list.

## 2026-06-12 Truncated .ps1 sat committed and undetected for a day
**What happened:** a project's verify-path-health.ps1 was truncated mid-string at its final line (corruption-era propagation, pre propagate-tools) and lived in git unnoticed until the operator ran it after the Linux trip — first parse error on invocation.
**Root cause:** detection gap — integrity checks compiled .py but never parsed .ps1/.sh; the gate doesn't invoke path-health; propagation predated byte-verification.
**Proposed fix:** verify-file-integrity gains script-syntax checks (PowerShell parser for *.ps1 on Windows twin; `bash -n` for *.sh on Linux twin — documented platform difference); repair delivered via propagate-tools (its first real mission).
**Status:** CODIFIED 2026-06-12, verify-file-integrity.{ps1,sh} + propagate run.

## 2026-06-12 Truncation hid inside a comment and passed bash -n
**What happened:** during verification, a stale mount view of check-kit-docs.sh was cut off mid-COMMENT ~30 lines early — `bash -n` passed it (a file ending in a comment is valid syntax) and the missing checks simply never ran, silently.
**Root cause:** syntax parsing proves parseability, not completeness; nothing asserted "this file has an ending."
**Proposed fix:** EOF sentinel — every tools script must END with a line starting `exit` or `# EOF`; verify-file-integrity FAILs otherwise (check 4b).
**Status:** CODIFIED 2026-06-12, verify-file-integrity.{ps1,sh} check 4b + sentinel lines added to all kit scripts.

## 2026-06-12 Kit had no provenance or fleet view for propagated tools
**What happened:** stack review found projects can't tell which kit commit their tools came from, and tool fixes required remembering every project — the exact gap the truncated-script incident exploited.
**Root cause:** propagation was one-target with no version stamp; drift invisible until breakage.
**Proposed fix:** tools/KIT-VERSION stamped by new-project + propagate-tools (printed by verify-path-health each session); propagate-tools -All/--all over gitignored tools/TARGETS.list.
**Status:** CODIFIED 2026-06-12, propagate-tools.{ps1,sh} + new-project.{ps1,sh} + verify-path-health.{ps1,sh}.

## 2026-06-12 Skills propagation crashed on a layout relic
**What happened:** propagate -All maiden run aborted mid-target: one project's .claude/skills held the OLD flat layout (bare SKILL.md + leaf files named like skills), and the blind recursive Copy-Item could not copy a folder onto a leaf; ErrorActionPreference=Stop killed the run before the KIT-VERSION stamp.
**Root cause:** propagation assumed the destination layout matched the kit's; nothing handled drift from older layouts, and one bad target could abort the fleet run.
**Proposed fix:** per-skill replace (remove existing entry file-or-folder, copy fresh) + WARN on entries the kit does not recognize (never silently delete - could be a custom skill).
**Status:** CODIFIED 2026-06-12, propagate-tools.{ps1,sh} skills block.

## 2026-06-11 PROPAGATE.list CRLF broke the .sh scaffolder on a Windows checkout
**What happened:** during a sandboxed smoke test, new-project.sh died (`cannot stat '...\r.ps1'`): PROPAGATE.list checks out CRLF on Windows (`* text=auto`, no `*.list` rule) and the bash list parsers never strip `\r` (xargs trims blanks, not CR). The Arch clone checks out LF, so the prior cross-platform pass never saw it.
**Root cause:** list files had no eol policy; .sh list parsers assumed LF input. The .ps1 twins are naturally CRLF/LF-tolerant, so the twins silently diverged in robustness.
**Proposed fix:** strip trailing `\r` in every .sh list parser (new-project, propagate-tools); pin `*.list text eol=lf` in .gitattributes; rewrite PROPAGATE.list with LF endings.
**Status:** CODIFIED 2026-06-11, new-project.sh + propagate-tools.sh + .gitattributes + PROPAGATE.list.

## 2026-06-11 grep -c with "|| echo 0" emits two zeros when the count is zero
**What happened:** with zero OPEN lessons, the learning-loop nudge printed `[: 0 0: integer expression expected` in check-kit-docs.sh (check 9) and check-reference-coverage.sh. Cosmetic (exit code unaffected) but it makes a green gate look broken.
**Root cause:** `grep -c` prints `0` AND exits 1 on no match, so `|| echo 0` appends a second zero; the var becomes `0\n0`.
**Proposed fix:** `|| true` plus a `${var:-0}` default instead of `|| echo 0`.
**Status:** CODIFIED 2026-06-11, check-kit-docs.sh + check-reference-coverage.sh (coverage checker is in PROPAGATE.list — re-propagate to the fleet).

## 2026-06-11 Synced-mount READS served truncated file views to a sandboxed session
**What happened:** a Cowork sandbox's mount view showed ~29 kit files truncated mid-line (one with a NUL-filled tail) while every file on the host disk was intact and complete. An audit nearly misdiagnosed repo corruption; the smoke test had to rebuild a faithful working copy from direct file-tool reads before any shell verification was trustworthy. Separately: verify-file-integrity in a git-less copy "passed" while scanning ZERO files (`git ls-files` empty → every check vacuous).
**Root cause:** AI-PARITY §4 bans git and shell WRITES through mounts; verification READS were assumed safe but stale views lie on read too. Integrity checks enumerate files via git only, with no signal when the enumeration is empty.
**Proposed fix:** AI-PARITY §4 note — in-sandbox shell verification requires file-tool-sourced copies (mount reads are non-authoritative); verify-file-integrity.{ps1,sh} should WARN "0 files checked" (or fall back to `find`) when git enumeration returns nothing.
**Status:** CODIFIED 2026-06-12, verify-file-integrity.{ps1,sh} local scanning fallbacks + AI-PARITY.md update.

## 2026-06-12 Personal email leaked via commit author identity
**What happened:** pre-publication history rewrite anonymized 33/39 commits, but 5 newer commits carried the operator's real email in the author field — caught by the public-safety audit (fresh clone of the public repo), fixed by reset-author rebase + re-tag + force-push during the unlinked window.
**Root cause:** nothing in the kit addresses git identity; all guards scan file CONTENT, while author metadata travels in every commit object.
**Proposed fix:** GETTING-STARTED + verify-path-health identity check could recommend/verify a noreply email (`<id>+<user>@users.noreply.github.com`) before first commit in public-bound repos; at minimum a GETTING-STARTED line.
**Status:** CODIFIED 2026-06-12 (interim: GETTING-STARTED.md warnings + verify-path-health.{ps1,sh}, but that only WARNs on today's *config* and cannot see commit objects already in history). HARDENED 2026-06-13, tools/check-git-identity.{ps1,sh}: scans author + committer name/email across ALL history against PRIVATE-MARKERS.list, FAILs the gate on any match (chained into gate.{ps1,sh}); hostile-env smoke test gains leak-detection + clean-pass cases. Follow-up (not blocking): propagate the checker to project gate.template + PROPAGATE.list so public-bound *projects* get the same guard.

## 2026-06-11 Pre-commit hook for THE GATE considered, declined
**What happened:** review flagged that the gate is honor-system — nothing mechanically stops an ungated commit.
**Root cause:** by design; surfaced as a conscious decision rather than a defect.
**Proposed fix:** evaluated a core.hooksPath pre-commit hook (full or cheap-checks-only).
**Status:** CODIFIED 2026-06-11, declined — the checkpoint protocol depends on fast `wip:` emergency commits; a hook blocks them at the worst moment. Session-end skill + muscle memory carry it. Do not re-litigate unless an ungated commit actually ships breakage.

## 2026-06-13 Pre-push hook for the identity guard (narrow scope) adopted
**What happened:** check-git-identity (the history-scan author/committer guard) was chained into the gate, but the gate is honor-system — nothing mechanically stops an ungated push from leaking identity to a public remote. The 2026-06-11 entry above declined a pre-COMMIT hook because it blocks fast `wip:` checkpoint commits.
**Root cause:** identity leak is a PUSH-time risk, not a commit-time one. The pre-commit objection (checkpoint speed) does not apply to a pre-PUSH hook — checkpoint's panic save is a local commit + push, and if the hook blocks a leaky push the local commit still saves; sync-repo untangles it next session.
**Proposed fix:** a tracked `tools/hooks/pre-push` that runs ONLY check-git-identity (not the whole gate, to keep pushes fast), installed per-clone via `tools/install-hooks.{ps1,sh}` (`core.hooksPath=tools/hooks`). Single LF-pinned sh hook (git runs hooks through its own sh on both OSes); calls the read-only `.sh` checker so there is no NTFS-write hazard. Skips cleanly when the checker / bash / PRIVATE-MARKERS.list is absent, so contributors without a markers list are never blocked. `--no-verify` remains the deliberate override.
**Status:** CODIFIED 2026-06-13, tools/hooks/pre-push + tools/install-hooks.{ps1,sh} + .gitattributes LF pin. Does NOT reopen the pre-commit decision (different trigger, different cost). Follow-up (not blocking): wire install-hooks into session-start/new-project and propagate the hook to projects via PROPAGATE.list.

## 2026-06-13 sync-repo classifier shipped without smoke coverage
**What happened:** the safe-arrival classifier (sync-repo, the multi-machine merge-conflict prevention net shipped 2026-06-12) had zero automated coverage; a regression in its state classification would silently reintroduce the exact novice merge conflict it exists to prevent. The stack audit flagged it as the highest-risk untested logic in tools/.
**Root cause:** test-hostile-env covered path-health / gate / scaffold but not sync-repo's branch logic; the tool was added without a paired test.
**Proposed fix:** tools/test-sync-repo.{ps1,sh} — exercises in-sync / behind-fast-forward / ahead / dirty+behind / diverged / merge-in-progress against a throwaway local bare remote and asserts each documented exit code (0 = safe, 2 = act).
**Status:** CODIFIED 2026-06-13, tools/test-sync-repo.{ps1,sh}.

## 2026-06-13 PowerShell test captured nothing via 2>&1 (Write-Host is the info stream)
**What happened:** test-sync-repo.ps1 asserted on sync-repo's output with `& script 2>&1 | Out-String`; all six keyword checks FAILed on first run even though the text was plainly on screen and every exit code was correct. Kit tools print via Write-Host, which writes to PowerShell's information stream (6), not stdout — `2>&1` (error stream) captured nothing, so `$out` was empty and every keyword match missed.
**Root cause:** a test capturing a kit tool's output for assertions must redirect stream 6 (or all streams). `2>&1` is the bash habit and silently under-captures in PowerShell; because exit codes still pass, a test that relied ONLY on output matching would be a false-green hazard (here it failed loud, which is the lucky direction).
**Proposed fix:** PowerShell tests that assert on tool output use `*>&1` (capture all streams). The .sh twin uses echo->stdout so its `2>&1` is correct — documented platform difference. Codify as a test-authoring convention (tools/README.md) when kit-retro runs.
**Status:** CODIFIED 2026-06-13, test-sync-repo.ps1 (`*>&1`); convention note deferred to kit-retro.
