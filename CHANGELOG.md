# Changelog

All notable changes to this project are documented in this file. Versions follow [Semantic Versioning](https://semver.org/).

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
