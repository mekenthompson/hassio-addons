# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.43] - 2026-07-17

### Fixed
- Adopted upstream DM topic thread routing fix (replaces scope-based #17980 fix)
- DM forum/topic threads now correctly preserve message_thread_id in outbound messages
- Fixed dmThreadId resolution using scope check instead of isGroup check
- Updated bot-message-context.ts and bot-native-commands.ts for correct thread scoping

## [1.0.38] - 2026-06-19

### Changed
- **Upgraded to OpenClaw 2026.2.15** — Latest upstream from main
- Incremented CACHEBUST to 10 for fresh rebuild

## [1.0.33] - 2026-02-12

### Fixed
- **Persist bun symlink for node user** - QMD (semantic search) now accessible
  - Added `.bun` to persistent storage symlinks in `init-openclaw-persist` script
  - Ensures `/home/node/.bun` persists across container rebuilds via `/data/openclaw-home/.bun`
  - Added `/home/node/.bun/bin` to PATH in gateway run script
  - Fixes issue where node user couldn't access bun/qmd installed for root during Docker build

## [1.0.30] - 2026-02-11

### Changed
- **Rebuilt from latest OpenClaw upstream** - Force fresh rebuild with incremented cache bust
- Incremented CACHEBUST to 3 and OPENCLAW_VERSION to 2026.2.11
- Pulls ~84 commits of upstream improvements (from fa21050 to 7f1712c)

## [1.0.29] - 2026-02-10

### Changed
- **Rebuilt from latest OpenClaw main** - Force fresh rebuild with cache busting
- Incremented CACHEBUST to 2 and OPENCLAW_VERSION to 2026.2.10
- Pulls ~33 commits of upstream improvements since last rebuild

## [1.0.25] - 2026-02-06

### Fixed
- **Web UI origin error** - Override Origin header in nginx to match Host header
  - OpenClaw's origin check does exact matching (no wildcard support)
  - HA ingress origin (port 8123) never matches addon port (18789), causing WebSocket disconnect
  - nginx now rewrites Origin to `http://$host` so it matches the request Host header

## [1.0.24] - 2026-02-06

### Fixed
- Added `allowedOrigins: ["*"]` to controlUi config (insufficient — see 1.0.25)
- Patches existing configs on startup to add missing `allowedOrigins`

## [1.0.23] - 2026-02-06

### Changed
- **Upgraded to OpenClaw main** (post-v2026.2.3) for Claude Opus 4.6 support and numerous fixes
- Removed runtime model patching hack (no longer needed)

### Key upstream fixes since v2026.2.3
- **Claude Opus 4.6** built-in model support (#9853)
- **Security:** Canvas host now requires auth, credentials redacted from gateway responses
- **Telegram:** DM topic threading, forum topic binding, group member allowlist fixes
- **Cron:** Scheduling regressions, timer re-arm on errors, legacy atMs handling
- **Stability:** Multiple compaction retries on context overflow, orphaned tool_results cleanup
- **New:** xAI Grok provider support

## [1.0.22] - 2026-02-06

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

### Fixed

- **Channels DVR add-on:** Fixed auto-restore triggering on every restart
  - Added database size check (empty = 32KB vs valid backup = 60KB)
  - Now only restores when `settings.db` is truly empty/corrupted
  - Prevents loop of restoring old data when DB is actually fine

## [1.0.14] - 2026-02-04

### Changed

- **Channels DVR add-on:** Improved resilience with NFS mount verification
  - Added loop checking NFS mount availability before starting server
  - Waits up to 60 seconds for mount, then starts anyway (server may handle it)
  - Better error logging when DVR directory isn't available

## [1.0.13] - 2026-02-04

### Fixed

- **Channels DVR add-on:** Fixed database corruption issue
  - Changed NFS mount from `soft,retrans=3` to `hard` for data integrity
  - Soft mounts can cause silent I/O errors leading to BoltDB corruption
  - Updated all existing configs that may have soft mount

## [1.0.12] - 2026-02-03

### Fixed

- **Channels DVR add-on:** Fixed version detection error
  - Changed from string parsing to proper integer extraction
  - Now correctly extracts build number from "YYYY.MM.DD.BBBB" format

## [1.0.11] - 2026-02-03

### Added

- New add-on: **Channels DVR Server**
  - Runs Channels DVR server directly in Home Assistant
  - Supports NFS mount for database and binary storage
  - Auto-updates DVR server binary when new versions available
  - Exposes port 8089 for web UI and client connections

## [1.0.10] - 2026-02-03

### Added

- **Persistent CLI tool configs** - `~/.config`, `~/.local`, and `~/.railway` directories now persist across restarts
  - Fixes GitHub CLI auth (`gh auth login`) being lost on restart
  - Fixes Railway CLI auth being lost on restart
  - Any tool that stores config in these locations will now persist

### Changed

- `~/.config`, `~/.local`, `~/.railway` are now symlinked to `/data/openclaw-home/` (same as persistent home)
- Previously only `/data/openclaw-home/` was available as persistent storage

### Migration

- Existing installations may need to manually move config from `/home/node/.config` to `/data/openclaw-home/.config` on first update
- New installations will work automatically

## [1.0.9] - 2026-02-03

### Fixed

- Channels DVR add-on: Fixed version comparison for updates
  - Version strings now properly converted to sortable integers
  - Example: "2025.10.30.0047" → 20251030004

## [1.0.8] - 2026-02-03

### Fixed

- Playwright Chromium installation now uses `/data/openclaw-home/.cache/ms-playwright` for persistence
- Browser installation survives add-on restarts
- Skip re-installation if browsers already present (faster startup)

### Changed

- Moved Playwright browser cache from `/home/node/.cache/ms-playwright` to `/data/openclaw-home/.cache/ms-playwright`
- Installation only runs on first startup after fresh install or cache clear

## [1.0.7] - 2026-02-03

### Fixed

- Channels DVR add-on: Fixed wget not found error
  - wget is now pre-installed in the Docker image
  - Removed runtime download of DVR server (not reliable)
  - Server binary must be present on NFS mount

## [1.0.6] - 2026-02-03

### Fixed

- OpenClaw config now persists correctly across add-on restarts
- Configuration created on first run is preserved for subsequent restarts
- Only generates fresh config when `/data/openclaw-config/openclaw.json` doesn't exist

### Changed

- Improved startup logging to show when config is preserved vs created
- Config file path logged for easier debugging

## [1.0.5] - 2026-02-03

### Fixed

- OpenClaw config directory symlink now properly created at `/home/node/.openclaw`
- Workspace directory structure corrected for proper file access
- Gateway token persistence improved

## [1.0.4] - 2026-02-03

### Added

- Persistent workspace storage at `/share/openclaw/workspace`
- Persistent credentials at `/share/openclaw/credentials`
- Support for additional apt packages via add-on config

### Fixed

- Configuration persistence across add-on restarts

## [1.0.3] - 2026-02-03

### Changed

- Disabled ingress port (using direct port 18789 only for now)
- Simplified nginx configuration

### Fixed

- Web UI access via direct port

## [1.0.2] - 2026-02-03

### Added

- Full Playwright/Chromium support for browser automation
- GitHub CLI (`gh`) pre-installed
- All required fonts for proper rendering

### Fixed

- Chromium dependencies properly installed

## [1.0.1] - 2026-02-03

### Added

- Initial release with OpenClaw AI Assistant
- Telegram integration for messaging
- Claude Opus 4.5 API support
- Web UI for configuration
- Home Assistant ingress support (sidebar panel)
