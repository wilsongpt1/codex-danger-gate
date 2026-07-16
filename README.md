# Codex Danger Gate

[![Windows validation](https://github.com/wilsongpt1/codex-danger-gate/actions/workflows/validate.yml/badge.svg)](https://github.com/wilsongpt1/codex-danger-gate/actions/workflows/validate.yml)
[![Latest release](https://img.shields.io/github/v/release/wilsongpt1/codex-danger-gate)](https://github.com/wilsongpt1/codex-danger-gate/releases/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Windows](https://img.shields.io/badge/platform-Windows-0078D4.svg)](INSTALL.md)

Codex Danger Gate is a Windows-focused, layered Codex guardrail. It opens an independent confirmation window for supported high-risk `PreToolUse` events and sandbox `PermissionRequest` events, and injects a concise destructive-action confirmation policy at session and subagent start.

For a matched action that reaches the hook, only a person clicking **Allow once** releases it. **Deny**, closing the window, a 90-second timeout, malformed hook input, and internal gate errors all fail closed.

> [!IMPORTANT]
> A live end-to-end test on Codex App and bundled CLI 0.144.2 deleted a disposable file through `functions.exec` → `shell_command` without showing a Danger Gate window. Both `PreToolUse` and `PermissionRequest` were installed, trusted, and active, but that route exposed neither usable hard-gate event. **Danger Gate therefore provides no hard protection for this tested route.** This project is an additional event-dependent guardrail, not a complete sandbox.

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
| Codex App 0.144.2 `functions.exec` → `shell_command` | Live deletion test exposed neither usable hard-gate event, despite active hooks | **No Danger Gate hard protection observed** |
| Other wrapped or future tool routes | Can be gated only if that Codex build and handler emit `PreToolUse` or `PermissionRequest` | Unverified and version-dependent |
| Indirect scripts, renamed executables, remote APIs, or innocuously named MCP tools | May not be recognizable from exposed input | Best effort only |

The normal Codex sandbox approval is a separate control. A sandbox approval prompt is not the Danger Gate confirmation window.

## How it works

1. `SessionStart` and `SubagentStart` add the compact confirmation policy as developer context.
2. `PreToolUse` examines supported tool names and pending input. Safe or unmatched actions continue without a dialog.
3. `PermissionRequest` asks for independent confirmation whenever Codex exposes a sandbox escalation request.
4. A matched or elevated action opens a topmost Windows window containing the hook event, tool, working directory, detected risks, and pending input.
5. **Deny**, closing the window, timeout, or an internal error returns a deny decision. **Allow once** returns control to Codex; native sandbox approval may still be required.

Plugin hooks must be reviewed and trusted before Codex runs them. Trust and active status mean Codex may run a hook for supported event dispatches; they do not mean every tool route emits those events. In the tested Codex App 0.144.2 route, `functions.exec` → `shell_command` emitted neither hard-gate event for an actual deletion.

## Safe test

Create a disposable test directory:

```powershell
$testPath = Join-Path $env:TEMP 'codex-danger-gate-test'
New-Item -ItemType Directory -Path $testPath -Force | Out-Null
Set-Content -LiteralPath (Join-Path $testPath 'dummy.txt') -Value 'Danger Gate test only'
$testPath
```

In a new Codex task opened on a different workspace, ask the Agent to delete only the printed disposable directory. This is a **coverage probe**, not a promised popup. If a Danger Gate dialog appears, click **Deny** and confirm the directory remains. If no dialog appears, that route has no hard Danger Gate coverage in the current Codex build and the Agent may delete the target. The live 0.144.2 `functions.exec` test produced no plugin dialog. Never use real documents, repositories, backups, or production data for this test.

Version 0.3.1 injects the compact behavioral safeguard automatically at session and subagent start. Users may still copy the [`AGENTS.md` guidance](docs/OPTIONAL_AGENT_GUIDANCE.md) when they want the rule to remain visible and durable outside the plugin.

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

Codex Danger Gate can hard-block only events Codex exposes to its hooks. The live Codex App and bundled CLI 0.144.2 test confirmed that `functions.exec` → `shell_command` deletion can bypass both registered hard gates and complete without a Danger Gate window. Startup context still asks the Agent to obtain explicit confirmation, but prompt guidance is not a security boundary and did not prevent the tested deletion.

The plugin does not guarantee detection of every destructive operation, encoded payload, indirect script, renamed executable, remote API mutation, or MCP tool with an innocuous name. A user-installed hook can also be disabled or left untrusted. For strong protection, keep important originals read-only and let Codex work in a disposable clone or worktree.

For organization-enforced protection, use administrator-managed hooks and policies in addition to this plugin. Keep filesystem permissions narrow, use non-production credentials for development, require database backups, and preserve version-controlled work.

## License

Released under the [MIT License](LICENSE).
