# Troubleshooting

## `codex` is not recognized

Use the [CLI discovery script](../INSTALL.md#2-find-the-codex-cli), then replace `codex` with `& $codexExe` in subsequent commands.

## `/hooks` is sent as a chat message

Enter `/hooks` inside the Codex CLI terminal interface. It is not a command for the Codex Desktop message composer.

## The hook is installed but inactive

Open `/hooks`, review the `PreToolUse` hook, and trust it. The definition must be reviewed again when its hash changes.

## No confirmation window appears

1. Confirm `/hooks` reports the `PreToolUse` hook as active.
2. Restart Codex Desktop and create a new task.
3. Confirm the pending action matches a documented rule.
4. Confirm Windows can launch `powershell.exe` and display Windows Forms.
5. Confirm the installed hook command points to the plugin's `scripts\danger-gate.ps1`.

## The dialog appears behind another window

Danger Gate requests a topmost taskbar window, but Windows focus rules or another always-on-top application can still interfere. Check the taskbar and use Alt+Tab. An unattended dialog times out and denies the action after 90 seconds.

## A safe command is blocked

Click **Deny**, copy only a sanitized version of the command, and open a false-positive bug report. Remove credentials, private paths, customer data, and proprietary content before posting.

## A dangerous action is not detected

Do not retry it against real data. Reproduce the behavior with a disposable local target and report a detection gap. Use private vulnerability reporting if the bypass is broadly exploitable or defeats a documented rule.

## Plugin update is not visible

Run:

```powershell
codex plugin marketplace upgrade danger-gate
codex plugin remove codex-danger-gate@danger-gate
codex plugin add codex-danger-gate@danger-gate
```

Then restart Codex or start a new task. Review the hook again if requested.
