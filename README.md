# Codex Danger Gate

[![Windows validation](https://github.com/wilsongpt1/codex-danger-gate/actions/workflows/validate.yml/badge.svg)](https://github.com/wilsongpt1/codex-danger-gate/actions/workflows/validate.yml)
[![Latest release](https://img.shields.io/github/v/release/wilsongpt1/codex-danger-gate)](https://github.com/wilsongpt1/codex-danger-gate/releases/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Windows](https://img.shields.io/badge/platform-Windows-0078D4.svg)](INSTALL.md)

Codex Danger Gate is a Windows-focused Codex plugin that requires explicit human confirmation before supported high-risk Agent actions can run when Codex exposes them to the plugin's `PreToolUse` hook. Its confirmation window is independent of the current session's **Approve for me** setting.

For a matched action that reaches the hook, only a person clicking **Allow once** releases it. **Deny**, closing the window, a 90-second timeout, malformed hook input, and internal gate errors all fail closed.

> [!IMPORTANT]
> This project is an additional guardrail, not a complete sandbox or a replacement for backups, least-privilege credentials, network controls, and production change management.

## Download

- [Download the latest release](https://github.com/wilsongpt1/codex-danger-gate/releases/latest)
- [Read the complete Windows installation guide](INSTALL.md)
- [Review all detection rules](docs/DETECTION_RULES.md)

Every release includes a ready-to-install ZIP and a SHA-256 checksum file.

## Quick install

Requirements: Windows 10 or 11, Codex Desktop or Codex CLI with plugin support, and Windows PowerShell 5.1 or PowerShell 7.

Open PowerShell and run:

```powershell
codex plugin marketplace add wilsongpt1/codex-danger-gate
codex plugin add codex-danger-gate@danger-gate
```

Then start Codex CLI, enter `/hooks`, review the `PreToolUse` hook, and press `t` to trust it. Restart Codex Desktop or start a new task after installation.

If `codex` is not on `PATH`, follow the [CLI discovery steps](INSTALL.md#2-find-the-codex-cli).

## What it protects

The gate currently detects these operations when they arrive through a supported hook event:

- File or directory deletion and content clearing
- Disk formatting, repartitioning, and raw device writes
- Destructive Git operations such as hard reset, forced clean, and force push
- Destructive SQL, Terraform, Kubernetes, Helm, and cloud CLI operations
- Shutdown, forced process termination, registry deletion, service deletion, and backup deletion
- Selected endpoint-security weakening and filesystem permission takeover commands
- File deletion or movement through `apply_patch`
- MCP tool names that indicate destructive or irreversible actions

See [Detection rules](docs/DETECTION_RULES.md) for the exact coverage and known limits.

### Coverage at a glance

| Route | Current coverage |
| --- | --- |
| `Bash` `PreToolUse` event | Inspects the command for documented high-risk patterns |
| `apply_patch`, `Edit`, or `Write` `PreToolUse` event | Inspects supported patch text for file deletion and movement |
| MCP `PreToolUse` event | Inspects the MCP tool name for destructive indicators |
| Codex Desktop `functions.exec` → `shell_command` | **Not exposed to `PreToolUse`; Danger Gate cannot inspect or block it** |
| Indirect scripts, renamed executables, remote APIs, or innocuously named MCP tools | Best effort only; may not be recognizable from the exposed input |

The normal Codex sandbox approval is a separate control. A sandbox approval prompt is not the Danger Gate confirmation window.

## How it works

1. Codex loads the plugin's `PreToolUse` lifecycle hook.
2. The hook examines supported tool names and pending tool input.
3. Safe or unmatched actions continue without a dialog.
4. A matched high-risk action opens a topmost Windows confirmation window containing the tool, working directory, detected risks, and pending input.
5. The hook returns an explicit allow or deny decision to Codex.

Plugin hooks must be reviewed and trusted before Codex runs them. The matcher covers `Bash`, `apply_patch`, `Edit`, `Write`, and MCP tool names, subject to the tool events Codex exposes to hooks. In the current Codex Desktop integration, actions invoked through `functions.exec` → `shell_command` are not exposed as `PreToolUse` tool events, so this plugin cannot inspect or block them.

## Safe test

Create a disposable test directory:

```powershell
$testPath = Join-Path $env:TEMP 'codex-danger-gate-test'
New-Item -ItemType Directory -Path $testPath -Force | Out-Null
Set-Content -LiteralPath (Join-Path $testPath 'dummy.txt') -Value 'Danger Gate test only'
$testPath
```

In a new Codex task, ask the Agent to delete only the printed disposable directory. This verifies Danger Gate only if Codex routes the action through a supported event and the separate dialog appears. If Codex Desktop routes it through `functions.exec` → `shell_command`, no Danger Gate dialog will appear; use the available Codex sandbox and approval controls, and do not treat that route as protected by this plugin. First click **Deny** and confirm the directory remains. Never use real documents, repositories, backups, or production data for the first test.

For an additional behavioral safeguard, users may opt in to the compact [`AGENTS.md` guidance](docs/OPTIONAL_AGENT_GUIDANCE.md). It is not installed automatically and does not replace hook or sandbox enforcement.

## Documentation

- [Installation, update, removal, and verification](INSTALL.md)
- [Detection rules and limitations](docs/DETECTION_RULES.md)
- [Optional compact Agent guidance](docs/OPTIONAL_AGENT_GUIDANCE.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Announcement and launch kit](docs/ANNOUNCEMENT_KIT.md)
- [Security policy](SECURITY.md)
- [Contributing](CONTRIBUTING.md)
- [Support](SUPPORT.md)
- [Changelog](CHANGELOG.md)

## Security boundary

Codex Danger Gate can only inspect tool events and input exposed to its hook. In particular, the current Codex Desktop `functions.exec` → `shell_command` route bypasses `PreToolUse` and therefore this plugin. It does not guarantee detection of every destructive operation, encoded payload, indirect script, renamed executable, remote API mutation, or MCP tool with an innocuous name. A user-installed hook can also be disabled or left untrusted.

For organization-enforced protection, use administrator-managed hooks and policies in addition to this plugin. Keep filesystem permissions narrow, use non-production credentials for development, require database backups, and preserve version-controlled work.

## License

Released under the [MIT License](LICENSE).
