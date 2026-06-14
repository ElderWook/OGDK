# Start Building — for people with ideas, not credentials

You don't need to know how to code to use this. You need an idea and about ten
minutes. This kit's job is to be the **guardrails** so you can move fast and learn how
software actually works *by building something real* — not by reading a textbook first.

The whole thing is six words: **idea → scaffold → plan → build → gate → save.**
That's the entire loop. Everything else in this repository is machinery that runs
quietly in the background and only speaks up if it catches a real problem.

---

## Step 0 — One-time setup (one command)

Open a terminal **inside the kit folder** and run:

```
# Windows (plain PowerShell):
.\tools\bootstrap.ps1

# Linux / macOS:
./tools/bootstrap.sh
```

`bootstrap` checks that git knows who you are, proves the kit works on your machine,
and tells you the exact next command. If it stops, it tells you precisely what to fix
in plain language. (If you'd rather follow the long, hand-held version with pictures of
every step, that's [GETTING-STARTED.md](./GETTING-STARTED.md) — but most people won't
need it.)

---

## Step 1 — Scaffold your idea

```
# Windows:
.\tools\new-project.ps1 -Name MyIdea -Type App

# Linux / macOS:
./tools/new-project.sh -n MyIdea -t App
```

It will ask **one** question — what *shape* your app is:

| You want... | Pick |
|-------------|------|
| something that works on your computer (most first apps) | **E — single desktop app** |
| something that also works on your phone / other devices | **A — local-first, multi-device** |
| a website or web service | **B or D** |
| a small command-line tool | **C** |

Don't overthink it — pick **E** if unsure; you can grow into the others. The scaffolder
creates a clean project with labelled, empty rooms (`src/core`, `src/store`, ...) for
your AI agent to fill in. Each room has a short note saying what it's *for*.

---

## Step 2 — Open it with your AI agent and say two words

Open the new project folder with your AI assistant (Claude, etc.) and type:

```
run session-start
```

That makes the agent read the project's rules and get its bearings. Then just **talk to
it about your idea.** "I want an app that tracks my plant watering schedule." It will
write a short plan first (so you both agree before any code), then build.

**Tell it you're learning.** Say `use explain-mode` and the agent will narrate *why* it
puts each piece where it does — what the "core" is, why some code never touches your
files directly, why every piece gets a test. That running commentary is how you'll
absorb how programs are actually structured, without a single tutorial.

---

## Step 3 — The one rule: the gate

Before saving a milestone, the agent (or you) runs:

```
# Windows:  .\tools\gate.ps1      Linux/macOS:  ./tools/gate.sh
```

If it prints **GATE PASSED**, your project is healthy and safe to save. If it doesn't,
*don't save* — the gate just caught something, and it'll tell you what. That's the whole
discipline. Green means go.

---

## Step 4 — Two buttons that mean you can never really break anything

- **Save right now** (phone's ringing, agent's about to time out):
  `.\tools\checkpoint.ps1` (Linux/macOS: `./tools/checkpoint.sh`, or double-click
  `tools\checkpoint.bat` on Windows). It saves everything instantly.
- **Help, it's tangled, get me back to safe:**
  `.\tools\rescue.ps1` (Linux/macOS: `./tools/rescue.sh`). It shelves any mess and puts
  you back at your last good save **without deleting anything**.

Between *save* and *rescue*, you genuinely cannot lose work. That safety net is the
point — it's what lets you experiment fearlessly.

---

## Step 5 — When something confuses or breaks you, say so (10 seconds)

```
.\tools\report-snag.ps1 "the gate failed after I changed the colors"
```

It prints a tidy note you can paste into `LESSONS.md` (or just hand to whoever gave you
the kit). Your confusion is *useful data* — it's how the kit gets friendlier for the
next person. You being new is the best test it has.

---

## What you'll understand by the end

By the time your first project runs, you'll have felt — not memorized — the ideas that
underpin most software: keeping the *thinking* part of a program separate from the parts
that touch files and screens; why every piece gets a test; why changes get saved in
small, checkable steps. When you're ready to go deeper, the same ideas are written down
in [app/APP-ARCHITECT.md](./app/APP-ARCHITECT.md) and the kit's code conventions. But
build first. Understanding comes from the doing.

Welcome aboard. Go make the thing. 🛠️
