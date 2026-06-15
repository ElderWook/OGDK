# Python-simulation track — conventions

> For any project whose heart is a **pure-Python simulation or rules engine** (signal/
> physics models, chemistry advisors, DSP, geometry/CAM math). Sits alongside the app
> and game tracks; the [CODE-CONVENTIONS](../CODE-CONVENTIONS.md) still apply.
> Distilled from external study (Qiskit, PyO3, skidl) — 2026-06-14.

## 1. Decouple the model from the topology

Define **what each component does** (its operation/physics) separately from **how
components are wired** (the connection graph). A standalone operation definition mapped
onto an independent graph keeps components reusable and the graph optimizable; physics
coupled to its neighbourhood is the thing that rots.

## 2. Separate the model from the runner

Parameters are **symbols**, not hard-coded numbers; bind them at run time. Put numerical
execution (sweeps, Monte Carlo, solvers) behind a **runner/backend interface** so the
physical model never imports the sweep loop. Swapping runners (single-shot, batch,
parallel) must not touch the model.

## 3. Fail fast: pre-simulation validation gates

Before a long run, validate structure cheaply — an **ERC-style check** (e.g. a
symmetrical contention matrix over connections, range/units checks, no dangling nodes).
A run that was going to fail should fail in milliseconds at the gate, not minutes in.

## 4. Keep the model portable; escape to native only behind the interface

The model stays **pure-Python / stdlib** for portability and exact test vectors. When a
hot loop dominates (Monte Carlo, large sweeps), an **optional native module** (e.g.
Rust via PyO3, releasing the GIL for parallel loops) may sit behind the same runner
interface — opt-in, never a default, never required to read or test the model.

## Verification

- The model runs and its tests pass with **zero native dependencies**.
- Validation gate rejects a known-bad input in a unit test.
- If a native runner exists, it produces **identical results** to the pure-Python one on
  shared test vectors (parity, like the cross-platform twin rule for tools).
