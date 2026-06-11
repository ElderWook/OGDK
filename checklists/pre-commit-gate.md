# Pre-commit gate (generic — project AGENTS.md is authoritative)

- [ ] `tools/verify-file-integrity.{ps1,sh}` passes (no NUL-fill / truncation corruption)
- [ ] `tools/check-reference-coverage.{ps1,sh}` — no FAILs; STALE pages updated or justified in STATUS
- [ ] Verification gate commands from AGENTS.md all pass
- [ ] Docs updated in the SAME commit as the code they describe
- [ ] No secrets, no scratch/binary artifacts staged
- [ ] One concern per commit; message says why, not just what
- [ ] If sync/data behavior changed (app) → parity tests updated
- [ ] If a gameplay system changed (game) → its GF smoke test still passes; perf note
      still accurate
- [ ] Session ending? Run the session-end skill (STATUS.md handoff)
