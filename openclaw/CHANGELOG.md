# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.3] - 2026-02-03

### Fixed

- WebSocket disconnection when accessing Web UI through HA sidebar (ingress)
- Telegram plugin not auto-enabling ("configured, not enabled yet")
- Gateway now runs behind nginx reverse proxy for proper WebSocket proxying

### Added

- nginx reverse proxy for reliable ingress WebSocket support
- Auto-run `openclaw doctor --fix` during initialization to enable configured plugins

## [1.0.1] - 2026-02-03

### Added

- Web UI button to access OpenClaw control interface
- Sidebar panel integration with robot icon
- Exposed port 18789 for web UI access

### Changed

- Port 18789 now accessible (changed from null to 18789)
- Updated port description to reflect web UI access

## [1.0.0] - 2026-02-03

### Added

- Initial release of OpenClaw AI Assistant addon
- Telegram bot integration with pairing-based authentication
- Claude Opus 4.5 model support via Claude Pro or Anthropic API
- Built-in Chromium browser for web automation
- Playwright integration for advanced browser tasks
- Power-user features enabled by default:
  - Persistent home directory
  - Browser cache preservation
  - Tool installation persistence
- Data persistence across restarts:
  - `/data/openclaw-config` - Configuration and tokens
  - `/data/openclaw-workspace` - User workspace files
  - `/data/openclaw-home` - Browser cache and tools
- S6 overlay for robust service management
- Automatic gateway token generation
- Comprehensive documentation and setup guide
- Support for additional system packages
- Configurable log levels
- Health check monitoring

### Technical Details

- Built from OpenClaw source (latest)
- Multi-stage Docker build for optimized image size
- Node.js 22 with Bun and pnpm
- Debian base image for compatibility
- amd64 architecture support

### Security

- Pairing-based authentication for Telegram
- Secure token storage
- Containerized execution
- Non-root user execution (node user)

### Known Issues

- First startup takes 10-15 minutes due to building OpenClaw from source
- Chromium installation adds ~1GB to image size

### Credits

- OpenClaw team for the amazing AI assistant framework
- Anthropic for Claude Opus 4.5
- Home Assistant community
