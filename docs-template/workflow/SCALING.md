# Scaling — how plans, studies, and lessons grow without rot

As a project (and the fleet) matures, plans, study material, and lessons pile up. This is
the convention that keeps that growth navigable: **tracking is generated from data, not
hand-maintained**, and every artifact type has three tiers — a small **working buffer**,
a **generated manifest/index**, and a **cold archive**. You read manifests and rollups,
never scroll a giant file.

## The growth invariant

You should be able to add the 100th plan, 50th study, or 30th lesson and still answer
"what's the state?" in one generated rollup — because the working buffers stay short
(cold content is archived), the indexes are generated (scale-free), and the source of
truth is data.

## Studies (`study-repo/`)

- **Clones** are shallow (`git clone --depth 1`), live OUTSIDE all kit repos in
  `study-repo/study/<name>`, and are **deletable after the study** — the manifest, not
  the clone, is the durable record. Storage stays bounded as study count grows.
- **Manifest** = `study-repo/STUDY-INDEX.md`, **generated** by
  `check-study-licenses --write` (license id, class, fold-in status, source). Regenerate
  any time; never hand-edit. Scales to any number of clones.
- **Findings** land in the TARGET repo's `docs/LESSONS.md` as the project-applicable
  adoption, each with a `Source-License:` line. Study **provenance** (what/where/license)
  lives in the manifest — it is NOT duplicated as OPEN process-lessons (that conflation
  is what inflates a LESSONS buffer).
- **Restriction:** strong-copyleft (GPL/AGPL) = ideas-only; enforced by
  `check-study-licenses` (FAIL on a strong-copyleft source with a fold-in).

## Plans (`docs/plans/`)

- **Lifecycle:** a plan is active in `docs/plans/` → on completion it graduates (content
  to `core/` + a `docs/reference/` page) → then moves to `docs/plans/archive/`.
  No reference page, no archive.
- **Index:** the `STATUS.md` "Active plans" table is the live index; archived plans are
  cold history. As plans grow, only active ones stay in STATUS — the archive holds the
  rest. (Future: a generated plan index from the dir + STATUS.)
- One concern per plan; rejected-options sections keep cuts cut.

## Lessons (`docs/LESSONS.md`)

- LESSONS.md is the **OPEN process-friction buffer only** — things the system didn't
  prevent, awaiting `kit-retro`. It is NOT a study log (studies → the manifest above).
- **Lifecycle:** OPEN → `kit-retro` codifies it (rule / script / doc) → mark CODIFIED →
  periodically move CODIFIED entries to `docs/LESSONS-ARCHIVE.md` so the buffer stays
  short and the OPEN count stays meaningful.
- `check-reference-coverage` WARNs at 5 OPEN — that's the trigger to run kit-retro and
  archive the codified ones.

## Fleet tracking (rollups)

- `STATUS.md` per repo = the human handoff (one screen). `fleet-status` = the git rollup.
  `fleet-work` (planned) = the work rollup — open-lessons + "Next up" + active plans —
  generated from STATUS + LESSONS, so the cross-fleet view scales without hand-editing.
- The fleet dashboard is generated from the same data (planned), not hand-coded.
- A small machine-readable block per repo (the **substrate**) is the future single source
  the generators read.

## Storage discipline

- **Text** (plans / docs / lessons / manifests): git-tracked, cheap — archive, never delete.
- **Binaries** (UE `.uasset`/`.umap`, Blender `.blend`, textures, models): **git-lfs**
  (`.gitattributes`), never raw in git (permanent repo weight). Keep
  `Binaries/ Intermediate/ Saved/ DerivedDataCache/ .vs/` gitignored.
- **Study clones:** shallow + outside repos + deletable; the manifest is the record.
- **Engine:** pinned (AGENTS §Engine), downloaded not cloned; upgrades are plans.

## Related

[GIT-LIFECYCLE.md](./GIT-LIFECYCLE.md) (the checkpoint map) · the reference graduation
rule in [../reference/COVERAGE.md](../reference/COVERAGE.md).
