# Codex Danger Gate Windows 安裝指引

本指引適用於 Windows 10／11、Codex Desktop 及 Codex CLI。

## 1. 準備及解壓縮

前往以下頁面下載最新的 `codes-danger-gate-<版本>.zip`：

```text
https://github.com/wilsongpt1/codes-danger-gate/releases/latest
```

如果 Release 另外提供 SHA-256，請先驗證：

```powershell
Get-FileHash "$env:USERPROFILE\Downloads\codes-danger-gate-<版本>.zip" -Algorithm SHA256
```

SHA-256 不相同就不要安裝。

在 File Explorer 右鍵 ZIP，選擇 **Extract All**。建議解壓到固定位置：

```text
C:\Users\<你的用戶名>\CodexPlugins\DangerGate\
```

完成後應有以下檔案：

```text
codes-danger-gate\
├─ .agents\plugins\marketplace.json
├─ plugins\codex-danger-gate\.codex-plugin\plugin.json
├─ plugins\codex-danger-gate\hooks\hooks.json
├─ plugins\codex-danger-gate\scripts\danger-gate.ps1
├─ INSTALL.md
└─ README.md
```

## 2. 找出 Codex CLI

開啟 Windows PowerShell，貼上：

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
    throw "找不到 Codex CLI。請先安裝或更新 Codex Desktop。"
}

& $codexExe --version
```

成功時會顯示類似 `codex-cli 0.144.2`，實際版本可以較新。

## 3. 登記 Marketplace

請按實際解壓位置調整 `$marketplace`：

```powershell
$marketplace = "$env:USERPROFILE\CodexPlugins\DangerGate\codes-danger-gate"

if (-not (Test-Path -LiteralPath "$marketplace\.agents\plugins\marketplace.json")) {
    throw "找不到 marketplace.json，請檢查解壓路徑。"
}

& $codexExe plugin marketplace add $marketplace
```

## 4. 安裝 Plugin

```powershell
& $codexExe plugin add codex-danger-gate@wilson-security
```

## 5. Review及 Trust Hook

啟動 Codex CLI：

```powershell
& $codexExe
```

進入 CLI 後輸入：

```text
/hooks
```

然後：

1. 按 `Enter` review `PreToolUse` hook。
2. 確認來源是 `codex-danger-gate` plugin。
3. 確認 matcher 是 `^(Bash|apply_patch|Edit|Write|mcp__.*)$`。
4. 確認 command 指向 plugin 內的 `scripts\danger-gate.ps1`。
5. 按 `t` trust。
6. 返回後確認 `PreToolUse Installed: 1 Active: 1`。
7. 按 `Esc` 離開並關閉 CLI。
8. 重新啟動 Codex Desktop或建立新 task。

不要使用 `--dangerously-bypass-hook-trust` 作正式安裝。

## 6. 安全測試

先建立專用 dummy folder：

```powershell
$testPath = Join-Path $env:TEMP 'codex-danger-gate-test'
New-Item -ItemType Directory -Path $testPath -Force | Out-Null
Set-Content -LiteralPath (Join-Path $testPath 'dummy.txt') -Value 'Danger Gate test only'
$testPath
```

然後在新 Codex task 要求 Agent **只刪除剛才顯示的 dummy folder**。

預期結果：

1. Danger Gate 顯示獨立確認視窗。
2. 按 **Deny** 後，dummy folder 保留。
3. 再測試並按 **Allow once** 時，Codex仍可能要求正常 sandbox approval；兩層權限互相獨立。

切勿使用真實文件、相片、repository 或 production data 作首次測試。

## 7. 更新 Plugin

1. 關閉 Codex Desktop 及 CLI。
2. 移除目前安裝記錄：

   ```powershell
   & $codexExe plugin remove codex-danger-gate@wilson-security
   & $codexExe plugin marketplace remove wilson-security
   ```

3. 用新版 ZIP 內容取代原有 `codes-danger-gate` 目錄。
4. 重新登記及安裝：

   ```powershell
   & $codexExe plugin marketplace add $marketplace
   & $codexExe plugin add codex-danger-gate@wilson-security
   ```

5. 開新 task 測試新版。
6. 如果 `/hooks` 顯示 hook 需要 review，重新檢查及 trust。

## 8. 移除 Plugin

```powershell
& $codexExe plugin remove codex-danger-gate@wilson-security
& $codexExe plugin marketplace remove wilson-security
```

確認移除成功後，才手動刪除已解壓的 marketplace 目錄。

## 疑難排解

### `codex is not recognized`

重新執行本指引第 2 步，然後使用 `& $codexExe`，毋須直接輸入 `codex`。

### `/hooks` 變成普通聊天訊息

`/hooks` 必須在 Codex CLI TUI 裡輸入，不是在 Codex Desktop composer。

### `Installed: 1` 但 `Active: 0`

進入 `/hooks` review並 trust `PreToolUse` hook。完成後應顯示 `Active: 1`。

### 沒有彈出確認視窗

1. 確認 `/hooks` 顯示 `PreToolUse Active: 1`。
2. 關閉並重新啟動 Codex Desktop。
3. 建立新 task 再測試。
4. 確認測試指令屬於 Danger Gate 已涵蓋的規則。

## 安全限制

Danger Gate 是額外 guardrail，不是完整 sandbox。請繼續使用 least-privilege filesystem permissions、network restrictions、Git及離線備份；不要把首次測試或高風險 automation 直接連接 production data。
