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

> ⚠️ **Important:** The email address you use here **must be registered and verified** on your GitHub account (under **Settings → Emails** on github.com). If you want to keep your personal email private, you can use your GitHub-provided `noreply` email address.

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

> 💡 **Placeholder Alert:** In the commands below, replace `core-maintainer` with the actual GitHub organization or username hosting your repository (e.g., `ElderWook` or whoever invited you).

```powershell
mkdir C:\Dev
cd C:\Dev
git clone https://github.com/core-maintainer/OGDK.git
```

What you'll see: `mkdir` prints a little table (or an error if C:\Dev exists —
that's fine, keep going). `cd` is silent. `git clone` prints several lines
ending in `done.` — if the repo is private, a browser window pops up first
asking you to log in to GitHub; log in once and it remembers you. (If the repository is private, make sure you have accepted the GitHub invitation link first!)

Now step inside:

```powershell
cd C:\Dev\OGDK
```

Your prompt should now read `PS C:\Dev\OGDK>`. You're standing in the kit.

(Linux: `mkdir -p ~/dev && cd ~/dev && git clone https://github.com/core-maintainer/OGDK.git && cd OGDK && chmod +x tools/*.sh` — replacing `core-maintainer` with the actual owner/org name.)

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

**⭐ Your private notes file already exists — go claim it.**
When you ran `verify-path-health` in Stage 2, the kit auto-created
`user-notes.local.md` for you (you saw the `[INIT]` line). That file is **git-ignored
and never commits** — it's where YOUR personal world lives: repo locations on your
machine, usernames, project build commands, machine quirks. The tracked
[user-notes.md](./user-notes.md) stays generic for everyone; the `.local` file is
yours alone. Open it now and fill in your repo paths:

```powershell
notepad user-notes.local.md        # Linux: nano user-notes.local.md
```

AI agents working in this repo are instructed to route personal and machine-specific
notes there automatically — so your crib sheet stays current across sessions WITHOUT
ever entering version control. Tracked notes = everyone's; `.local` = yours alone.

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

### 4.1 Daily Session Lifecycle

To keep multi-machine environments in lockstep and prevent work loss due to AI agent crashes or limits, we use the following strict pipeline:

1. **Session Start (Safe Arrival):**
   Run the sync check before touching any code:
   ```powershell
   .\tools\sync-repo.ps1
   ```
   * **What it does:** Fetches updates, fast-forwards if safely behind, and **stops** with instructions if there are conflicting commits or uncommitted/in-flight files from another machine.
   
2. **Panic Saves (Checkpoints):**
   If you need to step away, or if your AI agent is running low on message limits, save your progress:
   ```powershell
   .\tools\checkpoint.ps1 "wip: briefly describe what you did"
   ```
   * **What it does:** Stages all files, commits a local backup as `wip: ...`, and attempts to push. Even if push fails (e.g. offline), your local history is completely safe.
   * **Shortcut:** You can double-click `tools/checkpoint.bat` from File Explorer to trigger a panic save without using PowerShell.

3. **Session End (Pre-Commit Gate):**
   Before you commit any milestone:
   ```powershell
   .\tools\gate.ps1
   ```
   * **What it does:** Chains file integrity, reference documentation coverage, tests, and builds. **You must get a `GATE PASSED` to commit or push.**

### 4.2 Handling Git Conflicts on Kit Tools (The "Kit-Files Rule")

Since tool scripts (like `verify-path-health.ps1`, `gate.ps1`, `sync-repo.ps1`) are propagated from the central kit, they are not standard application code. If you encounter conflicts in `tools/*` when pulling:
1. Prefer the local version to finish the merge:
   ```powershell
   git checkout --ours tools/KIT-VERSION
   git checkout --ours tools/test-hostile-env.sh
   # (Do the same for other conflicting files under tools/*)
   git add -A
   git commit -m "chore: resolve tools propagation conflict"
   ```
2. Re-run `propagate-tools.ps1` from the kit to overwrite and update the tools files to the newest correct version.

### 4.3 Recovery from Interrupted Sessions

If you return to a repo and find uncommitted files, or the last commit message begins with `wip:`, a previous session was interrupted:
* **Do NOT start new work.**
* Reconstruct the in-flight state by running `git status`, `git diff`, and checking the active design plan.
* Re-verify path health and run `.\tools\sync-repo.ps1` to ensure you are safe to proceed.


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
- **Read [BOUNDARY.md](./BOUNDARY.md) before your first PR.** Short version:
  generic process and scrubbed lessons may enter the kit; YOUR project's code,
  names, and IP never do (that protection runs in your favor — nothing of yours
  leaks here). Seed your own gitignored `tools/PRIVATE-MARKERS.list` (format in
  BOUNDARY.md) so the gate mechanically blocks your private markers from ever
  being committed.

## Stage 6 — Onboarding Scenario: Git Safeguards & Stack Lore

If you are new to programming or Git, it is easy to feel overwhelmed. To help you get comfortable, this section is a **hands-on roleplay training scenario** to simulate typical Git friction, show how the dev kit shields you from breaking code, and explain the "lore" behind why these protections exist.

### Act 1: The "Safe Arrival" Sync Shock
*In which you boot up, forget what you did last session, and try to start editing files directly.*

**The Scenario:**
You have local, uncommitted experimental edits on your machine, but the remote repository has moved ahead with new tools. Under normal Git, a `git pull` here would either error out, try to auto-merge, or create a messy merge commit.

**What to run:**
```powershell
.\tools\sync-repo.ps1
```

**The Guard in Action:**
The script will fetch the remote, detect that your local tree is dirty while the remote is ahead, and issue a **STOP** warning:
> **`[STOP] uncommitted changes AND the remote is ahead. Pulling now risks tangling them.`**

**📚 Stack Lore — The Ghost of the Synced Mount:**
> Why are we so paranoid about pulling while dirty or working on synced paths? 
> Early in development, developers used cloud-synced folders (OneDrive/Dropbox) to share active work. If an agent or developer made changes, the cloud sync engine would lock files or sync stale index offsets. Normal Git would get confused, write garbage, and corrupt the index. 
>
> We codified the **Safe Arrival** protocol (`sync-repo`) to be *completely conflict-impossible*. It fetches purely to check the layout, and if it sees any risk of a tangle, it immediately pulls the emergency brake.

---

### Act 2: The Kit-Files Merge Battle
*In which you pull anyway, hit a conflict in `tools/`, and learn the "Magic Spell".*

**The Scenario:**
To resolve the block, you commit your work locally and run `git pull --no-rebase`. Because a tool script was updated on the remote, you hit a scary conflict:
```
CONFLICT (content): Merge conflict in tools/KIT-VERSION
Automatic merge failed; fix conflicts and then commit the result.
```
For a beginner, seeing `CONFLICT` is the ultimate panic moment. You expect you have ruined your project.

**The Guard in Action:**
The **Kit-Files Rule** printed by `sync-repo` tells you exactly how to handle this. Since the kit is the source of truth, you do not need to read the `<<<<<<< HEAD` diff markers in tool scripts. You just tell Git to prefer the local version of the tools to finish the merge, and then re-propagate:

```powershell
# 1. Cast the "Prefer Ours" spell
git checkout --ours tools/KIT-VERSION
git checkout --ours tools/test-hostile-env.ps1

# 2. Add and commit to finish the merge
git add -A
git commit -m "chore: merge conflicts resolved via kit-files rule"
```

**📚 Stack Lore — The Twin Rule & Propagated Truth:**
> Why do we override tool conflicts instead of merging them?
> Every script under `tools/` is a matched **cross-platform pair** (e.g., `.ps1` for Windows, `.sh` for Linux). If a developer tries to edit one of these directly to resolve a conflict, they break the **Twin Rule** (which demands both scripts behave identically). 
> 
> To protect developers, the rule is simple: tell Git to ignore the remote conflict, finish the merge using local files, and then run `propagate-tools.ps1` from the kit to automatically lay down a clean, verified set of twins.

---

### Act 3: The Path Health Check (NTFS Scars)
*In which you learn why POSIX terminals and Windows filesystems must never mix.*

**The Scenario:**
On a Windows machine, a developer might launch their AI coding assistant from a Git Bash, MSYS2, or WSL terminal because they are used to Linux-style commands.

**What to run:**
```powershell
.\tools\verify-path-health.ps1
```

**The Guard in Action:**
If launched from an MSYS2-emulated terminal, the script immediately triggers a **FAIL**:
> **`[FAIL] Linux-emulation paths found in PATH`**

**📚 Stack Lore — The MSYS2/NTFS Truncation Hazard:**
> This check exists because of a dark chapter in dev history. 
> When running AI agents on Windows from POSIX-emulated terminals, the agent tries to write files using the Linux API, which maps onto the Windows NTFS file allocation tables. 
> 
> Because of differences in file locks and handles, this mapping would silently write **zero-filled tails** and truncate files. Code files would look normal in the editor but would be half-full of `NUL` bytes underneath, corrupting git commits. 
> 
> The path health script was written to enforce a hard boundary: **Windows files stay on native NTFS with native shells; Linux files stay on native ext4/XFS.** No crossing the streams.

---

### Act 4: The Panic Save (The Checkpoint)
*In which you learn how to save your skin when your AI assistant is about to crash.*

**The Scenario:**
You are working on a feature, and your AI assistant is running low on message limits, or you need to step away from your PC immediately.

**What to run:**
```powershell
.\tools\checkpoint.ps1 "wip: halfway through updating layouts"
```
*(Or simply double-click `tools/checkpoint.bat` from File Explorer!)*

**The Guard in Action:**
The script stages your workspace, commits it as a `wip:` save point, and attempts to push to GitHub. Even if you are offline, the script outputs:
> **`[PASS] committed locally: wip: checkpoint... YOUR WORK IS SAFE.`**

**📚 Stack Lore — The Interrupted Session Handoff:**
> AI models are fragile—they hit context windows, rate limits, or crash mid-write. If an agent dies mid-task, it leaves the directory in a half-written "dirty" state.
> 
> By running a **Checkpoint**, the agent or developer leaves a clear trail. The next time anyone runs `sync-repo`, it sees the `wip:` commit at the top of the history, warns the user that the last session was interrupted mid-task, and tells them: *"Reconstruct from: git show HEAD. Do not start new work until this is finished or reverted."* It acts as a black box flight recorder for the codebase.

---

*Stuck anywhere? Copy the full error text and send it over — that message IS
a contribution. Welcome aboard.* 🛠️
