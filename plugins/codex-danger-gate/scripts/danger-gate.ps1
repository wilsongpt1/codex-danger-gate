[CmdletBinding()]
param(
    [switch]$DetectOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Add-Finding {
    param(
        [System.Collections.Generic.List[object]]$Findings,
        [string]$Id,
        [string]$Reason
    )

    if (-not ($Findings | Where-Object { $_.Id -eq $Id })) {
        $Findings.Add([pscustomobject]@{
            Id = $Id
            Reason = $Reason
        })
    }
}

function Get-RiskFindings {
    param(
        [string]$ToolName,
        [string]$Command
    )

    $findings = [System.Collections.Generic.List[object]]::new()

    if ($ToolName -match '^(apply_patch|Edit|Write)$') {
        if ($Command -match '(?im)^\*\*\*\s+Delete File:') {
            Add-Finding $findings "patch-delete" "The patch deletes one or more files."
        }
        if ($Command -match '(?im)^\*\*\*\s+Move to:') {
            Add-Finding $findings "patch-move" "The patch moves or renames a file."
        }
        return $findings
    }

    if ($ToolName -match '^mcp__') {
        if ($ToolName -match '(?i)(delete|remove|destroy|drop|truncate|purge|wipe|revoke|terminate|uninstall|unpublish|force_push|reset)') {
            Add-Finding $findings "destructive-mcp" "The MCP tool name indicates a destructive or irreversible action."
        }
        return $findings
    }

    $rules = @(
        @{ Id = "filesystem-delete"; Pattern = '(?i)(?:^|[\s;&|])(?:Remove-Item|Clear-Content|rm|del|erase|rmdir|rd|shred)(?:\.exe)?(?:\s|$)'; Reason = "The command deletes files, directories, or file contents." },
        @{ Id = "filesystem-format"; Pattern = '(?i)(?:^|[\s;&|])(?:format|diskpart|mkfs(?:\.[a-z0-9]+)?|wipefs)(?:\.exe)?(?:\s|$)'; Reason = "The command can format or repartition storage." },
        @{ Id = "raw-disk-write"; Pattern = '(?i)(?:^|[\s;&|])dd(?:\.exe)?\s+[^\r\n]*\bof\s*=\s*(?:/dev/|\\\\\.\\)'; Reason = "The command writes directly to a disk device." },
        @{ Id = "git-reset-hard"; Pattern = '(?i)(?:^|[\s;&|])git(?:\.exe)?\s+reset\s+[^\r\n;&|]*--hard\b'; Reason = "git reset --hard can discard uncommitted work." },
        @{ Id = "git-clean-force"; Pattern = '(?i)(?:^|[\s;&|])git(?:\.exe)?\s+clean\s+[^\r\n;&|]*(?:--force\b|-[a-z]*f[a-z]*\b)'; Reason = "git clean with force can permanently delete untracked files." },
        @{ Id = "git-discard"; Pattern = '(?i)(?:^|[\s;&|])git(?:\.exe)?\s+(?:checkout\s+--|restore\s+[^\r\n;&|]*(?:--worktree|--source))'; Reason = "The Git command can discard working-tree changes." },
        @{ Id = "git-force-push"; Pattern = '(?i)(?:^|[\s;&|])git(?:\.exe)?\s+push\s+[^\r\n;&|]*(?:--force(?:-with-lease)?\b|-f\b)'; Reason = "A force push can rewrite shared remote history." },
        @{ Id = "git-delete-branch"; Pattern = '(?i)(?:^|[\s;&|])git(?:\.exe)?\s+branch\s+-D\b'; Reason = "The command force-deletes a Git branch." },
        @{ Id = "database-destructive"; Pattern = '(?i)\b(?:DROP\s+(?:DATABASE|SCHEMA|TABLE)|TRUNCATE\s+TABLE)\b'; Reason = "The command contains a destructive database operation." },
        @{ Id = "terraform-destroy"; Pattern = '(?i)(?:^|[\s;&|])terraform(?:\.exe)?\s+(?:destroy|apply\s+[^\r\n;&|]*-destroy)\b'; Reason = "The Terraform command can destroy infrastructure." },
        @{ Id = "cluster-delete"; Pattern = '(?i)(?:^|[\s;&|])(?:kubectl(?:\.exe)?\s+delete|helm(?:\.exe)?\s+uninstall)\b'; Reason = "The command deletes cluster resources or a Helm release." },
        @{ Id = "cloud-delete"; Pattern = '(?i)(?:^|[\s;&|])(?:aws(?:\.exe)?\s+s3\s+rm\b[^\r\n;&|]*--recursive|az(?:\.exe)?\s+group\s+delete\b|gcloud(?:\.cmd|\.exe)?\s+[^\r\n;&|]*\bdelete\b)'; Reason = "The command can recursively delete cloud resources." },
        @{ Id = "system-shutdown"; Pattern = '(?i)(?:^|[\s;&|])(?:shutdown|Stop-Computer|Restart-Computer)(?:\.exe)?(?:\s|$)'; Reason = "The command shuts down or restarts the computer." },
        @{ Id = "process-force-kill"; Pattern = '(?i)(?:^|[\s;&|])(?:taskkill(?:\.exe)?\s+[^\r\n;&|]*/F\b|Stop-Process\s+[^\r\n;&|]*-Force\b)'; Reason = "The command forcibly terminates a process." },
        @{ Id = "registry-delete"; Pattern = '(?i)(?:^|[\s;&|])reg(?:\.exe)?\s+delete\b'; Reason = "The command deletes Windows registry data." },
        @{ Id = "service-delete"; Pattern = '(?i)(?:^|[\s;&|])sc(?:\.exe)?\s+delete\b'; Reason = "The command deletes a Windows service." },
        @{ Id = "backup-delete"; Pattern = '(?i)(?:^|[\s;&|])(?:vssadmin(?:\.exe)?\s+delete\s+shadows|wbadmin(?:\.exe)?\s+delete)\b'; Reason = "The command deletes backups or volume shadow copies." },
        @{ Id = "security-disable"; Pattern = '(?i)(?:Set-MpPreference\s+[^\r\n;&|]*(?:-DisableRealtimeMonitoring\s+\$?true|-DisableIOAVProtection\s+\$?true)|Set-NetFirewallProfile\s+[^\r\n;&|]*-Enabled\s+False)'; Reason = "The command weakens endpoint or firewall protection." },
        @{ Id = "permission-takeover"; Pattern = '(?i)(?:^|[\s;&|])(?:takeown|icacls)(?:\.exe)?\s+[^\r\n;&|]*(?:/F|/grant|/reset|/setowner)\b'; Reason = "The command takes ownership or broadly changes filesystem permissions." },
        @{ Id = "encoded-command"; Pattern = '(?i)(?:powershell|pwsh)(?:\.exe)?\s+[^\r\n;&|]*(?:-EncodedCommand|-enc)\b'; Reason = "The command uses an encoded PowerShell payload that is difficult to review." }
    )

    foreach ($rule in $rules) {
        if ($Command -match $rule.Pattern) {
            Add-Finding $findings $rule.Id $rule.Reason
        }
    }

    return $findings
}

function Show-ConfirmationDialog {
    param(
        [string]$ToolName,
        [string]$WorkingDirectory,
        [string]$Command,
        [object[]]$Findings
    )

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [System.Windows.Forms.Application]::EnableVisualStyles()

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Codex high-risk action confirmation"
    $form.Size = New-Object System.Drawing.Size(820, 590)
    $form.MinimumSize = New-Object System.Drawing.Size(680, 480)
    $form.StartPosition = "CenterScreen"
    $form.TopMost = $true
    $form.ShowInTaskbar = $true
    $form.FormBorderStyle = "Sizable"

    $heading = New-Object System.Windows.Forms.Label
    $heading.Text = "A high-risk Agent action is waiting for your approval."
    $heading.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $heading.AutoSize = $true
    $heading.Location = New-Object System.Drawing.Point(18, 16)
    $form.Controls.Add($heading)

    $warning = New-Object System.Windows.Forms.Label
    $warning.Text = "Approve for me does not answer this dialog. If you do nothing, the action is denied after 90 seconds."
    $warning.AutoSize = $true
    $warning.Location = New-Object System.Drawing.Point(20, 48)
    $form.Controls.Add($warning)

    $details = New-Object System.Windows.Forms.RichTextBox
    $details.Multiline = $true
    $details.ReadOnly = $true
    $details.WordWrap = $true
    $details.ScrollBars = [System.Windows.Forms.RichTextBoxScrollBars]::Vertical
    $details.DetectUrls = $false
    $details.Font = New-Object System.Drawing.Font("Consolas", 9)
    $details.Location = New-Object System.Drawing.Point(20, 82)
    $details.Size = New-Object System.Drawing.Size(762, 405)
    $details.Anchor = "Top,Bottom,Left,Right"

    $riskText = ($Findings | ForEach-Object { "- $($_.Reason)" }) -join [Environment]::NewLine
    $displayCommand = if ($Command.Length -gt 16000) { $Command.Substring(0, 16000) + "`r`n...[truncated]" } else { $Command }
    $details.Text = @"
Tool: $ToolName
Working directory: $WorkingDirectory

Detected risks:
$riskText

Pending input:
$displayCommand
"@
    $form.Controls.Add($details)

    $denyButton = New-Object System.Windows.Forms.Button
    $denyButton.Text = "Deny"
    $denyButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $denyButton.Size = New-Object System.Drawing.Size(120, 34)
    $denyButton.Location = New-Object System.Drawing.Point(526, 500)
    $denyButton.Anchor = "Bottom,Right"
    $form.Controls.Add($denyButton)

    $allowButton = New-Object System.Windows.Forms.Button
    $allowButton.Text = "Allow once"
    $allowButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $allowButton.Size = New-Object System.Drawing.Size(120, 34)
    $allowButton.Location = New-Object System.Drawing.Point(662, 500)
    $allowButton.Anchor = "Bottom,Right"
    $form.Controls.Add($allowButton)

    $form.AcceptButton = $allowButton
    $form.CancelButton = $denyButton

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 90000
    $timer.Add_Tick({
        $timer.Stop()
        $form.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $form.Close()
    })
    $form.Add_Shown({
        $form.Activate()
        $denyButton.Focus()
        $timer.Start()
    })

    try {
        $result = $form.ShowDialog()
        return $result -eq [System.Windows.Forms.DialogResult]::OK
    }
    finally {
        $timer.Stop()
        $timer.Dispose()
        $form.Dispose()
    }
}

function Write-DenyDecision {
    param([string]$Reason)

    @{
        hookSpecificOutput = @{
            hookEventName = "PreToolUse"
            permissionDecision = "deny"
            permissionDecisionReason = $Reason
        }
    } | ConvertTo-Json -Depth 4 -Compress | Write-Output
}

try {
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
        throw "The hook received no input."
    }

    $hookInput = $rawInput | ConvertFrom-Json
    $toolName = [string]$hookInput.tool_name
    $workingDirectory = [string]$hookInput.cwd

    if ([string]::IsNullOrWhiteSpace($toolName)) {
        throw "The hook input did not contain tool_name."
    }

    $command = ""
    if ($null -ne $hookInput.tool_input) {
        if ($hookInput.tool_input.PSObject.Properties.Name -contains "command") {
            $command = [string]$hookInput.tool_input.command
        }
        elseif ($toolName -match '^mcp__') {
            $command = $hookInput.tool_input | ConvertTo-Json -Depth 20
        }
    }

    $findings = @(Get-RiskFindings -ToolName $toolName -Command $command)

    if ($DetectOnly) {
        @{
            risky = $findings.Count -gt 0
            tool = $toolName
            findings = $findings
        } | ConvertTo-Json -Depth 5 -Compress | Write-Output
        exit 0
    }

    if ($findings.Count -eq 0) {
        exit 0
    }

    $approved = Show-ConfirmationDialog -ToolName $toolName -WorkingDirectory $workingDirectory -Command $command -Findings $findings
    if (-not $approved) {
        Write-DenyDecision "High-risk action denied or confirmation timed out."
    }
}
catch {
    if ($DetectOnly) {
        Write-Error $_
        exit 1
    }

    Write-DenyDecision "High-risk confirmation gate failed closed: $($_.Exception.Message)"
}
