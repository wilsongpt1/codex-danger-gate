[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$gate = Resolve-Path (Join-Path $PSScriptRoot '..\plugins\codex-danger-gate\scripts\danger-gate.ps1')
$cases = @(
    @{ Name = 'safe command'; Tool = 'Bash'; Input = @{ command = 'Get-ChildItem -LiteralPath C:\Temp' }; Risky = $false; Finding = $null },
    @{ Name = 'file deletion'; Tool = 'Bash'; Input = @{ command = 'Remove-Item -LiteralPath C:\Temp\example.txt' }; Risky = $true; Finding = 'filesystem-delete' },
    @{ Name = 'hard reset'; Tool = 'Bash'; Input = @{ command = 'git reset --hard HEAD~1' }; Risky = $true; Finding = 'git-reset-hard' },
    @{ Name = 'database drop'; Tool = 'Bash'; Input = @{ command = 'DROP TABLE customers;' }; Risky = $true; Finding = 'database-destructive' },
    @{ Name = 'patch deletion'; Tool = 'apply_patch'; Input = @{ command = "*** Begin Patch`n*** Delete File: example.txt`n*** End Patch" }; Risky = $true; Finding = 'patch-delete' },
    @{ Name = 'destructive MCP name'; Tool = 'mcp__supabase__delete_project'; Input = @{ project = 'dummy' }; Risky = $true; Finding = 'destructive-mcp' },
    @{ Name = 'Unicode input'; Tool = 'Bash'; Input = @{ command = 'Write-Output "Unicode safety test — café"' }; Risky = $false; Finding = $null }
)

function Invoke-Detection {
    param(
        [string]$Tool,
        [hashtable]$InputObject
    )

    $payload = @{
        tool_name = $Tool
        cwd = 'C:\Temp'
        tool_input = $InputObject
    } | ConvertTo-Json -Depth 10 -Compress

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = 'powershell.exe'
    $startInfo.Arguments = "-NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$gate`" -DetectOnly"
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

foreach ($case in $cases) {
    $result = Invoke-Detection -Tool $case.Tool -InputObject $case.Input
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

Write-Host "Passed $($cases.Count) Danger Gate smoke tests."
