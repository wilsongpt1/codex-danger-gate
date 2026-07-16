# Troubleshooting

## `codex` is not recognized

Use the [CLI discovery script](../INSTALL.md#2-find-the-codex-cli), then replace `codex` with `& $codexExe` in subsequent commands.

## `/hooks` is sent as a chat message

Enter `/hooks` inside the Codex CLI terminal interface. It is not a command for the Codex Desktop message composer.

## The hook is installed but inactive

Open `/hooks`, review the `SessionStart`, `SubagentStart`, `PreToolUse`, and `PermissionRequest` hooks, and trust them. Definitions must be reviewed again when their hashes change.

## No confirmation window appears

1. Determine which tool route Codex used and whether it crossed the sandbox. The current Codex Desktop `functions.exec` → `shell_command` route is not exposed to `PreToolUse`.
2. Confirm `/hooks` reports both `PreToolUse` and `PermissionRequest` as active.
3. Restart Codex Desktop and create a new task.
4. Confirm the pending action matches a documented rule.
5. Confirm Windows can launch `powershell.exe` and display Windows Forms.
6. Confirm the installed hard-gate hooks point to `scripts\danger-gate.ps1` and startup hooks point to `scripts\safety-context.ps1`.
7. If the action was already inside a writable workspace and Codex emitted neither hard event, no dialog is expected; only the behavioral startup policy applies.

## A Codex approval appears but no Danger Gate window appears

The Codex sandbox approval and the Danger Gate Windows dialog are separate controls. Version 0.3.0 also registers `PermissionRequest`, so an exposed escalation can produce a Danger Gate dialog before the native approval. If that tool handler does not emit the hook event, only the native approval appears. Only the window titled **Codex high-risk action confirmation** belongs to this plugin.

## The dialog appears behind another window

Danger Gate requests a topmost taskbar window, but Windows focus rules or another always-on-top application can still interfere. Check the taskbar and use Alt+Tab. An unattended dialog times out and denies the action after 90 seconds.

## A safe command is blocked

Click **Deny**, copy only a sanitized version of the command, and open a false-positive bug report. Remove credentials, private paths, customer data, and proprietary content before posting.

## A dangerous action is not detected

Do not retry it against real data. First determine whether Codex exposed the action through a supported event:

- If the route was `functions.exec` → `shell_command` inside a writable workspace, this is a documented hard-coverage limit.
- If it crossed the sandbox but no `PermissionRequest` hook ran, record the Codex version and report an event-coverage gap.
- If a supported event reached the hook but a documented rule did not match, reproduce it with a disposable local target and report a detection gap.

Use private vulnerability reporting if the bypass is broadly exploitable or defeats documented supported-event behavior.

The plugin injects the compact policy automatically. The optional [`AGENTS.md` guidance](OPTIONAL_AGENT_GUIDANCE.md) keeps it visible and durable but still does not enforce policy.

## Plugin update is not visible

Run:

```powershell
codex plugin marketplace upgrade danger-gate
codex plugin remove codex-danger-gate@danger-gate
codex plugin add codex-danger-gate@danger-gate
```

Then restart Codex or start a new task. Review the hook again if requested.
