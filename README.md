# Codex Danger Gate

[![Windows validation](https://github.com/wilsongpt1/codex-danger-gate/actions/workflows/validate.yml/badge.svg)](https://github.com/wilsongpt1/codex-danger-gate/actions/workflows/validate.yml)
[![Latest release](https://img.shields.io/github/v/release/wilsongpt1/codex-danger-gate)](https://github.com/wilsongpt1/codex-danger-gate/releases/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Windows](https://img.shields.io/badge/platform-Windows-0078D4.svg)](INSTALL.md)

Codex Danger Gate is a Windows-focused Codex plugin that requires explicit human confirmation before supported high-risk Agent actions can run. Its confirmation window is independent of the current session's **Approve for me** setting.

Only a person clicking **Allow once** releases the pending action. **Deny**, closing the window, a 90-second timeout, malformed hook input, and internal gate errors all fail closed.

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

The gate currently detects supported forms of:

- File or directory deletion and content clearing
- Disk formatting, repartitioning, and raw device writes
- Destructive Git operations such as hard reset, forced clean, and force push
- Destructive SQL, Terraform, Kubernetes, Helm, and cloud CLI operations
- Shutdown, forced process termination, registry deletion, service deletion, and backup deletion
- Selected endpoint-security weakening and filesystem permission takeover commands
- File deletion or movement through `apply_patch`
- MCP tool names that indicate destructive or irreversible actions

See [Detection rules](docs/DETECTION_RULES.md) for the exact coverage and known limits.

## How it works

1. Codex loads the plugin's `PreToolUse` lifecycle hook.
2. The hook examines supported tool names and pending tool input.
3. Safe or unmatched actions continue without a dialog.
4. A matched high-risk action opens a topmost Windows confirmation window containing the tool, working directory, detected risks, and pending input.
5. The hook returns an explicit allow or deny decision to Codex.

Plugin hooks must be reviewed and trusted before Codex runs them. The matcher covers `Bash`, `apply_patch`, `Edit`, `Write`, and MCP tool names, subject to the tool events Codex exposes to hooks.

## Safe test

Create a disposable test directory:

```powershell
$testPath = Join-Path $env:TEMP 'codex-danger-gate-test'
New-Item -ItemType Directory -Path $testPath -Force | Out-Null
Set-Content -LiteralPath (Join-Path $testPath 'dummy.txt') -Value 'Danger Gate test only'
$testPath
```

In a new Codex task, ask the Agent to delete only the printed disposable directory. First click **Deny** and confirm the directory remains. Never use real documents, repositories, backups, or production data for the first test.

## Documentation

- [Installation, update, removal, and verification](INSTALL.md)
- [Detection rules and limitations](docs/DETECTION_RULES.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Security policy](SECURITY.md)
- [Contributing](CONTRIBUTING.md)
- [Support](SUPPORT.md)
- [Changelog](CHANGELOG.md)

## Security boundary

Codex Danger Gate can only inspect tool events and input exposed to its hook. It does not guarantee detection of every destructive operation, encoded payload, indirect script, renamed executable, remote API mutation, or MCP tool with an innocuous name. A user-installed hook can also be disabled or left untrusted.

For organization-enforced protection, use administrator-managed hooks and policies in addition to this plugin. Keep filesystem permissions narrow, use non-production credentials for development, require database backups, and preserve version-controlled work.

## License

Released under the [MIT License](LICENSE).
