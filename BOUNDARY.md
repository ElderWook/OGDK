# BOUNDARY.md — what may enter this kit, and what never does

The kit is shared. Projects are not. This page is the membrane between them, in
both directions. It is enforced socially (PR review, this page) and mechanically
(`check-kit-docs` check 8 scans tracked kit files against each owner's gitignored
`tools/PRIVATE-MARKERS.list`).

## Inbound — what MAY enter the kit

- **Generic process**: rules, conventions, scripts, skills, templates — anything
  that would be true for a project you've never seen.
- **Genericized lessons**: a LESSONS entry may graduate from a project repo to the
  kit only after scrubbing — no project names, no paths containing usernames, no
  domain specifics that identify the project. ("A truncated script sat committed
  undetected" graduates; the name of the repo it happened in does not.)
- **Anonymized findings** from repo-study: ADOPT/ADAPT/DECLINE/CONFIRMS verdicts
  describing a practice, never the studied repo's code (license discipline).

## Inbound — what NEVER enters the kit

- **Project code or assets.** Code reaches the kit only through the rule of two
  (a second concrete consumer) and only as a deliberate extraction, never as a
  copy-paste during kit work.
- **Project names without the owner's consent.** Your own projects included —
  the kit refers to "the hardware project", "the origin app", etc.
- **Anything from a collaborator's repos.** A collaborator working in the kit
  must never find their project's IP, names, or specifics committed here — not
  in LESSONS, not in examples, not in commit messages. Project LESSONS stay in
  project repos; only the scrubbed generic form may graduate.
- **Personal data**: usernames, emails, machine paths, local config. That lives
  in your gitignored `user-notes.local.md`. Python compiled bytecode files
  (`.pyc` / `__pycache__`) are also barred, as they can leak absolute directory
  paths from the compilation machine; these are ignored in `.gitignore`.

## Outbound — what never leaves the kit toward a project

Nothing is restricted outbound; the kit exists to be copied from. The one rule:
propagation goes through `propagate-tools` (SHA-verified) or the scaffolder, not
ad-hoc copying — so a corrupted or stale kit file can't silently spread.

## The mechanical guard

Each kit owner/collaborator maintains `tools/PRIVATE-MARKERS.list` (gitignored —
the list itself is private): usernames, emails, home paths, project codenames,
collaborator names. `check-kit-docs` check 8 FAILS the gate if any marker appears
in a tracked kit file, and reports only the marker's index — never its text — so
check output stays shareable. Seed yours when you first clone (the file header in
a fresh list shows the format); a missing list is a WARN, not a pass.

## History note (decision of record, 2026-06-12)

Kit git history predating the privacy sweep contains early project context. The
repository was made public on 2026-06-12 with the historical commits accepted as-is
under public visibility (private markers are fully scrubbed from the active working
tree but remain in historical commit diffs). Any future commits must strictly adhere
to the safety boundaries defined here.
