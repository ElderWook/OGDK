# Code Conventions — annotated, modular, generation-ready

These conventions make code legible to any human or AI session with zero context —
the code-level twin of the docs session chain. They are language-agnostic; every
language binds them with its native idioms. The kit's canonical exemplar
(`app/exemplar/` in the kit repo) demonstrates the bar.

## 1. The annotation standard

Every module (file/class/significant function) opens with a header block using
these tags — comments in whatever syntax the language uses:

| Tag | Answers | Required on |
|-----|---------|-------------|
| `@intent` | why this module exists; what problem it owns | every module |
| `@flow` | how data moves through it (in → transform → out) | modules with logic |
| `@boundary` | what it MAY depend on; who MAY depend on it | every module |
| `@invariant` | what must always hold (precision, ordering, durability) | wherever one exists |
| `@risk` | known sharp edges, deferred hazards | as discovered |
| `@todo` | planned work, with enough context to action cold | as needed |

Rules: annotations describe the PRESENT (todos excepted) — stale annotations fail
review like stale docs fail the coverage gate. One lie in an annotation costs more
than ten missing ones; when behavior changes, the header changes in the same commit.

## 2. Module shape

- **One concern per module.** If `@intent` needs the word "and", split it.
- **Dependencies are declared, directional, and minimal.** `@boundary` is the
  contract; an import not covered by it is a design change, not a convenience.
  Dependency direction within a layer points ONE way (the game track's
  Game→Features→Core rule is the universal pattern).
- **Composition lives at the edge.** One composition root wires modules together;
  modules never construct their own dependencies (inject them) — this is what makes
  every module testable alone and every skeleton portable.
- **Pure core, effectful shell.** Logic that can be pure (math, transforms,
  decisions) is pure and dependency-free; I/O, clocks, randomness, and platform
  calls live in thin adapter modules at the boundary. (This is why the hardware
  project's math survived engine-free into firmware, and why game logic survives
  engine ports.)

## 3. The non-negotiables (any language, any combination)

1. **Exact arithmetic for things that matter** — money is integer minor-units
   end-to-end; round at defined points only; never floats for currency.
2. **Durable writes** — state that matters is written atomically (temp + rename or
   transactional store); a crash mid-write must never yield a half-file.
3. **Errors are policy, not improvisation** — each module's failures either return
   typed results or raise; pick per module, write it in the header, never both.
4. **Every module ships with its test** — the test file mirrors the module name;
   pure-core modules get exhaustive tests (they're cheap), adapters get contract
   tests. Untested modules don't graduate to reference pages.
5. **No hidden state, no hidden config** — configuration enters at the composition
   root and is passed down; modules reading globals/env directly are adapters and
   say so in `@boundary`.

## 4. Generated skeletons (the language policy)

The kit does NOT store per-language boilerplate — stored skeletons rot, and
generating them is what AI sessions are for. Instead:

- When an operator picks features + a language, the session **generates the
  skeleton fresh**: APP-ARCHITECT (app track) or the track's STACK doc chooses the
  modules; THIS document governs their shape; the exemplar sets the quality bar.
- Every generated file opens with the §1 annotation header, already filled in.
- Generated skeletons include the test files and a composition root, compile/run
  empty, and pass the gate before any feature code lands.
- If one preset gets generated repeatedly and stabilizes, it MAY graduate to a
  stored template — rule of two, like everything else.

## 5. Review heuristics (what gate scripts can't check, humans/agents must)

- Can a stranger state each module's job from its header alone? (If not: header.)
- Does any module know who calls it? (It shouldn't.)
- Could the pure core run on a different platform unchanged? (It must.)
- Is there exactly one place where the wiring happens? (There should be.)
