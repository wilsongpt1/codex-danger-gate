# Detection Rules

Danger Gate evaluates supported tool names and pending input before the tool runs. It also gates exposed sandbox permission requests and injects a compact confirmation policy at session and subagent start.

## Event coverage

Danger Gate has three event-dependent layers:

| Exposed event | What Danger Gate does | Strength |
| --- | --- | --- |
| `Bash` `PreToolUse` | Evaluates command text against the rules below | Hard gate |
| `apply_patch`, `Edit`, `Write` `PreToolUse` | Evaluates supported patch text for deletion or movement | Hard gate |
| `mcp__.*` `PreToolUse` | Evaluates the MCP tool name for destructive indicators | Hard gate |
| `PermissionRequest` | Gates any exposed sandbox-boundary escalation and also evaluates available command input | Hard gate |
| `SessionStart`, `SubagentStart` | Injects the action-specific confirmation policy | Behavioral guard only |

The current Codex Desktop `functions.exec` → `shell_command` route does not emit a supported `PreToolUse` event. It can receive a hard gate only if Codex separately emits `PermissionRequest` because the action crosses the sandbox. Inside an already writable workspace, the route may emit neither event; the startup behavioral policy is then the only Danger Gate layer.

## Shell and command input

| Rule | Examples of covered capability |
| --- | --- |
| File deletion | `Remove-Item`, `Clear-Content`, `rm`, `del`, `erase`, `rmdir`, `rd`, `shred` |
| Storage destruction | `format`, `diskpart`, `mkfs`, `wipefs`, raw-device `dd` output |
| Git history or work loss | `reset --hard`, forced `clean`, destructive restore/checkout, force push, `branch -D` |
| Database destruction | `DROP DATABASE`, `DROP SCHEMA`, `DROP TABLE`, `TRUNCATE TABLE` |
| Infrastructure destruction | Terraform destroy, Kubernetes delete, Helm uninstall |
| Cloud deletion | Recursive AWS S3 removal, Azure resource-group deletion, Google Cloud delete commands |
| System disruption | Shutdown, restart, forced process termination |
| Windows persistence or recovery loss | Registry deletion, service deletion, shadow-copy or backup deletion |
| Security weakening | Selected Microsoft Defender and Windows Firewall disable operations |
| Permission takeover | Selected `takeown` and `icacls` ownership or broad permission changes |
| Obfuscated PowerShell | `-EncodedCommand` and `-enc` payloads |

These rules apply only to command text delivered through a supported event. Patterns are case-insensitive and designed to recognize common command boundaries. Review the source in `scripts/danger-gate.ps1` for the exact regular expressions.

## File-editing tools

For `apply_patch`, `Edit`, and `Write`, Danger Gate checks supported patch text for:

- `*** Delete File:`
- `*** Move to:`

Ordinary file creation and content edits are not currently gated unless they are expressed through another matched high-risk command.

## MCP tools

MCP tool names are gated when the name contains a destructive indicator such as `delete`, `remove`, `destroy`, `drop`, `truncate`, `purge`, `wipe`, `revoke`, `terminate`, `uninstall`, `unpublish`, `force_push`, or `reset`.

This is a name-based heuristic. A destructive MCP tool with an innocuous name can bypass this rule, while a harmless tool whose name includes one of these terms can cause a false positive.

## Fail-closed cases

The pending action is denied when:

- The user clicks **Deny**
- The confirmation window is closed
- The 90-second confirmation timer expires
- Hook input is missing or malformed
- The gate encounters an internal error while processing a matched request

## Known limitations

- Codex can invoke the hard gate only for events it exposes to `PreToolUse` or `PermissionRequest`.
- `PermissionRequest` coverage also depends on Codex emitting the event for that tool handler and platform build.
- The current Codex Desktop `functions.exec` → `shell_command` route is not exposed to `PreToolUse`. Inside an already writable workspace it may also avoid `PermissionRequest`, so destructive commands can bypass the hard dialog.
- Session and subagent policy injection shapes Agent behavior but cannot enforce a deny decision.
- Regex matching is not a complete shell, SQL, or PowerShell parser.
- Indirect execution through scripts, aliases, renamed executables, encoded data, or remote APIs may not be recognizable.
- Database mutations sent through a generically named MCP tool may not be detected.
- The gate does not inspect the future behavior of downloaded binaries or scripts.
- A local user can disable or decline to trust a user-installed hook.
- Concurrent hooks are independent; this plugin does not control other hooks.

Use least-privilege credentials, backups, protected branches, database access controls, and administrator-managed policies for defense in depth.

The plugin injects its compact non-enforcing policy automatically. Users can also keep the same rule explicitly in [`AGENTS.md`](OPTIONAL_AGENT_GUIDANCE.md) for durable visibility.
