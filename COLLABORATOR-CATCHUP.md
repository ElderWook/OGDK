# One-time catch-up: get current + protected by the new git guards

Hey! I just pushed changes to OGDK that add automatic guards against leaking
private info (like your real email) into git history. Quick one-time catch-up so
your copy is current and protected. **Nothing here can lose your work** — and if
anything looks unsure, it'll tell you to stop and send me the output. Do the steps
in order.

> Using an AI agent (Claude Code / agy) in this repo? Just paste this whole message
> to it and let it drive — tell it to **stop and ask you before anything risky and
> never force-push or auto-merge**. Doing it by hand is just as fine.

## 0. Save your work first (your usual move)
Double-click **`tools\checkpoint.bat`**. This commits anything in progress as a
`wip:` save so nothing can be lost in the next steps. If it says the push failed,
that's fine — it still saved on your machine.

## 1. Open PowerShell in your OGDK folder
In File Explorer, open your OGDK folder, click the address bar, type `powershell`,
Enter. (Or open PowerShell and `cd` to wherever your OGDK clone lives.)

## 2. Set your git identity to a private (noreply) email — one time
This is the whole point of the new guard: your real email must never land in a
commit. Get your GitHub noreply address from GitHub -> Settings -> Emails ->
"Keep my email private" (looks like `12345+yourname@users.noreply.github.com`):

```powershell
git config --global user.name "Your Name"
git config --global user.email "12345+yourname@users.noreply.github.com"
```

## 3. Check your environment is clean
```powershell
.\tools\verify-path-health.ps1
```
See any **[FAIL]**? Stop and send me the whole output.

## 4. Catch up safely (this is "git pull" done right)
```powershell
.\tools\sync-repo.ps1
```
- Ends with **SAFE TO WORK** -> you're current. Go to step 5.
- Says **[STOP]** anything (DIVERGED / uncommitted / MERGE in progress) ->
  **don't try to fix it yourself.** Copy the entire output, send it to me, and
  wait. Untangling it wrong is exactly how people lose work, so we'll do it
  together. (That STOP is the guard working, not a problem you caused.)

## 5. Turn on the new push guard for your machine
```powershell
.\tools\install-hooks.ps1
```
From now on, every `git push` automatically checks your commit history for private
info first and blocks the push if it finds any.

## 6. Tell the guard what to protect (important, one time)
Open **`tools\PRIVATE-MARKERS.list`** in Notepad (create it if it's missing). Put
one item per line: your name, your email, your GitHub username, your Windows
username, and any project codenames I send you separately. Save. This file stays
private on your machine and is never committed — it's what lets the guard catch a
leak before it's pushed.

## 7. Final check
```powershell
.\tools\gate.ps1
```
Want **GATE PASSED**. If the **git identity** section shows a **[FAIL]** about a
commit, send me the output — it means an older commit has your real email in it and
we'll clean it up together. **Don't push until we do.**

---

That's it — you're current and protected. Steps 3-4 are also the normal
"start of every session" routine, so it's a good habit to run them each time you
sit down. Ping me if any step shows red.
