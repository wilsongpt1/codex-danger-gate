# Security Policy

## Supported versions

Security fixes are provided for the latest published release. Upgrade to the latest release before reporting an issue that may already be fixed.

## Report a vulnerability privately

Do not open a public issue for a vulnerability that could help bypass the gate, execute an action without confirmation, expose sensitive hook input, or weaken the fail-closed behavior.

Use [GitHub private vulnerability reporting](https://github.com/wilsongpt1/codex-danger-gate/security/advisories/new). Include:

- The affected release and Codex version
- Windows and PowerShell versions
- The tool name and a sanitized reproduction input
- Expected and observed behavior
- Whether the issue can bypass a deny decision
- A minimal proof of concept that contains no credentials or private data

You should receive an acknowledgement within seven days. Please allow time for investigation and a coordinated release before public disclosure.

## Security model

Codex Danger Gate inspects supported `PreToolUse` events exposed by Codex. The current Codex Desktop `functions.exec` → `shell_command` route is not exposed to that hook and bypasses this plugin. It is not a complete sandbox, malware scanner, command parser, database proxy, or organization-enforced policy. Review [Detection rules and limitations](docs/DETECTION_RULES.md) before relying on it.

## Secrets and diagnostic data

Never include API keys, access tokens, private SQL data, customer information, full conversation transcripts, or production paths in an issue. Replace sensitive values with clearly marked examples while preserving the structure needed to reproduce the problem.
