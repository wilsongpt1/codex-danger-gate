[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$utf8 = New-Object System.Text.UTF8Encoding($false)
$stdin = [Console]::OpenStandardInput()
$reader = New-Object System.IO.StreamReader($stdin, $utf8, $true)
try {
    $rawInput = $reader.ReadToEnd()
}
finally {
    $reader.Dispose()
}

if ([string]::IsNullOrWhiteSpace($rawInput)) {
    throw "The safety-context hook received no input."
}

$hookInput = $rawInput | ConvertFrom-Json
$hookEventName = [string]$hookInput.hook_event_name
if ($hookEventName -notin @('SessionStart', 'SubagentStart')) {
    throw "Unsupported safety-context hook event: $hookEventName"
}

$policy = "Before any destructive or irreversible action, state the exact target, scope, and material effect, then wait for the user's explicit confirmation of that specific action. A tool or sandbox approval does not count as confirmation. If the target, scope, or material effect changes, stop and ask again. Do not use an alternate execution route to avoid this requirement."

@{
    hookSpecificOutput = @{
        hookEventName = $hookEventName
        additionalContext = $policy
    }
} | ConvertTo-Json -Depth 4 -Compress | Write-Output
