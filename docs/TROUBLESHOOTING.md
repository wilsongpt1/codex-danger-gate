# Troubleshooting

## `codex` is not recognized

Use the [CLI discovery script](../INSTALL.md#2-find-the-codex-cli), then replace `codex` with `& $codexExe` in subsequent commands.

## `/hooks` is sent as a chat message

Enter `/hooks` inside the Codex CLI terminal interface. It is not a command for the Codex Desktop message composer.

## The hook is installed but inactive

Open `/hooks`, review the `PreToolUse` hook, and trust it. The definition must be reviewed again when its hash changes.

## No confirmation window appears

1. Determine which tool route Codex used. The current Codex Desktop `functions.exec` → `shell_command` route is not exposed to `PreToolUse` and cannot trigger Danger Gate.
2. If the action used a supported event, confirm `/hooks` reports the `PreToolUse` hook as active.
3. Restart Codex Desktop and create a new task.
4. Confirm the pending action matches a documented rule.
5. Confirm Windows can launch `powershell.exe` and display Windows Forms.
6. Confirm the installed hook command points to the plugin's `scripts\danger-gate.ps1`.

## A Codex approval appears but no Danger Gate window appears

The Codex sandbox approval and the Danger Gate Windows dialog are separate controls. A sandbox approval can appear for a `functions.exec` → `shell_command` action even though Danger Gate received no `PreToolUse` event. Only the window titled **Codex high-risk action confirmation** belongs to this plugin.

## The dialog appears behind another window

Danger Gate requests a topmost taskbar window, but Windows focus rules or another always-on-top application can still interfere. Check the taskbar and use Alt+Tab. An unattended dialog times out and denies the action after 90 seconds.

## A safe command is blocked

Click **Deny**, copy only a sanitized version of the command, and open a false-positive bug report. Remove credentials, private paths, customer data, and proprietary content before posting.

## A dangerous action is not detected

Do not retry it against real data. First determine whether Codex exposed the action through a supported event:

- If the route was `functions.exec` → `shell_command`, this is a documented platform coverage limit.
- If a supported event reached the hook but a documented rule did not match, reproduce it with a disposable local target and report a detection gap.

Use private vulnerability reporting if the bypass is broadly exploitable or defeats documented supported-event behavior.

For defense in depth, review the optional compact [`AGENTS.md` guidance](OPTIONAL_AGENT_GUIDANCE.md). It shapes Agent behavior but does not enforce policy.

## Plugin update is not visible

Run:

```powershell
codex plugin marketplace upgrade danger-gate
codex plugin remove codex-danger-gate@danger-gate
codex plugin add codex-danger-gate@danger-gate
```

Then restart Codex or start a new task. Review the hook again if requested.
