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

## 2026-06-13 Kit docs path-check scanned gitignored target/marker lists
**What happened:** check-kit-docs path check failed because tools/TARGETS.list and tools/PRIVATE-MARKERS.list contain local path markers and are gitignored, but the check scanned all files under tools/*.
**Root cause:** check-kit-docs path scanner was blindly looping over all files in tools/ without excluding gitignored/local configuration lists.
**Proposed fix:** exclude TARGETS.list and PRIVATE-MARKERS.list from the tools path check.
**Status:** CODIFIED 2026-06-13, tools/check-kit-docs.sh + tools/check-kit-docs.ps1.

## 2026-06-13 Twin rule verified existence but not behavioral parity
**What happened:** an external audit found real behavioral drift between several .ps1/.sh twins the gate never caught: sync-repo.ps1 lacked the synced-mount guard its .sh twin enforced (Windows could run git through a OneDrive/UNC path - the exact hazard the kit exists to prevent); verify-file-integrity.sh probed only python3 while the .ps1 probed python/py/python3 (a box with python but no python3 silently skipped the .py truncation gate); check-reference-coverage separator-skip regex and summary text differed; launch-claude-clean.ps1 skipped the health gate the .sh runs before launch; check-kit-docs marker scan skipped binary files on Linux only.
**Root cause:** check-kit-docs check 1 (twin rule) asserts the PAIR EXISTS, never that the two halves BEHAVE the same. Behavioral parity has been carried by author discipline alone, so drift accumulated silently between releases.
**Proposed fix:** the five drifts were corrected this commit (both twins). Systemic follow-up still open: a parity lint that flags when one twin contains a guard keyword/branch the other lacks, or a shared scenario table both twins must satisfy (test-sync-repo is the model to copy).
**Status:** CODIFIED 2026-06-14, tools/test-twin-parity.{ps1,sh} — the behavioral-parity harness that was the unbuilt part. Phase 1 parses every tools/*.sh under `bash -n` and every tools/*.ps1 under the PowerShell parser (generalises the audit's "parse every .ps1 under pwsh" pass to both languages). Phase 2 runs verify-file-integrity + check-git-identity through identical throwaway fixtures in BOTH shells and asserts exit-code parity (the OS-invariant contract; text may differ per OS, so a mismatch dumps both). The cross-shell half SKIPs (not fails) when one interpreter is absent, since parity is only judgeable where both exist. Verified via drift injection: Phase 2 caught a behavioral drift that parse checks miss, Phase 1 caught a syntax drift. (The five original drifts themselves were fixed 2026-06-13 on both twins.) Follow-up (not blocking): broaden Phase 2's curated tool list as more twins gain cheap deterministic scenarios.

## 2026-06-13 Onboarding was written for the maintainer, not the newcomer
**What happened:** the audit's headline finding - every entry doc front-loaded maintainer paranoia (NTFS/MSYS2 hazards, privacy markers, fleet propagation, history rewrites) before a newcomer could build anything, contradicting the stated goal of handing the kit to someone with ideas and little coding experience.
**Root cause:** the kit grew by accreting guardrails, each documented where it was added; no progressive-disclosure layer ever separated "I want to build" from "I maintain the kit". A guardrail should be invisible until it catches something.
**Proposed fix:** two front doors in README; START-BUILDING.md (six-word loop: idea -> scaffold -> plan -> build -> gate -> save) that hides maintainer machinery; bootstrap.{ps1,sh} (one-command setup collapsing GETTING-STARTED Stages 2-4); explain-mode + project-retro skills (the agent teaches architecture as it builds, then recaps - delivering the "learn how code works" payoff); rescue.{ps1,sh} (symmetric to checkpoint - the undo-the-mess button); report-snag.{ps1,sh} (frictionless LESSONS capture); -Features/-Preset in new-project (interactive shape wizard + annotated module placeholders, language code still agent-generated per CODE-CONVENTIONS); beginner-friendly phrasing of the optional privacy WARNs in verify-path-health.
**Status:** CODIFIED 2026-06-13, README.md + START-BUILDING.md + tools/bootstrap.{ps1,sh} + tools/rescue.{ps1,sh} + tools/report-snag.{ps1,sh} + skills/explain-mode + skills/project-retro + new-project.{ps1,sh} + verify-path-health.{ps1,sh} + PROPAGATE.list. Follow-up (not blocking): propagate rescue/report-snag to existing project repos; consider an interactive feature wizard mapping the full 10-question APP-ARCHITECT set, not just preset A-E.

## 2026-06-13 Pre-commit cheap-gate that exempts wip: commits (re-raise, not re-litigation)
**What happened:** the 2026-06-11 entry declined a pre-commit gate because it would block fast wip: checkpoint commits. The audit noted that decision evaluated "full" and "cheap-checks-only" but never the variant that runs cheap checks AND auto-exempts wip: commits by inspecting the commit subject - which preserves checkpoint speed while giving mechanical enforcement that an honor-system gate cannot, exactly for the beginners the kit now targets.
**Root cause:** honor-system gating fails the audience least likely to remember to run the gate; the existing tools/hooks/pre-commit is already the right home and already skips cleanly when prerequisites are absent.
**Proposed fix:** evaluate extending tools/hooks/pre-commit to optionally run the cheap integrity subset, skipping any commit whose subject starts with 'wip:'. Decide on its own merits.
**Status:** CODIFIED 2026-06-14, tools/hooks/pre-commit gains a cheap staged-only integrity gate: NUL-byte block + EOF-sentinel block on tools scripts + trailing-newline warn, all pure-text (no python/bash/pwsh) so it runs unchanged under git's bundled sh on Windows. It is panic-exempt via OGDK_SKIP_INTEGRITY, which checkpoint.{ps1,sh} now set on their wip: commit. Chosen over subject-sniffing (the originally-proposed "skip if subject starts wip:") because (a) a pre-commit hook cannot read the final commit subject reliably, and (b) the real intent is to never block a PANIC save of a half-broken tree — and checkpoint is exactly that tool, so marking it is both reliable and semantically precise; a manual `wip:` commit is not a panic save and can pass the cheap gate. The privacy scan still always runs; the marker guard was restructured so the integrity gate runs even when PRIVATE-MARKERS.list is absent. Verified across 8 throwaway-repo scenarios (clean / NUL / missing-sentinel / sentinel-present / panic-exempt / no-markers / privacy-leak / clean-with-markers). Does NOT reopen the full-gate decline (different trigger, different cost).

## 2026-06-13 Study of Vercel Labs' opensrc dependency source context caching
**What happened:** studied vercel-labs/opensrc to evaluate AI-agent dependency context enrichment, release pipelines, and monorepo structure.
**Root cause:** AI agents often lack implementation visibility into third-party dependencies (relying on type stubs or docs), leading to integration bugs.
**Proposed fix:** ADAPT opensrc into user-notes.md and create a skills/inspect-dependency skill template for projects, enabling on-demand shallow cloning and caching of package source code under ~/.opensrc/.
**Status:** OPEN (study artifact created, pending human review of the proposal).

## 2026-06-14 Recurring multi-machine git messes ate sessions (steps got skipped)
**What happened:** session after session began (and often ended) untangling git — a sync not run on arrival so work landed on a stale base; a tool propagation run on one machine but left uncommitted while the other machine pushed its own, diverging the target; leftover stashes and dirty trees from past untangling. The kit had the *tools* to prevent each (sync-repo, checkpoint, propagate-tools) but no binding flow that made the steps un-skippable, and no read-only whole-fleet view to catch trouble before propagating.
**Root cause:** the git workflow lived as scattered prose and operator memory; nothing made an agent walk the human through the checkpoints in order, gate on each, and refuse to cross one with an uncommitted tree. A synced-mount agent also cannot run git, so the discipline has to be "agent narrates the exact commands, human runs them natively, agent waits for the pasted result."
**Proposed fix:** gitwalk — a no-skip git lifecycle. `docs-template/workflow/GIT-LIFECYCLE.md` (C0 ARRIVE → C1 GROUND → C2 SAVE → C3 PROPAGATE → C4 HANDOFF → C5 DEPART → C6 SWITCH-MACHINE, each with exact commands + resolve sub-flows S1–S6); an always-on binding clause in `AGENTS.md` + `AGENTS.template.md` (present each checkpoint's commands, gate on the human's pasted output, nothing crosses a checkpoint uncommitted); `tools/fleet-status.{ps1,sh}` (read-only whole-fleet sweep = the C0 multi-repo check); session-start/session-end skills wired to the lifecycle.
**Status:** CODIFIED 2026-06-14 — GIT-LIFECYCLE.md + AGENTS.md/AGENTS.template.md gitwalk clause + tools/fleet-status.{ps1,sh} (twin, verified byte-identical including the unborn-HEAD edge) + session-start/session-end skills. fleet-status is kit-only (not propagated); the lifecycle doc + skills scaffold to projects and propagate via `--skills`. Follow-up (not blocking): have new-project print the C0 command on first run; consider a fleet-wide checkpoint helper.

## 2026-06-14 Fleet list was hand-maintained and per-machine-blind
**What happened:** `tools/TARGETS.list` (the gitignored, per-machine list that drives `fleet-status` and `propagate-tools --all`) had to be edited by hand. New projects from `new-project` weren't tracked until someone remembered to add them, and a project cloned on a second machine was invisible to that machine's fleet tooling — the list is gitignored, so it doesn't travel with the repo.
**Root cause:** project registration was a manual step with no tool; nothing connected "a project was scaffolded / cloned here" to "this machine's fleet list knows about it."
**Proposed fix:** `new-project` auto-registers each scaffolded project into TARGETS.list (idempotent); `tools/track-projects.{ps1,sh}` discovers OGDK projects (a git repo carrying `tools/KIT-VERSION`) under a root dir and registers any missing — the one-command fix for "cloned on another machine," since the list is per-machine.
**Status:** CODIFIED 2026-06-14 — new-project.{ps1,sh} section 8 + tools/track-projects.{ps1,sh} (twin; verified scan / idempotent / reject + identical registered sets across twins) + README/user-notes rows + GIT-LIFECYCLE C6. Also: fleet-status now trims the KIT-VERSION "(do not edit)" annotation in its table, and the new .sh tools were fixed to mode 100755 to match the kit's executable-.sh convention.

## 2026-06-14 Propagated .sh lost the executable bit; the kit source had drifted too
**What happened:** several projects (an embedded project, an embedded project, and others) carried their `tools/*.sh` as non-executable (100644) in git, so each needed a manual `chmod +x` + commit before the scripts would run — a recurring per-project annoyance the fleet sweep surfaced. Two of the kit's OWN source scripts (`fleet-status.sh`, `safe-agent-push.sh`) were also committed 100644.
**Root cause:** `propagate-tools.sh` and `new-project.sh` already `chmod +x` their copied `.sh`, but (a) nothing guarded the kit SOURCE from regressing to non-exec — a script created by a file tool lands 100644 and `cp` then carries that mode — and (b) the `.ps1` twins can't set a Unix exec bit on Windows (and git's `core.fileMode` is off there), so a Windows propagation commits the copies non-exec.
**Proposed fix:** a `check-kit-docs` guard (check 10) that FAILs if any tracked `tools/*.sh` is not 100755 — it reads `git ls-files -s` (the mode that actually travels), so the source becomes self-correcting; fix any straggler with `git update-index --chmod=+x`. The two kit stragglers were set to 100755.
**Status:** CODIFIED 2026-06-14 — check-kit-docs.{ps1,sh} check 10 + fleet-status.sh / test-twin-parity.sh / safe-agent-push.sh → 100755. Verified: the guard flags a 644 `.sh` and passes at 755, and both twins report identically. Residual (documented, not blocking): a propagation run from Windows still can't set the bit — it self-heals on the next Linux touch.

## 2026-06-14 safe-agent-push didn't strictly follow gitwalk (the local-access path)
**What happened:** safe-agent-push (the automated commit+push wrapper for an agent that CAN run git) ran the right checkpoints — path-health, sync-repo, gate, then commit+push — but the git invocations were sloppy: `git add .` (cwd-scoped, misses changes outside the cwd), `git push origin main` (hardcoded remote+branch, wrong off `main`), it errored when there was nothing to commit, and it had no fast-fail mount guard (relying entirely on sync-repo's guard to fire).
**Root cause:** the wrapper predates gitwalk; its git calls were quick-and-dirty rather than the lifecycle's C2 SAVE semantics, and nothing self-documented that it is the NATIVE-ACCESS path (a synced-mount agent must never reach its git step).
**Proposed fix:** harden to strict adherence — `git -C <repo> add -A` + `git push` (current branch's upstream); skip the commit gracefully when nothing is staged (still push unpushed commits); a fast-fail synced-mount guard at the very top (belt-and-suspenders with sync-repo's); and a header documenting the C0→C2 mapping and the never-force rule.
**Status:** CODIFIED 2026-06-14 — tools/safe-agent-push.{ps1,sh}. Verified: the mount guard STOPs (exit 2) before any git when run from a synced mount; the save step commits when there are changes and is a clean no-op when there aren't. AGENTS clause + GIT-LIFECYCLE "Execution modes" now name safe-agent-push as the native-access SAVE path; the clause was also added to all 5 existing project AGENTS.md (propagation can't carry AGENTS).

## 2026-06-14 Gate's Python-test step fails a fresh project (unittest exits 5 on no tests)
**What happened:** an embedded project's very first gate FAILED on an empty project — the project-checks step ran `python -m unittest discover`, which on **Python 3.12+** exits code **5** ("NO TESTS RAN") instead of 0, so a brand-new, test-less Python project can never pass its own gate.
**Root cause:** the kit's App guidance (`user-notes.md`: "Python projects: python -m unittest discover tests") and the `gate.template.{ps1,sh}` FILL-IN example assume `unittest` returns 0 with zero tests — true pre-3.12, but 3.12 changed it to exit 5 (matching pytest), silently breaking the gate of every freshly-scaffolded Python App.
**Proposed fix:** guard the test run behind "do tests exist yet" — `find src -name 'test_*.py'` (sh) / `Get-ChildItem -Recurse -Filter test_*.py` (ps1) — and only invoke unittest when at least one test file is present; otherwise print "(no tests yet)" and pass cleanly. Proven in `an embedded project/tools/gate.{sh,ps1}`; graduate the guard into `tools/gate.template.{ps1,sh}` and fix the `user-notes.md` App line.
**Status:** OPEN — flow-back from an embedded project (rule 7); fix proven there but NOT yet in the kit template. Also still OPEN: propagate the **pre-commit** hook to projects (only pre-push propagates today).

## 2026-06-14 study of actualbudget/actual local-first synchronization and HLC
**What happened:** studied actualbudget/actual to evaluate its offline-first SQLite synchronization, Hybrid Logical Clock (HLC), and Merkle trie diffing logic for App-track local-first syncing.
**Root cause:** App track lacked a standardized local-first synchronization protocol, requiring developers to reinvent state replication and conflict resolution.
**Proposed fix:** ADAPT actual's HLC (`timestamp.ts`) and Merkle radix trie (`merkle.ts`) logic into a shared `@oasis/local-first-sync` library or generic skill in `app/packages/` for App-track projects.
**Status:** OPEN (study artifact created).

## 2026-06-14 study of actualbudget/actual core business logic separation
**What happened:** studied actual's monorepo code isolation (`loot-core`), which isolates SQL queries, preference engines, and business rules from the Svelte/Electron/Tauri UI wrapper.
**Root cause:** app templates have soft boundaries between Svelte UI code and Rust backend commands, making query/state logic leak.
**Proposed fix:** ADAPT the `#platform` and `#server` abstraction pattern into App-track architecture templates (`docs-template/core/app-architecture.md`) to enforce clean backend/worker layer isolation.
**Status:** OPEN (study artifact created).

## 2026-06-14 study of tranek/GASDocumentation ASC and AttributeSet separation
**What happened:** studied tranek/GASDocumentation to analyze C++ Gameplay Ability System (GAS) implementation, focusing on Actor-bound vs PlayerState-bound ASC layouts (Hero vs Minion topologies).
**Root cause:** Game track templates lack clear guidelines on ASC lifetime and persistence models, which leads to issues with attribute state loss on character respawn.
**Proposed fix:** ADAPT Hero (PlayerState-bound, initialized via `PossessedBy`/`OnRep_PlayerState`) vs Minion (Actor-bound) design guidelines into `docs-template/core/game-architecture.md`.
**Status:** OPEN (study artifact created).

## 2026-06-14 study of tranek/GASDocumentation C++ macro and replication helpers
**What happened:** studied tranek/GASDocumentation to analyze standard C++ helper macros (`ATTRIBUTE_ACCESSORS`) and RepNotify boilerplate for attribute replication.
**Root cause:** C++ boilerplate in C++ AttributeSets is high-overhead and error-prone for developers setting up new attributes.
**Proposed fix:** ADOPT the `ATTRIBUTE_ACCESSORS` definition and standard `DOREPLIFETIME_CONDITION_NOTIFY` / `OnRep` templates directly inside scaffolded C++ AttributeSet templates.
**Status:** OPEN (study artifact created).

## 2026-06-14 study of Qiskit/qiskit topological circuit decoupling
**What happened:** studied Qiskit/qiskit to evaluate node operation representation vs connection graph layout for Python-based simulation modeling.
**Root cause:** Python simulation layouts often tightly couple component physics to their topological neighborhood, making component reuse and graph optimization difficult.
**Proposed fix:** ADAPT Qiskit's decoupled architecture (standalone operation definitions mapped to an independent connection graph) into Python simulation track guidelines.
**Status:** OPEN (study artifact created).

## 2026-06-14 study of Qiskit/qiskit simulation parameters and backend abstraction
**What happened:** studied Qiskit's parameter expression mappings and unified backend runner interface to abstract solvers from model building.
**Root cause:** simulation solvers and mathematical parameter sweeps are typically monolithic, coupling physical models directly to numerical runners.
**Proposed fix:** ADAPT symbol-based parameter bindings and runner abstractions to separate physical definition from sweep execution in Python simulations.
**Status:** OPEN (study artifact created).

## 2026-06-14 study of FocusCookie/tauri-sqlite-example database migrations and frontend query boundaries
**What happened:** studied FocusCookie/tauri-sqlite-example to analyze SQLite integration in Tauri 2.0 apps, focusing on tauri-plugin-sql migrations and frontend-driven query execution boundaries.
**Root cause:** App templates lack a standard method for configuring local SQLite migrations and db wrappers at app startup.
**Proposed fix:** ADOPT Rust-side startup migrations via `tauri-plugin-sql` in Svelte/Tauri app templates; DECLINE frontend-driven raw SQL query strings, enforcing a backend command bridge instead.
**Status:** OPEN (study artifact created).

## 2026-06-14 study of filliperomero/InterfaceHero asynchronous UI asset loading and Common UI stack
**What happened:** studied filliperomero/InterfaceHero to evaluate asynchronous user interface asset loading using soft references (`TSoftClassPtr`) and activatable widget stack layouts.
**Root cause:** Game templates default to hard class references which force synchronous blocking asset loads at startup, causing frame hitches.
**Proposed fix:** ADOPT soft widget references (`TSoftClassPtr`) and asynchronous streamable asset loading via `UAssetManager::Get().GetStreamableManager().RequestAsyncLoad` in UI subsystems.
**Status:** OPEN (study artifact created).

## 2026-06-14 study of devbisme/skidl electrical rules checking and topological modeling
**What happened:** studied devbisme/skidl to analyze its Net-Pin-Part data schema and symmetrical pin conflict contention matrix for design rule checking (ERC).
**Root cause:** Python simulation solvers lack robust pre-flight checks, which causes execution failures to only trigger late in simulation runs.
**Proposed fix:** ADOPT symmetrical contention matrices (`defaultdict` mappings) and pre-simulation verification validation gates (ERC checks) in physical simulation projects.
**Status:** OPEN (study artifact created).

## 2026-06-14 study of pubkey/rxdb reactive queries and signals garbage collection
**What happened:** studied pubkey/rxdb to analyze fine-grained reactive queries, state-management wrappers, and automatic GC cleanup of database subscriptions using `FinalizationRegistry`.
**Root cause:** local-first app queries rely on manual subscription cleanup, which is prone to memory leaks if components unmount prematurely.
**Proposed fix:** ADOPT `FinalizationRegistry` and `WeakRef` patterns in Custom Reactivity bridges to automatically clean up database subscriptions when UI state variables go out of scope.
**Status:** OPEN (study artifact created).

## 2026-06-14 study of Hazelight/Docs-UnrealEngine-Angelscript scripting and memory boundaries
**What happened:** studied Hazelight's Docs-UnrealEngine-Angelscript to evaluate AngelScript as an alternative text-based scripting framework in game engines, and its object pointer abstraction patterns.
**Root cause:** Game development options default to visual Blueprints or heavy C++, leading to merge conflicts or raw pointer crash hazards.
**Proposed fix:** ADAPT text-based scripting concepts (AngelScript/Lua) and C++ reference pointer wrappers to safeguard visual designers and speed up gameplay iterations.
**Status:** OPEN (study artifact created).

## 2026-06-14 study of PyO3/pyo3 high-performance language bridges and thread safety
**What happened:** studied PyO3/pyo3 to analyze Rust-to-Python language bridges, zero-overhead memory pointer boundaries (`Bound<'py, T>`), and releasing the Global Interpreter Lock (GIL).
**Root cause:** Python simulation solvers suffer from single-threaded speed limits, making Monte Carlo sweeps slow.
**Proposed fix:** ADOPT PyO3 native Rust modules for performance-critical simulation logic, and release the GIL via `allow_threads` to execute parallel loops.
**Status:** OPEN (study artifact created).



