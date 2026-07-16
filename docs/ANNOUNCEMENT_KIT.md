# Announcement and Launch Kit

This kit provides reusable English copy and a practical launch checklist for introducing Codex Danger Gate to developers. Update version numbers and results before each post.

## Positioning

**One sentence:** Codex Danger Gate adds an independent human confirmation window before supported high-risk Codex Agent actions run on Windows.

**Problem:** Session-level auto-approval is convenient, but developers may still want a separate human gate for destructive commands, file deletion, force pushes, infrastructure destruction, and destructive MCP operations.

**Difference:** The confirmation window is independent of the current session's **Approve for me** setting. Denial, timeout, malformed input, and internal gate errors fail closed.

**Honest boundary:** It is a regex- and tool-name-based guardrail over supported `PreToolUse` events, not a complete sandbox or a guarantee that every destructive action will be detected.

## Recommended launch assets

Create these assets before posting broadly:

1. A 20–30 second screen recording showing installation, `/hooks` trust, a disposable delete request, and **Deny** preserving the directory.
2. A screenshot of the wrapped confirmation dialog showing the tool, working directory, detected risk, and pending input.
3. A simple architecture image: `Codex tool request → PreToolUse hook → risk match → human dialog → allow/deny`.
4. A release link, direct ZIP link, SHA-256 checksum, and two-command install snippet.
5. A short limitations statement visible in the post, not hidden at the bottom.

Never record real credentials, private paths, customer data, production SQL, or unrelated desktop content.

## Two-command install snippet

```powershell
codex plugin marketplace add wilsongpt1/codex-danger-gate
codex plugin add codex-danger-gate@danger-gate
```

After installation, users must review and trust the `PreToolUse` hook through `/hooks` and start a new task.

## GitHub Discussion announcement

### Title

Codex Danger Gate v0.2.0 — independent human confirmation for high-risk Agent actions

### Body

I built **Codex Danger Gate**, an open-source Windows plugin for developers who use Codex automation but still want a separate human checkpoint before supported destructive actions run.

It uses a `PreToolUse` hook to detect common high-risk operations, including file deletion, destructive Git commands, database drops, infrastructure destruction, selected system/security changes, destructive patch operations, and MCP tools whose names indicate irreversible behavior.

When a rule matches, Danger Gate opens a separate Windows confirmation dialog. The action proceeds only after a person clicks **Allow once**. Denial, closing the window, a 90-second timeout, malformed input, and internal errors fail closed.

Install:

```powershell
codex plugin marketplace add wilsongpt1/codex-danger-gate
codex plugin add codex-danger-gate@danger-gate
```

Repository: https://github.com/wilsongpt1/codex-danger-gate

Latest release: https://github.com/wilsongpt1/codex-danger-gate/releases/latest

This is defense in depth, not a complete sandbox. I would especially value feedback on false positives, missing destructive MCP naming patterns, Windows compatibility, and additional safe test cases.

## Reddit or developer-community post

### Suggested title

I built an open-source Codex plugin that asks a human before high-risk Agent actions run

### Suggested body

I use Codex automation, but I wanted a second checkpoint that is independent of session auto-approval for destructive operations.

So I built **Codex Danger Gate**, a Windows-focused `PreToolUse` plugin. It detects supported forms of file deletion, destructive Git/SQL/infrastructure commands, selected system and security changes, destructive patch operations, and destructive-looking MCP tool names. A match opens a separate confirmation window with the pending input and risk reasons.

The action runs only if a person clicks **Allow once**. Deny, close, timeout, malformed input, and internal errors fail closed.

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

I built Codex Danger Gate: an open-source Windows plugin that opens an independent human confirmation window before supported destructive Codex Agent actions run.

File deletion, force push, destructive SQL/infra, risky MCP names, and more. Deny/timeout/errors fail closed.

https://github.com/wilsongpt1/codex-danger-gate

## LinkedIn or Dev.to introduction

Codex automation can save time, but high-risk tool calls deserve a clear security boundary. Codex Danger Gate adds a separate human confirmation step before supported destructive actions run on Windows, even when the current session uses automatic approval.

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
