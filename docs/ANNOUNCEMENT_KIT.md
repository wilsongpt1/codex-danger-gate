# Announcement and Launch Kit

This kit provides reusable English copy and a practical launch checklist for introducing Codex Danger Gate to developers. Update version numbers and results before each post.

## Positioning

**One sentence:** Codex Danger Gate adds an independent human confirmation window before supported high-risk Codex Agent actions run on Windows.

**Problem:** Session-level auto-approval is convenient, but developers may still want a separate human gate for destructive commands, file deletion, force pushes, infrastructure destruction, and destructive MCP operations.

**Difference:** The confirmation window is independent of the current session's **Approve for me** setting. Denial, timeout, malformed input, and internal gate errors fail closed.

**Honest boundary:** Hard blocking depends on Codex exposing `PreToolUse` or `PermissionRequest`. A live Codex App 0.144.2 test deleted a disposable file through `functions.exec` → `shell_command` without either plugin event or warning window. Startup context adds only a behavioral safeguard.

## Recommended launch assets

Create these assets before posting broadly:

1. A 20–30 second screen recording showing installation, `/hooks` trust, a disposable delete request, and **Deny** preserving the directory.
2. A screenshot of the wrapped confirmation dialog showing the tool, working directory, detected risk, and pending input.
3. A simple architecture image: `session policy + exposed PreToolUse/PermissionRequest → human dialog where available → Codex sandbox`.
4. A release link, direct ZIP link, SHA-256 checksum, and two-command install snippet.
5. A short limitations statement visible in the post, not hidden at the bottom.

Never record real credentials, private paths, customer data, production SQL, or unrelated desktop content.

## Two-command install snippet

```powershell
codex plugin marketplace add wilsongpt1/codex-danger-gate
codex plugin add codex-danger-gate@danger-gate
```

After installation, users must review and trust the `SessionStart`, `SubagentStart`, `PreToolUse`, and `PermissionRequest` hooks through `/hooks` and start a new task.

## GitHub Discussion announcement

### Title

Codex Danger Gate v0.3.1 — event-dependent human confirmation for supported Agent actions

### Body

I built **Codex Danger Gate**, an open-source Windows plugin for developers who use Codex automation but still want a separate human checkpoint before supported destructive actions run.

It uses `PreToolUse` to detect supported high-risk operations, `PermissionRequest` to gate exposed sandbox escalations, and startup hooks to inject a concise action-specific confirmation policy without editing user `AGENTS.md` files.

When a rule matches **and Codex emits a supported hook event**, Danger Gate opens a separate Windows confirmation dialog. The action proceeds only after a person clicks **Allow once**. Denial, closing the window, a 90-second timeout, malformed input, and internal errors fail closed.

Install:

```powershell
codex plugin marketplace add wilsongpt1/codex-danger-gate
codex plugin add codex-danger-gate@danger-gate
```

Repository: https://github.com/wilsongpt1/codex-danger-gate

Latest release: https://github.com/wilsongpt1/codex-danger-gate/releases/latest

This is defense in depth, not a complete sandbox. Codex App 0.144.2 `functions.exec` deletion produced no usable plugin event in live testing, so that route has no Danger Gate hard protection. I would especially value feedback on false positives, event coverage across Codex builds, Windows compatibility, and additional safe test cases.

## Reddit or developer-community post

### Suggested title

I built an open-source Codex plugin that asks a human before high-risk Agent actions run

### Suggested body

I use Codex automation, but I wanted a second checkpoint that is independent of session auto-approval for destructive operations.

So I built **Codex Danger Gate**, a layered Windows-focused plugin. It detects supported destructive `PreToolUse` inputs, gates exposed sandbox `PermissionRequest` events, and adds concise confirmation context at session and subagent start. A hard-gate event opens a separate confirmation window with the pending input and risk reasons.

For an exposed hard-gate event, the action runs only if a person clicks **Allow once**. Deny, close, timeout, malformed input, and internal errors fail closed. Codex App 0.144.2 `functions.exec` deletion did not expose such an event in live testing and was not blocked.

Two-command install:

```powershell
codex plugin marketplace add wilsongpt1/codex-danger-gate
codex plugin add codex-danger-gate@danger-gate
```

Repo: https://github.com/wilsongpt1/codex-danger-gate

It is intentionally documented as a guardrail rather than a full sandbox. I am looking for feedback on detection gaps, false positives, MCP coverage, and the confirmation UX.

## Hacker News submission

**Title:** Show HN: Codex Danger Gate – human confirmation for high-risk Agent actions

**URL:** https://github.com/wilsongpt1/codex-danger-gate

Use a first comment that briefly explains the threat model, why normal Codex approvals were not sufficient for your workflow, what the hook can and cannot inspect, and how you tested fail-closed behavior.

## X post

I built Codex Danger Gate: an open-source Windows plugin that opens an independent human confirmation window when Codex exposes supported destructive Agent actions to plugin hooks.

File deletion, force push, destructive SQL/infra, risky MCP names, and more. Deny/timeout/errors fail closed.

https://github.com/wilsongpt1/codex-danger-gate

## LinkedIn or Dev.to introduction

Codex automation can save time, but high-risk tool calls deserve a clear security boundary. Codex Danger Gate adds a separate human confirmation step for supported hook events on Windows, even when the current session uses automatic approval. It cannot create missing hook events, and live Codex App 0.144.2 `functions.exec` testing demonstrated a route it cannot hard-block.

The project is open source, includes a checksummed release ZIP, automated Windows tests, documented detection rules and limitations, and private vulnerability reporting.

Project: https://github.com/wilsongpt1/codex-danger-gate

## Outreach targets

Prioritize communities where the problem is already visible:

- GitHub topic pages for `codex-plugins`, `openai-codex`, `agent-safety`, and `human-in-the-loop`
- Codex-focused Reddit communities and OpenAI developer communities
- Dev.to, Hacker News Show HN, LinkedIn, and X
- Maintainers of relevant `awesome-codex`, agent-plugin, AI safety, and developer-security lists
- Developers building destructive MCP integrations, especially database, cloud, deployment, and repository-management tools

Follow each community's self-promotion rules. Lead with a useful demo and threat model rather than repeating the same promotional text everywhere.

## Trust checklist

Before asking developers to install a security-sensitive plugin, confirm:

- The repository and release archive use the same name.
- The release is generated from a tagged, tested commit.
- SHA-256 is published next to the ZIP.
- CI is green on Windows.
- Detection rules and known limitations are easy to find.
- The source is small enough to audit.
- Security reports can be submitted privately.
- Release notes explain every material behavior change.
- No telemetry, credentials, or unexpected network behavior is present.

## Launch sequence

1. Publish the release and verify the direct download.
2. Pin a GitHub Discussion announcement.
3. Post the demo to one focused Codex community and answer every technical question.
4. Incorporate early feedback and publish a small follow-up release.
5. Submit to relevant GitHub topic pages and curated lists.
6. Share the improved demo more broadly after several independent users have tested it.

## Metrics worth tracking

Track signals of real usage rather than impressions alone:

- Unique release downloads
- Stars and forks
- Successful installation reports
- Detection-gap and false-positive issues
- Number of external contributors
- Time to acknowledge security reports
- Repeat downloads after a new release
