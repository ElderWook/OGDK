# NOTICES — third-party attributions

> Copy this to `NOTICES.md` at the project root (or `docs/`) the moment the project **bundles or
> redistributes** any third-party asset: a vendored library, font, model, icon set, sample data, etc.
> One row per asset. Ship the license text alongside the asset (a `LICENSES/` or `*/fonts/*-OFL.txt`
> file) and point to it here. Original work does **not** go here.

## When this is required
- You vendor a JS/CSS/font/binary into the repo (e.g. `three.min.js`, a `.woff2`, a `.glb`).
- You copy code or assets from another project (even permissively licensed — attribution still owed).
- You ship a build that embeds any of the above (e.g. a desktop app, a Steam build, a web bundle).

You do **not** need an entry for: dependencies pulled at build time by a package manager (those are
covered by the lockfile + the dependency's own license), or for ideas/algorithms you re-implemented
yourself (those are tracked as `Source-License:` lines in `docs/LESSONS.md`, ideas-only).

## Assets bundled in this project

| Asset | Version | License | Why bundled | License file |
|---|---|---|---|---|
| _e.g._ Three.js | r128 | MIT | offline 3D, no CDN dependency | `vendor/three.LICENSE` |
| _e.g._ Rye (font) | — | SIL OFL 1.1 | display type, offline | `assets/fonts/Rye-OFL.txt` |

## Strong-copyleft reminder
GPL/AGPL/LGPL assets have shipping obligations. If an asset is strong-copyleft (GPL/AGPL), do **not**
bundle it into a proprietary/closed build — re-implement the idea instead and record it as an
ideas-only `Source-License:` line in `docs/LESSONS.md`. LGPL/MPL (weak-copyleft) can be bundled but
carries relink/source-availability obligations — note them in the row above.

## Original work
Everything else in this repository is original work for the Oasis fleet.
