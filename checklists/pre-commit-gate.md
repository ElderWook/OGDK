# Pre-commit gate (generic — project AGENTS.md is authoritative)

- [ ] **`tools/gate.{ps1,sh}` exits 0** (chains: integrity → coverage → project tests/builds)
- [ ] Docs updated in the SAME commit as the code they describe
- [ ] No secrets, no scratch/binary artifacts staged
- [ ] One concern per commit; message says why, not just what
- [ ] If sync/data behavior changed (app) → parity tests updated
- [ ] If a gameplay system changed (game) → its GF smoke test still passes; perf note
      still accurate
- [ ] Session ending? Run the session-end skill (STATUS.md handoff)
