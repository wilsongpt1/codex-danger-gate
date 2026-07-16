# Contributing

Contributions that improve detection accuracy, Windows compatibility, documentation, tests, or accessibility are welcome.

## Before opening a pull request

1. Open an issue for broad behavior or architecture changes.
2. Keep each pull request focused on one problem.
3. Do not include credentials, private paths, production commands, or user data.
4. Add or update a smoke-test case for detection-rule changes.
5. Preserve fail-closed behavior for malformed input, timeout, and internal errors.

## Local development

Requirements:

- Windows PowerShell 5.1 or PowerShell 7
- Git
- A current Codex installation for manual integration testing

Clone the repository:

```powershell
git clone https://github.com/wilsongpt1/codex-danger-gate.git
Set-Location codex-danger-gate
```

Run the dependency-free smoke tests:

```powershell
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File .\tests\danger-gate-smoke.ps1
```

Check PowerShell syntax:

```powershell
$errors = @()
[System.Management.Automation.Language.Parser]::ParseFile(
    (Resolve-Path '.\plugins\codex-danger-gate\scripts\danger-gate.ps1'),
    [ref]$null,
    [ref]$errors
) | Out-Null
$errors
```

An empty result means the parser found no syntax errors.

## Detection rule guidelines

- Prefer narrow patterns that identify a destructive capability rather than a generic word.
- Include command boundaries so safe substrings do not trigger accidentally.
- Add a positive test and, when practical, a nearby negative test.
- Describe the risk in plain English because the reason appears in the confirmation window.
- Treat MCP name matching as a heuristic and document its limits.

## Pull requests

Complete the pull request template, describe security impact, and list the checks you ran. Maintainers may request changes when a rule is too broad, platform-specific behavior is untested, or the change weakens the security boundary.
