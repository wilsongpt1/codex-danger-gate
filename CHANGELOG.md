# Changelog

All notable changes to this project are documented in this file. Versions follow [Semantic Versioning](https://semver.org/).

## [0.3.1] - 2026-07-16

### Changed

- Corrected the protection claims after a live end-to-end test on Codex App and bundled CLI 0.144.2 deleted a disposable file through `functions.exec` → `shell_command` without emitting a usable `PreToolUse` or `PermissionRequest` hook event.
- Marked the tested wrapper route as having no Danger Gate hard protection, even when all plugin hooks are installed, trusted, and active.
- Reworked the verification and launch guidance so a missing dialog is treated as a demonstrated coverage result rather than a successful installation test.

No detection or hook behavior changed in this release. Existing event-dependent gates remain installed for Codex builds and tool handlers that expose their events.

## [0.3.0] - 2026-07-16

### Added

- Added `PermissionRequest` gating for sandbox escalation events Codex exposes, with an independent confirmation dialog before the normal approval flow.
- Added concise destructive-action confirmation context through `SessionStart` and `SubagentStart` without modifying user `AGENTS.md` files.
- Added wrapped-command input handling and automated coverage for permission requests and startup context.

### Changed

- Reframed the project as a layered guardrail and documented hard gates, behavioral safeguards, native sandbox boundaries, and routes with no hard coverage separately.
- Made writable-workspace and `functions.exec` limitations prominent throughout installation, testing, detection, and troubleshooting guidance.

## [0.2.1] - 2026-07-16

### Changed

- Documented that the current Codex Desktop `functions.exec` → `shell_command` route is not exposed to `PreToolUse` and therefore bypasses Danger Gate.
- Added a route-by-route coverage matrix, clearer sandbox-versus-plugin troubleshooting, and safer verification guidance.
- Added optional compact `AGENTS.md` guidance as a non-enforcing defense-in-depth measure without modifying user repositories.

## [0.2.0] - 2026-07-16

### Added

- Public GitHub installation through `codex plugin marketplace add wilsongpt1/codex-danger-gate`
- Complete English installation, update, removal, detection, troubleshooting, security, support, and contribution documentation
- MIT license, issue forms, pull request template, community standards, and automated Windows validation
- Dependency-free detection smoke tests and automated release packaging

### Changed

- Renamed the repository and release archives to `codex-danger-gate`
- Improved Windows PowerShell 5.1 UTF-8 hook-input handling
- Improved the confirmation window with wrapped text and vertical scrolling

## [0.1.2] - 2026-07-16

### Added

- Initial public preview with a Windows `PreToolUse` confirmation gate
- Detection for destructive shell, patch, Git, database, infrastructure, system, security, and MCP operations
- Fail-closed behavior for denial, timeout, malformed input, and internal errors
