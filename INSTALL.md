# Installing Codex Danger Gate on Windows

This guide covers online installation from GitHub, offline installation from a release ZIP, hook review, safe verification, updates, removal, and common recovery steps.

## 1. Requirements

- Windows 10 or Windows 11
- Codex Desktop or Codex CLI with plugin and hook support; hard protection is limited to `PreToolUse` and `PermissionRequest` events Codex exposes
- Windows PowerShell 5.1 or PowerShell 7
- Network access to GitHub for online installation

## 2. Find the Codex CLI

First try:

```powershell
codex --version
```

If PowerShell reports that `codex` is not recognized, use the CLI bundled with Codex Desktop:

```powershell
$codexCommand = Get-Command codex -ErrorAction SilentlyContinue

if ($codexCommand) {
    $codexExe = $codexCommand.Source
}
else {
    $codexExe = Get-ChildItem "$env:LOCALAPPDATA\OpenAI\Codex\bin" `
        -Recurse -Filter codex.exe -File -ErrorAction SilentlyContinue |
        Where-Object {
            $_.DirectoryName -ne "$env:LOCALAPPDATA\OpenAI\Codex\bin"
        } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1 -ExpandProperty FullName
}

if (-not $codexExe) {
    throw "Codex CLI was not found. Install or update Codex Desktop first."
}

& $codexExe --version
```

Use `& $codexExe` instead of `codex` in the commands below if the CLI is not on `PATH`.

## 3. Online installation from GitHub

Register this repository as a Codex plugin marketplace:

```powershell
& $codexExe plugin marketplace add wilsongpt1/codex-danger-gate
```

Install the plugin:

```powershell
& $codexExe plugin add codex-danger-gate@danger-gate
```

Start Codex CLI:

```powershell
& $codexExe
```

## 4. Review and trust the hook

Inside the Codex CLI terminal interface, enter:

```text
/hooks
```

Review the pending hooks and verify:

1. The source is the `codex-danger-gate` plugin.
2. `SessionStart` uses `scripts\safety-context.ps1` for `startup|resume|clear|compact`.
3. `SubagentStart` uses `scripts\safety-context.ps1` with the all-events matcher.
4. `PreToolUse` uses `scripts\danger-gate.ps1` with `^(Bash|apply_patch|Edit|Write|mcp__.*)$`.
5. `PermissionRequest` uses `scripts\danger-gate.ps1` with the all-events matcher.
6. Press `t` to trust each reviewed definition and confirm `/hooks` reports them active.

Do not use `--dangerously-bypass-hook-trust` for a normal installation. Restart Codex Desktop or create a new task after trusting the hook.

## 5. Safe verification

Create a disposable test directory:

```powershell
$testPath = Join-Path $env:TEMP 'codex-danger-gate-test'
New-Item -ItemType Directory -Path $testPath -Force | Out-Null
Set-Content -LiteralPath (Join-Path $testPath 'dummy.txt') -Value 'Danger Gate test only'
$testPath
```

In a new Codex task, ask the Agent to delete only the printed disposable directory.

This verification can exercise either a supported `PreToolUse` event or a sandbox `PermissionRequest`. Keep the disposable directory outside the task's active workspace; otherwise a wrapped action may already have write permission and emit neither event.

Expected behavior:

1. Danger Gate opens a separate confirmation window.
2. Clicking **Deny** leaves the test directory in place.
3. The dialog identifies whether it came from `PreToolUse` or `PermissionRequest`.
4. Clicking **Allow once** releases the gate, but Codex may still require its normal sandbox approval. The two approval layers are independent.
5. If no dialog appears, the current Codex build did not expose that route to either hard hook. Treat it as behavioral-policy-only coverage.

Never use real documents, repositories, photos, backups, or production data for an initial test.

## 6. Offline installation from a release ZIP

Open the [latest release page](https://github.com/wilsongpt1/codex-danger-gate/releases/latest) and download:

- `codex-danger-gate-<version>.zip`
- `codex-danger-gate-<version>.zip.sha256.txt`

Verify the download:

```powershell
$zip = "$env:USERPROFILE\Downloads\codex-danger-gate-<version>.zip"
Get-FileHash -LiteralPath $zip -Algorithm SHA256
Get-Content -LiteralPath "$zip.sha256.txt"
```

The two SHA-256 values must match. Do not install a mismatched archive.

Extract the ZIP to a stable directory such as:

```text
C:\Users\<username>\CodexPlugins\codex-danger-gate\
```

The extracted marketplace root must contain:

```text
codex-danger-gate\
├─ .agents\plugins\marketplace.json
├─ plugins\codex-danger-gate\.codex-plugin\plugin.json
├─ plugins\codex-danger-gate\hooks\hooks.json
├─ plugins\codex-danger-gate\scripts\danger-gate.ps1
├─ plugins\codex-danger-gate\scripts\safety-context.ps1
├─ INSTALL.md
└─ README.md
```

Register the extracted directory and install the plugin:

```powershell
$marketplace = "$env:USERPROFILE\CodexPlugins\codex-danger-gate"

if (-not (Test-Path -LiteralPath "$marketplace\.agents\plugins\marketplace.json")) {
    throw "marketplace.json was not found. Check the extraction path."
}

& $codexExe plugin marketplace add $marketplace
& $codexExe plugin add codex-danger-gate@danger-gate
```

Complete the hook trust steps in section 4.

## 7. Update

For a GitHub-backed installation:

```powershell
& $codexExe plugin marketplace upgrade danger-gate
& $codexExe plugin remove codex-danger-gate@danger-gate
& $codexExe plugin add codex-danger-gate@danger-gate
```

For an offline installation, remove the installed plugin and marketplace registration, replace the extracted directory with the new release, then register and install it again.

Start a new task after updating. If `/hooks` reports that the hook changed, review the new definition before trusting it.

## 8. Remove

```powershell
& $codexExe plugin remove codex-danger-gate@danger-gate
& $codexExe plugin marketplace remove danger-gate
```

After both commands succeed, you may delete the extracted offline marketplace directory.

## 9. Troubleshooting

See [Troubleshooting](docs/TROUBLESHOOTING.md) for hook trust, missing dialogs, CLI discovery, false positives, and log-safe diagnostics.

## 10. Security limits

Danger Gate is an additional guardrail, not a complete sandbox. It cannot hard-block actions that Codex exposes to neither `PreToolUse` nor `PermissionRequest`, including wrapped actions inside an already writable workspace. The automatically injected startup policy is behavioral guidance, not enforcement. Continue using least-privilege filesystem and cloud credentials, disposable workspaces, network restrictions, Git, tested backups, and separate development and production environments.
