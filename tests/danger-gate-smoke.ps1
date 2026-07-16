[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$gate = Resolve-Path (Join-Path $PSScriptRoot '..\plugins\codex-danger-gate\scripts\danger-gate.ps1')
$cases = @(
    @{ Name = 'safe command'; Event = 'PreToolUse'; Tool = 'Bash'; Input = @{ command = 'Get-ChildItem -LiteralPath C:\Temp' }; Risky = $false; Finding = $null },
    @{ Name = 'file deletion'; Event = 'PreToolUse'; Tool = 'Bash'; Input = @{ command = 'Remove-Item -LiteralPath C:\Temp\example.txt' }; Risky = $true; Finding = 'filesystem-delete' },
    @{ Name = 'hard reset'; Event = 'PreToolUse'; Tool = 'Bash'; Input = @{ command = 'git reset --hard HEAD~1' }; Risky = $true; Finding = 'git-reset-hard' },
    @{ Name = 'database drop'; Event = 'PreToolUse'; Tool = 'Bash'; Input = @{ command = 'DROP TABLE customers;' }; Risky = $true; Finding = 'database-destructive' },
    @{ Name = 'patch deletion'; Event = 'PreToolUse'; Tool = 'apply_patch'; Input = @{ command = "*** Begin Patch`n*** Delete File: example.txt`n*** End Patch" }; Risky = $true; Finding = 'patch-delete' },
    @{ Name = 'destructive MCP name'; Event = 'PreToolUse'; Tool = 'mcp__supabase__delete_project'; Input = @{ project = 'dummy' }; Risky = $true; Finding = 'destructive-mcp' },
    @{ Name = 'safe permission escalation'; Event = 'PermissionRequest'; Tool = 'functions.exec'; Input = 'Get-ChildItem -LiteralPath C:\Protected'; Risky = $true; Finding = 'sandbox-permission-request' },
    @{ Name = 'destructive permission escalation'; Event = 'PermissionRequest'; Tool = 'functions.exec'; Input = 'await tools.shell_command({"command":"Remove-Item -LiteralPath C:\\Protected\\example.txt"});'; Risky = $true; Finding = 'filesystem-delete' },
    @{ Name = 'Unicode input'; Event = 'PreToolUse'; Tool = 'Bash'; Input = @{ command = 'Write-Output "Unicode safety test — café"' }; Risky = $false; Finding = $null }
)

function Invoke-Detection {
    param(
        [string]$Event,
        [string]$Tool,
        [object]$InputObject,
        [string]$Mode = '-DetectOnly'
    )

    $payload = @{
        hook_event_name = $Event
        tool_name = $Tool
        cwd = 'C:\Temp'
        tool_input = $InputObject
    } | ConvertTo-Json -Depth 10 -Compress

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = 'powershell.exe'
    $startInfo.Arguments = "-NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$gate`" $Mode"
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardInput = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    if (-not $process.Start()) {
        throw 'Unable to start the detection process.'
    }

    $utf8 = New-Object System.Text.UTF8Encoding($false)
    $bytes = $utf8.GetBytes($payload)
    $process.StandardInput.BaseStream.Write($bytes, 0, $bytes.Length)
    $process.StandardInput.Close()

    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    if ($process.ExitCode -ne 0) {
        throw "Detection process failed with exit code $($process.ExitCode): $stderr"
    }

    return $stdout | ConvertFrom-Json
}

$failures = [System.Collections.Generic.List[string]]::new()

$preToolDeny = Invoke-Detection -Event 'PreToolUse' -Tool 'Bash' -InputObject @{ command = 'Remove-Item -LiteralPath C:\Temp\example.txt' } -Mode '-DenyOnly'
if ($preToolDeny.hookSpecificOutput.hookEventName -ne 'PreToolUse' -or $preToolDeny.hookSpecificOutput.permissionDecision -ne 'deny') {
    $failures.Add('PreToolUse deny output did not contain permissionDecision=deny')
}

$permissionDeny = Invoke-Detection -Event 'PermissionRequest' -Tool 'functions.exec' -InputObject 'Get-ChildItem -LiteralPath C:\Protected' -Mode '-DenyOnly'
if ($permissionDeny.hookSpecificOutput.hookEventName -ne 'PermissionRequest' -or $permissionDeny.hookSpecificOutput.decision.behavior -ne 'deny') {
    $failures.Add('PermissionRequest deny output did not contain decision.behavior=deny')
}

foreach ($case in $cases) {
    $result = Invoke-Detection -Event $case.Event -Tool $case.Tool -InputObject $case.Input
    $findingIds = @($result.findings | ForEach-Object { $_.Id })

    if ([bool]$result.risky -ne [bool]$case.Risky) {
        $failures.Add("$($case.Name): expected risky=$($case.Risky), got risky=$($result.risky)")
        continue
    }

    if ($null -ne $case.Finding -and $findingIds -notcontains $case.Finding) {
        $failures.Add("$($case.Name): expected finding '$($case.Finding)', got '$($findingIds -join ', ')' ")
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host "Passed $($cases.Count) detection cases and 2 deny-output cases."
