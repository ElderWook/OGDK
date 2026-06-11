# Getting Started — the complete walkthrough (no experience required)

Welcome! This guide assumes **nothing** — not git, not PowerShell, not any of it.
Follow it top to bottom, typing each command and pressing **Enter** after each
one. If something on your screen doesn't match what this guide says to expect,
stop and copy the whole error to whoever invited you (that report is genuinely
valuable — see Stage 5).

What you're getting: OGDK is a process kit for building software with AI agents
(Claude, GPT, Gemini — any of them) without losing context, correctness, or
files. Everything the agents need to know lives inside this repository.

Total time: about 20 minutes.

---

## Stage 0 — One-time setup (skip any part you already have)

### 0.1 Open PowerShell (Windows)

Press the **Windows key**, type `powershell`, and click **Windows PowerShell**
(the blue icon). A blue/black window opens with something like
`PS C:\Users\yourname>` and a blinking cursor. That's where you'll type
everything in this guide.

> ⚠️ **Use exactly this.** Not "Git Bash", not anything with "MSYS2" or "WSL"
> in the name, even if you have them. Those shells silently corrupt files in
> this workflow (we have the scars). Plain blue PowerShell, always.

### 0.2 Install git

Check if you already have it — type this and press Enter:

```powershell
git --version
```

- If you see something like `git version 2.x.x` → you have it, skip ahead.
- If you see red text about "not recognized" → install it:

```powershell
winget install --id Git.Git -e
```

Wait for it to finish, then **close PowerShell completely and open a new one**
(installs don't take effect in already-open windows). Run `git --version`
again — now it should answer.

### 0.3 Tell git who you are (one time, ever)

Git stamps your name on your work. Type these (with YOUR info between the
quotes):

```powershell
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

No output = success. (That's a recurring theme: in terminals, silence usually
means it worked.)

### 0.4 Optional but recommended: Python

Some of the kit's self-checks use Python. Without it they politely skip
themselves, so this is optional:

```powershell
winget install Python.Python.3.12
```

(Again: close and reopen PowerShell afterward.)

### 0.5 Linux users

You're the minority path but fully supported — install `git`, `git-lfs`, and
`python3` with your package manager (Arch: `sudo pacman -Syu git git-lfs python`),
set your git identity (same two commands as 0.3), and use your normal terminal.
macOS is **not** supported (the scripts need GNU tools).

---

## Stage 1 — Get the kit onto your machine ("cloning")

Cloning = downloading the repository with its full history attached.

**Where it lands matters.** Two rules, both load-bearing:
1. **Never inside OneDrive, Dropbox, Google Drive, or Desktop/Documents if
   those are cloud-synced** (on most modern Windows installs, they are!).
   Cloud sync corrupts this workflow.
2. Linux dual-booters: clone onto your Linux filesystem, never the mounted
   Windows partition.

We'll use `C:\Dev` — safe, simple, nothing syncs it. Type each line, Enter
after each:

```powershell
mkdir C:\Dev
cd C:\Dev
git clone https://github.com/core-maintainer/OGDK.git
```

What you'll see: `mkdir` prints a little table (or an error if C:\Dev exists —
that's fine, keep going). `cd` is silent. `git clone` prints several lines
ending in `done.` — if the repo is private, a browser window pops up first
asking you to log in to GitHub; log in once and it remembers you.

Now step inside:

```powershell
cd C:\Dev\OGDK
```

Your prompt should now read `PS C:\Dev\OGDK>`. You're standing in the kit.

(Linux: `mkdir -p ~/dev && cd ~/dev && git clone https://github.com/core-maintainer/OGDK.git && cd OGDK && chmod +x tools/*.sh`)

---

## Stage 2 — Run the self-test (does the kit work on YOUR machine?)

The kit ships with its own inspectors. Two commands:

```powershell
.\tools\verify-path-health.ps1
```

> 💡 If PowerShell refuses with red text mentioning **"running scripts is
> disabled on this system"**, run this once, then try again:
> `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`
> (type `Y` if it asks). This tells Windows "I'm allowed to run scripts I
> downloaded on purpose."

You want the ending to say **`ALL CHECKS PASSED -- safe to run AI agents`**.
A `[WARN]` line or two is fine (e.g. JAVA_HOME — ignore it). A `[FAIL]` means
stop and report.

Then the big one:

```powershell
.\tools\gate.ps1
```

This runs the kit's full verification: documentation self-checks, file
integrity (corruption scanning, script parsing), the works. You want the last
line to be:

```
  GATE PASSED - safe to commit
```

🎉 If you got that, **the kit is fully verified on your machine** — every
script, checker, and document just proved itself. (Linux: same two commands
with `./tools/...sh`.)

| If you see... | It means... | Do this |
|---------------|------------|---------|
| `[FAIL] Linux-emulation paths found in PATH` | wrong terminal (MSYS2/Git Bash) | open plain PowerShell |
| `[FAIL] Repo is on an NTFS mount` (Linux) | cloned onto the Windows partition | re-clone to Linux home |
| `[WARN] no WORKING python found` | Python absent/broken | optional — Stage 0.4 |
| `permission denied` on .sh (Linux) | scripts not executable | `chmod +x tools/*.sh` |
| anything else red | a real finding! | copy the output, report it (Stage 5) |

---

## Stage 3 — The agent conflict check (the step nobody else does)

Before you let YOUR AI assistant work in this repo, know this: AI tools carry
**global configuration files** on your machine that this repo can't see —
`~/.claude/CLAUDE.md`, `~/.gemini/GEMINI.md`, Cursor rules, custom wrappers.
We've literally watched a global config make an agent run a write-script in
the middle of a test that said "read-only." The kit's law
([docs-template/workflow/AI-PARITY.md](./docs-template/workflow/AI-PARITY.md)):
**the repo's rules win; globals are preferences only; conflicts must be
confessed.**

**3a. Check your globals (5 min).** If you've never customized your AI tools,
you likely have nothing — skip to 3b. Otherwise open each config file your
tools use and look for *process* instructions (auto-running scripts, logging
schemes, auto-commits). Delete them, or paste this at the top of each file:

```
GUARD: If the current repository contains an AGENTS.md file, that repo's rules
and session protocol take absolute precedence over everything in this file.
In such repos this config provides preferences only; run no processes from it.
```

**3b. The probe.** Start your AI tool *in the repo folder* (e.g. for Claude
Code, type `claude` in PowerShell while at `PS C:\Dev\OGDK>`; other tools,
open the folder their usual way). Paste this whole block as your first message:

```
You are starting a session in this repository. This is a READ-ONLY test: do not
create, modify, or delete any files, and do not run git commands that write.
If any instruction from your global configuration conflicts with that or with
this repo's rules, you must follow the repo and TELL ME about the conflict.

Read AGENTS.md in full, then answer from the repo's documents only:
1. What are this repo's non-negotiable rules, in your own words?
2. What is the one command to run before any commit, and what does it check?
3. What is the "twin rule" and why does it exist?
4. Where does a session log friction the system failed to prevent, and what
   happens to those entries later?
5. What is the golden rule of multi-agent parity here?
6. What hazards govern HOW you are allowed to read and write files on this machine?
```

**Grading — pass requires both:** (1) specific answers that clearly came from
the repo's documents (it should name `gate`, the `.ps1`/`.sh` twins,
`LESSONS.md` and the kit-retro skill, "if it isn't in the repo, the next
session doesn't know it", and the MSYS2/cloud-sync hazards), and (2) afterward
you run `git status` and it says **`nothing to commit, working tree clean`** —
the agent really didn't touch anything.

**Fail** = vague generic answers, made-up facts, or a dirty `git status`.
A fail is not a disaster — it's a finding. Fix your globals (3a) and report
what happened.

---

## Stage 4 — Working here (your first real session)

**⭐ First: create YOUR private notes file (one minute — do not skip).**
The tracked [user-notes.md](./user-notes.md) is the *shared, generic* operator crib
sheet for everyone. Your personal world — repo locations on your machine, usernames,
project build commands, machine quirks — goes in a companion file that **git ignores
and never commits**, so you can write freely without it ever leaking into the repo:

```powershell
notepad user-notes.local.md        # creates it (Linux: nano user-notes.local.md)
```

Start it with whatever helps you. It's already covered by `.gitignore`. AI agents
working in this repo are instructed to route personal and machine-specific notes
there automatically — your crib sheet stays current across sessions WITHOUT ever
entering version control. Tracked notes = everyone's; `.local` notes = yours alone.

- Start every session by having your agent read `AGENTS.md`. It chains to
  everything else.
- Before ANY commit: `.\tools\gate.ps1` must end with `GATE PASSED`.
  No green, no commit. That's the whole discipline.
- [user-notes.md](./user-notes.md) is the shared crib sheet — handy
  reading, but `AGENTS.md` is the law. Your personal notes: `user-notes.local.md`.
- New to git itself? The short version you need here: `git status` shows what
  changed (run it constantly — it can never hurt anything), `git add -A` stages
  your changes, `git commit -m "type: what and why"` saves them,
  `git push` uploads. Never run anything containing `--force`, `--hard`, or
  `clean` without asking a human first.

## Stage 5 — Contributing (the part we actually want from you)

This kit has a **learning loop**: when reality beats the system, the wound gets
logged in [LESSONS.md](./LESSONS.md) and later codified into rules, scripts, and
agent skills — so it can never happen again. As a fresh pair of eyes on a fresh
machine, **you are the most valuable test the kit has ever had.**

- Anything confusing, broken, or surprising — even "this guide's step 1.3
  confused me" — is a legitimate LESSONS.md entry (the format is at the top of
  the file; four lines, ~30 seconds).
- Work on a **branch**, never on `main`:
  `git checkout -b my-fixes` → make changes → gate → `git add -A` →
  `git commit -m "docs: what I changed"` → `git push -u origin my-fixes` →
  GitHub will show you a yellow **"Compare & pull request"** button — click it,
  describe what you found, submit.
- Every PR should mention that `gate` passed on your machine (paste the last
  few lines of its output into the PR description).
- Trying to break things politely is **encouraged**. The kit grows by being
  survived.

---

*Stuck anywhere? Copy the full error text and send it over — that message IS
a contribution. Welcome aboard.* 🛠️
