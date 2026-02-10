# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.24] - 2026-02-10

### Changed
- **Rebuilt from latest OpenClaw main** - Force fresh rebuild with cache busting
- Added CACHEBUST arg (now 2) and updated OPENCLAW_VERSION to 2026.2.10
- Pulls ~33 commits of upstream improvements since last rebuild

## [1.0.21] - 2026-02-06

### Fixed
- **Web UI origin error** - Override Origin header in nginx to match Host header
  - OpenClaw's origin check does exact matching (no wildcard support)
  - HA ingress origin (port 8123) never matches addon port (18891), causing WebSocket disconnect
  - nginx now rewrites Origin to `http://$host` so it matches the request Host header

## [1.0.20] - 2026-02-06

### Fixed
- Added `allowedOrigins: ["*"]` to controlUi config (insufficient — see 1.0.21)
- Patches existing configs on startup to add missing `allowedOrigins`

## [1.0.19] - 2026-02-06

### Changed
- **Upgraded to OpenClaw main** (post-v2026.2.3) for Claude Opus 4.6 support and numerous fixes

### Key upstream fixes since v2026.2.3
- **Claude Opus 4.6** built-in model support (#9853)
- **Security:** Canvas host now requires auth, credentials redacted from gateway responses
- **Telegram:** DM topic threading, forum topic binding, group member allowlist fixes
- **Cron:** Scheduling regressions, timer re-arm on errors, legacy atMs handling
- **Stability:** Multiple compaction retries on context overflow, orphaned tool_results cleanup
- **New:** xAI Grok provider support

## [1.0.18] - 2026-02-06

### Changed

- **Upgraded to OpenClaw v2026.2.3** - Updated from v2026.2.2

### OpenClaw v2026.2.3 Upstream Changes

- **New Features:**
  - Telegram improvements with proper Grammy type definitions (removed @ts-nocheck)
  - Cloudflare AI Gateway provider support
  - Moonshot (.cn) authentication with preserved China base URLs
  - Per-channel responsePrefix overrides for message tools
  - Enhanced cron: ISO 8601 schedules, announce delivery mode, auto-cleanup of one-shot jobs
  - Shell completion optimization for faster terminal startup

- **Security Improvements:**
  - Enforced sandboxed media paths for message attachments
  - Required explicit credentials for gateway URL overrides (prevents credential leakage)
  - Gated whatsapp_login tool access to owner senders only
  - Hardened webhook verification with host allowlists and proxy trust validation
  - Untrusted channel metadata kept out of system prompts

- **Bug Fixes:**
  - Multi-account channel heartbeat routing with explicit accountId support
  - Telegram inline model selection persistence
  - Web UI agent model selection and workspace path text wrapping
  - Gateway control UI logo path resolution with basePath
  - Cron store data reloading when files recreated
  - macOS cron payload rendering and ISO 8601 formatter thread safety

- **Breaking Changes:**
  - Cron: Legacy post-to-main/payload delivery and atMs fields removed (migrated to announce/none modes)
  - **Note**: No impact on add-on functionality

## [1.0.17] - 2026-02-04

### Added
- Home Assistant Core API access (`homeassistant_api: true`) for entity state queries

### Fixed
- Web UI ingress broken: stripped CSP `frame-ancestors` and `X-Frame-Options` headers that blocked HA iframe embedding

## [1.0.16] - 2026-02-04

### Changed

- **Pinned to OpenClaw v2026.2.2** - Dockerfile now pins to specific OpenClaw version tag instead of latest
- This provides better stability and predictable updates

### OpenClaw v2026.2.2 Upstream Changes

- **New Features:**
  - Feishu/Lark plugin support for team collaboration
  - Web UI Agents dashboard for better agent management
  - QMD memory backend for enhanced memory storage
  - Default subagent thinking level configuration
- **Security Improvements:**
  - Operator approval system for sensitive operations
  - Matrix allowlists for enhanced security
  - SSRF (Server-Side Request Forgery) guards
  - Various security fixes across the platform
- **Reliability:**
  - Telegram long-poll error recovery improvements
  - Various agent/media/onboarding fixes and enhancements

## [1.0.15] - 2026-02-04

### Changed

- **OpenClaw upstream:** latest as of 2026-02-04
- Persist all `~/.config` and `~/.local` directories across container reboots
- Improves tool installation persistence and user configuration retention

### Added

- Persistent symlinks for `.config`, `.local`, and `.railway` in init script
- Better preservation of openclaw.json configuration across restarts (only created on first run)

### Fixed

- OpenClaw Lisa schema - telegram_bot_token now correctly marked as password type
- Configuration preservation across addon restarts

## [1.0.14] - 2026-02-04

### Changed

- **OpenClaw upstream:** latest as of 2026-02-04
- Persist GitHub CLI and git configuration across container reboots

### Added

- Enhanced persistence for developer tools and authentication

## [1.0.13] - 2026-02-03

### Added

- **OpenClaw upstream:** latest as of 2026-02-03
- ffmpeg for media processing capabilities
- ripgrep (rg) for fast text searching
- tmux for terminal multiplexing
- jq for JSON processing
- GitHub CLI (gh) for git operations and authentication

### Changed

- Enhanced development and media processing capabilities in the container environment

## [1.0.12] - 2026-02-03

### Added

- **OpenClaw upstream:** latest as of 2026-02-03
- Terminal access directly in Home Assistant addon UI
- Interactive shell access through the HA interface

### Changed

- Enabled stdin in addon configuration for terminal interactivity

## [1.0.11] - 2026-02-03

### Fixed

- **OpenClaw upstream:** latest as of 2026-02-03
- Claude authentication by properly exporting ANTHROPIC_API_KEY environment variable
- API key now correctly accessible to OpenClaw processes

## [1.0.10] - 2026-02-03

### Changed

- **OpenClaw upstream:** latest as of 2026-02-03
- Use fully qualified model names in configuration to silence deprecation warnings
- Improved model configuration clarity

## [1.0.9] - 2026-02-03

### Fixed

- **OpenClaw upstream:** latest as of 2026-02-03
- WebSocket connections by connecting directly to addon port instead of through ingress proxy
- Improved Web UI connectivity and real-time features

## [1.0.8] - 2026-02-03

### Fixed

- **OpenClaw upstream:** latest as of 2026-02-03
- Configuration keys updated to match current OpenClaw schema requirements
- Ensures proper configuration parsing and validation

## [1.0.7] - 2026-02-03

### Fixed

- **OpenClaw upstream:** latest as of 2026-02-03
- Configuration now written to `openclaw.json` (not `config.json`)
- Matches expected configuration file naming convention

## [1.0.6] - 2026-02-03

### Fixed

- **OpenClaw upstream:** latest as of 2026-02-03
- Ingress authentication with token-based auth and allowInsecureAuth setting
- Improved Web UI access through Home Assistant sidebar

## [1.0.5] - 2026-02-03

### Fixed

- **OpenClaw upstream:** latest as of 2026-02-03
- Inline ingress fix script to avoid file path resolution errors
- Improved startup reliability

## [1.0.4] - 2026-02-03

### Fixed

- **OpenClaw upstream:** latest as of 2026-02-03
- Nginx configuration variable parsing error with `$` characters
- Improved reverse proxy stability

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
