# Codex Danger Gate

[![Windows validation](https://github.com/wilsongpt1/codex-danger-gate/actions/workflows/validate.yml/badge.svg)](https://github.com/wilsongpt1/codex-danger-gate/actions/workflows/validate.yml)
[![Latest release](https://img.shields.io/github/v/release/wilsongpt1/codex-danger-gate)](https://github.com/wilsongpt1/codex-danger-gate/releases/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Windows](https://img.shields.io/badge/platform-Windows-0078D4.svg)](INSTALL.md)

Codex Danger Gate is a Windows-focused, layered Codex guardrail. It opens an independent confirmation window for supported high-risk `PreToolUse` events and sandbox `PermissionRequest` events, and injects a concise destructive-action confirmation policy at session and subagent start.

For a matched action that reaches the hook, only a person clicking **Allow once** releases it. **Deny**, closing the window, a 90-second timeout, malformed hook input, and internal gate errors all fail closed.

> [!IMPORTANT]
> This project is an additional guardrail, not a complete sandbox. Operations inside an already writable workspace can still bypass the hard gate when Codex does not expose a tool or permission event. Keep the native sandbox enabled and use disposable workspaces, backups, least-privilege credentials, and protected branches.

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

Then start Codex CLI, enter `/hooks`, review the `SessionStart`, `SubagentStart`, `PreToolUse`, and `PermissionRequest` hooks, and press `t` to trust the reviewed definitions. Restart Codex Desktop or start a new task after installation.

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

### Coverage and protection strength

| Layer or route | Protection | Strength and limit |
| --- | --- | --- |
| `Bash`, `apply_patch`, `Edit`, `Write`, or MCP `PreToolUse` | Inspects documented destructive patterns and can deny before execution | **Hard gate when Codex emits the event** |
| `PermissionRequest` | Opens the independent dialog for sandbox-boundary escalation, even when no destructive regex matches | **Hard gate when Codex emits the permission event**; normal Codex approval still follows an allow |
| `SessionStart` and `SubagentStart` | Adds a concise policy requiring exact target, scope, material effect, and action-specific confirmation | **Behavioral guard**, not enforcement |
| Codex Desktop `functions.exec` → `shell_command` outside the sandbox | Not visible to `PreToolUse`; may still reach the `PermissionRequest` gate when Codex requests escalation | Best effort and version-dependent |
| Codex Desktop `functions.exec` inside an already writable workspace | Receives only the startup behavioral policy when no tool or permission event is emitted | **No hard hook coverage** |
| Indirect scripts, renamed executables, remote APIs, or innocuously named MCP tools | May not be recognizable from exposed input | Best effort only |

The normal Codex sandbox approval is a separate control. A sandbox approval prompt is not the Danger Gate confirmation window.

## How it works

1. `SessionStart` and `SubagentStart` add the compact confirmation policy as developer context.
2. `PreToolUse` examines supported tool names and pending input. Safe or unmatched actions continue without a dialog.
3. `PermissionRequest` asks for independent confirmation whenever Codex exposes a sandbox escalation request.
4. A matched or elevated action opens a topmost Windows window containing the hook event, tool, working directory, detected risks, and pending input.
5. **Deny**, closing the window, timeout, or an internal error returns a deny decision. **Allow once** returns control to Codex; native sandbox approval may still be required.

Plugin hooks must be reviewed and trusted before Codex runs them. In the current Codex Desktop integration, actions invoked through `functions.exec` → `shell_command` are not exposed as `PreToolUse` tool events. The `PermissionRequest` layer can help only when the action crosses the sandbox and Codex emits that event; it does not create a hard gate for actions already allowed inside a writable workspace.

## Safe test

Create a disposable test directory:

```powershell
$testPath = Join-Path $env:TEMP 'codex-danger-gate-test'
New-Item -ItemType Directory -Path $testPath -Force | Out-Null
Set-Content -LiteralPath (Join-Path $testPath 'dummy.txt') -Value 'Danger Gate test only'
$testPath
```

In a new Codex task opened on a different workspace, ask the Agent to delete only the printed disposable directory. First click **Deny** and confirm the directory remains. A dialog may come from either a supported `PreToolUse` event or a `PermissionRequest` sandbox escalation; its details identify the event. If no dialog appears, that route has no hard Danger Gate coverage in the current Codex build. Never use real documents, repositories, backups, or production data for the first test.

Version 0.3.0 injects the compact behavioral safeguard automatically at session and subagent start. Users may still copy the [`AGENTS.md` guidance](docs/OPTIONAL_AGENT_GUIDANCE.md) when they want the rule to remain visible and durable outside the plugin.

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

Codex Danger Gate can hard-block only events Codex exposes to its hooks. In particular, the current Codex Desktop `functions.exec` → `shell_command` route bypasses `PreToolUse`; when it also stays inside an already writable workspace, it may produce no `PermissionRequest` event and therefore no hard Danger Gate dialog. Startup context still asks the Agent to obtain explicit confirmation, but prompt guidance is not a security boundary.

The plugin does not guarantee detection of every destructive operation, encoded payload, indirect script, renamed executable, remote API mutation, or MCP tool with an innocuous name. A user-installed hook can also be disabled or left untrusted. For strong protection, keep important originals read-only and let Codex work in a disposable clone or worktree.

For organization-enforced protection, use administrator-managed hooks and policies in addition to this plugin. Keep filesystem permissions narrow, use non-production credentials for development, require database backups, and preserve version-controlled work.

## License

Released under the [MIT License](LICENSE).
