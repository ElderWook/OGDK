# App track — web / local / mobile stack

Proven in the **origin app project** (a private Oasis production app). One codebase, three surfaces:
desktop (Tauri), mobile (PWA/wrapped web), and an optional relay server for
device-to-device sync. Local-first by default.

## Stack

| Layer | Choice | Why |
|-------|--------|-----|
| UI | Svelte + Vite + Tailwind | small bundles, no VDOM overhead, fast dev loop |
| Desktop shell | Tauri | tiny installers, native FS access, auto-updater |
| Mobile | second Vite app sharing `src/shared` | one logic codebase, platform bridges |
| Data | SQLite, single file, local-first | user owns the data; atomic temp-file+rename writes |
| Sync | relay server (Node) + master/client model | desktop-authoritative; works without cloud |
| Tests | node test runner: unit + parity + live e2e | parity tests are the sync safety net |

## Architecture invariants (the proven set — start every app project with these)

1. **Shared-core layout.** All logic in `src/shared/`; platform apps consume it via
   aliases (`$shared`, `$platform`). Platform differences are injected through a
   `$platform` bridge module — never `if (isMobile)` checks inside shared code.
2. **Never duplicate shared code into a platform tree.** The only platform-specific
   files: bridges, platform services (updates, sync transport), platform stores.
3. **Shared modules importable by node tests must have no bundler-specific imports**
   (`?raw`, `?url`).
4. **Exact arithmetic for anything that matters.** Money = integer cents end-to-end;
   round per line, then sum. Never floats for currency.
5. **Durable writes.** Atomic file replace (temp + rename), serialized through one
   process; rolling backups on launch.
6. **Referential integrity on.** Foreign keys enforced; versioned, non-destructive
   migrations; per-item transactions on import — failed items reported, not dropped.
7. **One authority per datum.** In sync, decide which node is authoritative for each
   record type and enforce it (e.g. document numbers are desktop-authoritative).
8. **Any change to sync behavior updates the parity test in the same commit.**

## Verification gate

`npm test` (all green) · `npm run build` for every target (desktop, mobile).

## packages/ (rule of two)

Empty until a second project needs a module. Extraction queue from the origin app, in order
of generality: `money-cents` → `atomic-sqlite-persist` → `migrations-runner` →
`pdf-engine` (theme/primitives + generators split) → sync parity-test harness.

When extracting: copy the module + its tests, remove app-specific imports, give it a
README with the invariant it enforces.
