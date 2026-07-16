[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$contextHook = Resolve-Path (Join-Path $PSScriptRoot '..\plugins\codex-danger-gate\scripts\safety-context.ps1')
$events = @('SessionStart', 'SubagentStart')
$failures = [System.Collections.Generic.List[string]]::new()

foreach ($eventName in $events) {
    $payload = @{
        hook_event_name = $eventName
        cwd = 'C:\Temp'
    } | ConvertTo-Json -Compress

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = 'powershell.exe'
    $startInfo.Arguments = "-NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$contextHook`""
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardInput = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    if (-not $process.Start()) {
        throw 'Unable to start the safety-context process.'
    }

    $utf8 = New-Object System.Text.UTF8Encoding($false)
    $bytes = $utf8.GetBytes($payload)
    $process.StandardInput.BaseStream.Write($bytes, 0, $bytes.Length)
    $process.StandardInput.Close()

    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    if ($process.ExitCode -ne 0) {
        $failures.Add("$eventName failed with exit code $($process.ExitCode): $stderr")
        continue
    }

    $result = $stdout | ConvertFrom-Json
    $output = $result.hookSpecificOutput
    if ($output.hookEventName -ne $eventName) {
        $failures.Add("$eventName returned hookEventName '$($output.hookEventName)'")
    }
    if ([string]$output.additionalContext -notmatch 'exact target, scope, and material effect') {
        $failures.Add("$eventName did not return the destructive-action confirmation policy")
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host "Passed $($events.Count) safety-context smoke tests."
