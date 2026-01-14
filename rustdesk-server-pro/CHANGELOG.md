# Changelog

All notable changes to this add-on will be documented in this file.

## [1.4.0] - 2026-01-15

### Changed
- Updated base image to RustDesk Server Pro 1.7.3 (from 1.7.2)

### RustDesk Server Pro 1.7.3 Highlights
- Bug fixes and stability improvements

## [1.3.0] - 2025-12-13

### Added
- Configuration option: `always_use_relay` - forces all connections through relay server
- Helps with VPN/Tailscale setups where direct peer connections show incorrect online status

## [1.2.1] - 2025-12-13

### Added
- Open Web UI button on add-on info page to launch RustDesk web console (port 21114)

## [1.2.0] - 2025-12-13

### Changed
- Pinned base image to RustDesk Server Pro 1.7.2 (previously used :latest which was 1.6.9 as of 2025-11-09)
- Improved reproducibility by using explicit version tag instead of :latest

### RustDesk Server Pro 1.7.2 Highlights (since 1.6.9)
- Custom client for Windows x86
- Device group token and additional user API
- Custom web client support
- SMTP TLS fallback to plain
- Batch set address book peer tags
- 2FA enforcement and force logout
- OIDC group mapping (Okta/Azure/Keycloak/GitLab)
- Web client updated to 1.4.4

## [1.1.2] - 2025-11-09

### Fixed
- Corrected web console access documentation - port 21114, not 21118
- Added default credentials (admin/test1234) to documentation

## [1.1.1] - 2025-11-09

### Fixed
- **CRITICAL**: Added symlink /root -> /config for data persistence
- Data now persists across restarts and upgrades in /config directory

## [1.1.0] - 2025-11-09

### Changed
- **COMPLETE REWRITE**: Now exactly matches official RustDesk Docker documentation
- Simplified Dockerfile to minimal setup
- Simplified run.sh to run hbbr and hbbs from /root (as per official docs)
- Using /config mapped to /root for data persistence
- Removed all complexity - just runs the official commands

## [1.0.7] - 2025-11-09

### Fixed
- Removed bashio dependency (not available in RustDesk image)
- Using plain bash with echo for logging
- Should now start properly without bashio errors

## [1.0.6] - 2025-11-09

### Fixed
- Simplified run.sh to use /share/rustdesk for data (avoiding symlink complexity)
- Added set -e for better error handling
- Hardcoded binary paths to avoid discovery issues
- Changed from addon_config to share mapping for better compatibility

## [1.0.5] - 2025-11-09

### Fixed
- Updated icon with native 128x128 version from RustDesk repository

## [1.0.4] - 2025-11-09

### Fixed
- **CRITICAL:** Fixed working directory - RustDesk expects data in /root, not /config
- Added symlink from /root to /config to match official Docker documentation
- Services now run from /root directory as per RustDesk documentation

## [1.0.3] - 2025-11-09

### Fixed
- Hardcoded binary paths to /usr/bin/hbbs and /usr/bin/hbbr (confirmed location in RustDesk Pro image)
- Added binary existence validation before starting services

## [1.0.2] - 2025-11-09

### Fixed
- Replaced add-on icon with higher quality version from RustDesk repository

## [1.0.1] - 2025-11-09

### Fixed
- Fixed "command not found" error for hbbs and hbbr binaries
- Added dynamic binary location detection in run.sh
- Cleared ENTRYPOINT in Dockerfile to avoid conflicts with base image
- Added official RustDesk icon (128x128)

### Changed
- Improved binary discovery with fallback search paths
- Enhanced logging to show binary locations during startup

## [1.0.0] - 2025-11-09

### Added
- Initial release of RustDesk Server Pro add-on
- Support for RustDesk Pro server (hbbs and hbbr services)
- Web-based admin console access on port 21118
- Host networking support for proper licensing
- Multi-architecture support (aarch64, amd64, armhf, armv7)
- Comprehensive documentation and setup guides
- Automatic data persistence via addon_config mapping
- Complete port exposure for all RustDesk services (21114-21119)

### Features
- Self-hosted remote desktop server
- End-to-end encryption
- Multiple concurrent connections
- Address book and device management
- API server for Pro features
- NAT traversal and relay services

### Notes
- Requires valid RustDesk Pro license
- Uses host networking (required for licensing)
- License files stored in `/addon_configs/<slug>/` directory
