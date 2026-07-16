# Codex Danger Gate

Repository: https://github.com/wilsongpt1/codes-danger-gate

## 中文快速開始

Codex Danger Gate 是一個以 Windows 為主的 Codex plugin。當 Agent 準備執行受支援的高危操作時，它會先顯示獨立確認視窗；這個視窗不受目前 task 的 **Approve for me** 設定控制。

完整的繁體中文 Windows 安裝、hook trust、安全測試、更新、移除及疑難排解步驟：

➡️ **[閱讀 INSTALL.md](INSTALL.md)**

發佈版 ZIP 可在 [GitHub Releases](https://github.com/wilsongpt1/codes-danger-gate/releases) 下載。

只有真人按下 **Allow once** 才會放行。按 **Deny**、關閉視窗、90 秒逾時或 gate 發生錯誤都會拒絕操作。

## Overview

Codex Danger Gate is a Windows-focused Codex plugin that asks a human to confirm supported high-risk Agent actions before they run. The confirmation dialog is independent of the session's **Approve for me** setting.

## What it detects

- File and directory deletion or content clearing
- Disk formatting and raw device writes
- Destructive Git commands, including `reset --hard`, forced clean, and force push
- Destructive database and infrastructure commands
- System shutdown, force-kill, registry/service deletion, and backup deletion
- Selected security weakening and permission takeover commands
- File deletion or movement through `apply_patch`
- MCP tool names that indicate destructive operations

Denial, timeout, malformed hook input, and internal errors fail closed.

## Install

For detailed Traditional Chinese instructions, see [INSTALL.md](INSTALL.md).

1. Download the latest ZIP from [GitHub Releases](https://github.com/wilsongpt1/codes-danger-gate/releases) and extract it to a stable local path.
2. Register the marketplace:

   ```powershell
   codex plugin marketplace add "C:\path\to\codex-danger-gate-marketplace"
   ```

3. Install the plugin:

   ```powershell
   codex plugin add codex-danger-gate@wilson-security
   ```

4. Restart Codex or start a new task.
5. Run `/hooks`, review the plugin hook, and trust it.

## Update

Remove the installed plugin and marketplace registration, replace the extracted marketplace with the new version, then register and install it again. Start a new task and review the hook again if Codex reports that its hash changed.

## Remove

Remove `codex-danger-gate@wilson-security` from `/plugins` or with the supported `codex plugin` removal command shown by `codex plugin --help`. Remove the marketplace only after no installed plugin depends on it.

## Security boundary

This plugin is a guardrail, not a complete sandbox. Codex currently does not expose every shell or tool path to `PreToolUse`. Keep `read-only` or least-privilege filesystem permissions, network restrictions, backups, and version control enabled. A user-installed plugin can also be disabled; organization-enforced protection requires a managed hook deployed through administrator-controlled requirements.
