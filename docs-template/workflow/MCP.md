# MCP integration — model-agnostic agent tools, with a boundary

MCP (Model Context Protocol) is the vendor-neutral way to give agents tools:
one server definition works in Claude Code, Gemini CLI, Cursor, Codex, and
desktop agents. That neutrality makes it the AI-PARITY-correct place for tool
integration — and its power makes it the place where this repo's boundary
rules bite hardest. Read the tier table before connecting anything.

## 1. The rule that comes before all others

**An MCP server is third-party code running with whatever access you grant.**
Connecting one to a repo is an access decision about that repo's contents, not
a convenience setting. The repo's sensitivity tier (below, §2) decides what may
connect; AGENTS.md §Engine-style pins decide nothing here — THIS page does.

## 2. Sensitivity tiers (every repo declares one in AGENTS.md)

| Tier | Meaning | MCP policy |
|------|---------|------------|
| **open** | public or public-bound code | any reputable server; normal secret hygiene |
| **normal** | private business code | local servers freely; cloud-calling servers only for data already hosted there (e.g. GitHub MCP against the repo's own GitHub remote) |
| **restricted** | unfiled IP, pre-disclosure research, anything under an IP freeze | **local-only servers; NOTHING that transmits repo content to third-party services.** No cloud search/index/“AI helper” servers. Treat every outbound byte as a public disclosure. |

A repo that has not declared a tier is `normal` by default — except a repo whose
AGENTS.md carries an IP/disclosure freeze, which is `restricted` automatically.

## 3. The host-shell server (the sanctioned escape hatch)

Sandboxed agents (Cowork, remote agents) see this repo through a sync layer and
are BANNED from running git or gates through it (AI-PARITY §4). A **host-side
shell MCP server** (e.g. Desktop Commander) changes that calculus: the agent
calls a tool, the command runs in a NATIVE shell on the host against the real
filesystem, and true output comes back. Rules:

- Host-shell MCP **supersedes "ask the human to run git"** — gates, `git
  status`/`log`/`diff`, builds, and propagation may run through it, because
  they execute natively (the mount is not involved).
- The host shell is still a shell on YOUR machine: the standing launch rules
  apply to it (never via MSYS2 paths; `verify-path-health` first when writing).
- Mutating git commands (`commit`, `push`, checkout) through an agent-held
  host shell: allowed, but the session-end protocol's human review of
  `git status` + diff happens BEFORE the commit command is issued.
- File EDITS still go through the agent's direct file tools, not shell
  heredocs, when both can reach the file — file tools are the authoritative
  view (AI-PARITY §4 unchanged).

## 4. Configuration map (where servers are declared, per tool)

| Tool | Project-scoped config (checked in) | User/global config |
|------|-----------------------------------|--------------------|
| Claude Code | `.mcp.json` at repo root | `~/.claude.json` |
| Gemini CLI | `.gemini/settings.json` `mcpServers` | `~/.gemini/settings.json` |
| Cursor | `.cursor/mcp.json` | app settings |
| Cowork / Claude desktop | n/a (connectors UI) | desktop app settings |

- The CHECKED-IN config is the team contract: it names which servers this repo
  sanctions. Tool-specific duplicates carry the same list (pointer-file rule:
  if they drift, `.mcp.json` wins; fix the copy).
- **Never a secret in checked-in config.** Tokens enter via environment
  variable references (`${GITHUB_TOKEN}` style) or the tool's secure storage.
  The private-markers gate does not scan your shell environment — discipline
  does.
- Global/user-level MCP servers follow rule precedence (AI-PARITY §1): they
  may exist, but in THIS repo they must respect this page's tier; a global
  server the tier forbids must not be used against this repo's content.

## 5. Sanctioned servers (this stack, today)

| Server | Tier required | What it's for |
|--------|--------------|----------------|
| Host shell (Desktop Commander or equivalent) | normal+ (restricted OK — it's local) | gates, git truth, builds from sandboxed sessions (§3) |
| GitHub MCP | normal | chat-side PR review, issues from LESSONS entries, release notes — against this repo's own remote only |

Adding a server = a row here (in the project's copy of this page) + the config
entry, same commit. An unlisted server in config fails review.

## 6. Declined (recorded so they stay declined)

- **Custom kit MCP server wrapping the gates** — the gates are already one
  command with clean exit codes; a wrapper adds a layer, a version, and a twin
  obligation for zero new capability the host-shell server doesn't provide.
  Revisit only if a client appears that cannot run shell commands at all.
- **UE editor MCP servers** (editor automation) — promising but premature;
  revisit when real game-content work starts and editor toil is measurable.
  Rule of two applies to kit adoption.

## 7. Session etiquette

- Session start: an agent that detects available MCP servers states which ones
  it will use this session (one line). Unexpected servers = say so before use.
- A new server that earns its keep gets a LESSONS entry → kit-retro decides
  whether it graduates into the kit's sanctioned table.
