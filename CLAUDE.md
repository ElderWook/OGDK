# OGDK — Claude Code entry

All rules live in **[AGENTS.md](./AGENTS.md)** (model-agnostic). Read it in full before
changing the kit — changes here multiply into every future Oasis project.

Working as an agent here? The **Working here as an AI agent** section of AGENTS.md is
binding: session-start `verify-path-health` + `sync-repo`, never run git through a
Cowork mount, and never push or force-push from a sandbox.

Windows: run `.\tools\verify-path-health.ps1` before any file writes.
