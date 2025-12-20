# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2024-12-20

### ⚠️ Breaking Changes

- Pin code-server to specific version (v4.107.0) instead of always pulling latest
- Add-on version now tracks independently from code-server version

### Added

- Version pinning for reproducible builds
- CHANGELOG.md for tracking version history
- AppArmor security profile for improved security rating
- Watchdog support for automatic restart on failure
- New configuration options:
  - `default_workspace`: Set the initial directory opened in VS Code
  - `init_commands`: Run custom commands on add-on startup
- Backup exclusions for cache directories to reduce backup size

### Changed

- Improved documentation with detailed configuration explanations
- Updated labels and metadata for better add-on store presentation
- Enhanced translations for configuration UI

### Security

- Added custom AppArmor profile (+1 security rating)

## [1.0.0] - 2024-12-01

### Added

- Initial release
- VS Code Server (code-server) running in browser
- Password authentication support
- Ingress support for Home Assistant integration
- Access to Home Assistant configuration files
- Persistent settings and extensions storage
- SSH and Git support
