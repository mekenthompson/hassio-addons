# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.5] - 2026-03-01
<!-- last-upstream-sha: 3685ccb536 -->

### Changed
- **Synced fork to upstream openclaw/openclaw main** (70 commits since last sync)
- GPU commits (browser `gpuEnabled` config) cherry-picked cleanly on top

### Fixed (upstream)
- **Memory flush gating** — correct context token accounting for flush decisions
- **Memory keyword search** — keep keyword hits when hybrid vector search misses
- **sessions_list transcriptPath** — path resolution fixed
- **Cron fixes (11)** — heartbeat target for main-session jobs, disable messaging tool when delivery.mode=none, avoid marking queued announce as delivered, completion direct send for text-only announce, force main-target system events onto main session, condition requireExplicitMessageTarget on delivery, schedule nextWakeAtMs for isolated sessionTarget jobs, preserve session scope for main-target reminders
- **Browser navigate** — resolve correct targetId after renderer swap
- **Gateway restart** — shorter manual reinstall/restart delays
- **Telegram reply dedup** — fix duplicate block replies by unblocking coalesced payloads
- **TUI shutdown** — guard SIGTERM against setRawMode EBADF

### Added (upstream)
- **Diffs plugin** — new plugin with image/view modes
- **Control UI** — session deletion support
- **Cron** — `--account` flag for multi-account delivery

### Not relevant (skipped)
- Android voice/onboarding fixes (12 commits)
- Feishu locale/features (4 commits)
- Azure OpenAI endpoint fixes (6 commits)
- Podman Quadlet fixes

## [2.0.3] - 2026-02-28
<!-- last-upstream-sha: f1bf558685 -->

### Changed
- **Synced fork to upstream openclaw/openclaw main** (89 commits since last sync)
- GPU commits (browser `gpuEnabled` config) rebased cleanly on top

### Fixed (upstream)
- **Telegram outbound chunking** — unified shared chunking logic, whitespace preserved in HTML retry
- **Model reasoning preserved in provider fallback** — thinking/reasoning no longer silently dropped when falling back between providers
- **Ollama context window handling** — unified across discovery, merge, and OpenAI-compat transport
- **Ollama autodiscovery hardened** — better warning behavior and apiKey config without predeclared provider
- **Heartbeat wake dedup** — skip wake on deduplicated notifications, scope wakeups to correct session
- **Post-compaction audit injection removed** — internal system messages no longer leak into context (security)
- **`tools.fs.workspaceOnly=false` honored** — host write/edit outside workspace now works correctly
- **Browser `url` alias** — accepted for open and navigate actions
- **Doctor detects empty groupAllowFrom** with groupPolicy=allowlist
- **Control UI CSP** — Google Fonts origins now allowed
- **Gateway restart** — actively kickstart launchd on supervised restart

### Added (upstream)
- **Android node capabilities** — calendar, contacts, photos, notifications, motion/pedometer handlers
- **TTS opus format** — voice bubbles for WhatsApp
- **Codex usage label** — weekly window correctly labeled "Week"

## [1.0.54] - 2026-02-23
<!-- last-upstream-sha: c92c3ad22 -->

### Changed
- **Rebased fork to clean upstream + 2 GPU commits** — fork is now just `openclaw/openclaw main` + GPU headless Chrome support (was 54 diverged commits, now 2)
- **Merged upstream openclaw** (v2026.2.22 → latest main) — 50+ commits

### Added
- **Persistent `~/.cache` directory** — qmd index, HuggingFace models, and Playwright browser cache now survive rebuilds via `/data/openclaw-home/.cache` symlink
- **Auto qmd update+embed on boot** — runs in background on startup, resumes where it left off (no re-indexing from scratch after restarts)

### Fixed (upstream)
- **Telegram topic target normalization** — unified delivery target resolution, legacy prefixed targets preserved
- **Cron telegram announce targets** — delivery targets now persisted correctly at runtime
- **HTTP 502/503/504 treated as failover-eligible** — better resilience during provider outages
- **Agent model fallback** — falls back to `agents.defaults.model` when agent has no model config
- **OpenRouter reasoning_effort conflict** removed from payload
- **Session key case canonicalization** — mixed-case keys now normalized
- **Config write immutability** — `unsetPaths` no longer mutates input

### Security (upstream)
- Obfuscated command detection for allowlist bypass prevention
- User input escaped in HTML gallery (stored XSS)
- Sensitive data redacted in OTEL log exports

### Added (upstream)
- **Web UI**: Full cron edit parity, all-jobs run history, compact filters
- **Mistral** media understanding provider
- **Data-driven tools catalog** with provenance tracking
- **Synology Chat** channel plugin
- **Telegram delivery target validation** — rejects invalid formats

## [1.0.53] - 2026-02-23

### Changed
- Synced fork to upstream (merge approach, later replaced by clean rebase in 1.0.54)

## [1.0.51] - 2026-02-22
<!-- last-upstream-sha: 861718e4d -->

### Changed
- **Synced fork to upstream openclaw/openclaw main** (`861718e4d`, v2026.2.21) — 339 commits ahead of previous sync
- GPU patches (browser `gpuEnabled` config) rebased cleanly on top
- CACHEBUST incremented to 22 for fresh Docker rebuild

### Added (upstream)
- **Gemini 3.1** model support
- **Apple Watch** companion app (inbox UI, notification relay, quick-reply actions)
- **Discord voice channels** (`/vc` join/leave/status), stream preview mode, forum tag management
- **Thread-aware model overrides** and per-channel model overrides (`channels.modelByChannel`)
- **Telegram streaming overhaul** — simplified to `channels.telegram.streaming` (boolean), split reasoning/answer preview lanes
- **Telegram/Discord lifecycle status reactions** — configurable emoji for queued/thinking/tool/done/error phases
- **Volcano Engine (Doubao) and BytePlus** providers
- **Discord ephemeral slash-command defaults** and thread-bound subagent sessions
- **Subagent spawn depth** default raised to `maxSpawnDepth=2`

### Fixed (upstream)
- **Compaction safeguard** extension not loading in production builds
- **Cron `maxConcurrentRuns`** now actually honored (was running serially)
- **Subagent announce chain** — deep spawn chains no longer drop final completions
- **Memory/QMD**: mixed-source search diversification, async close race, embed scheduling hardened, explicit unavailable status
- **Session memory persists on `/reset`** (not just `/new`)
- **Telegram**: topic targeting for cron/heartbeat, status reaction stall timers, `NO_REPLY` prefix suppression
- **Telegram duplicate bot-token** detection at startup
- **Docker image ~50% smaller** (~900MB reduction), base images pinned to SHA256 digests
- **Owner-only tools** now work for authorized senders (forward `senderIsOwner` to embedded runner)
- **Tool display**: compound commands no longer truncated to first stage

### Security (upstream)
- Unbounded compaction retry cost loop capped (`GHSA-76m6-pj3w-v7mf`)
- Exec heredoc/shell startup-file env injection blocked (`BASH_ENV`, `LD_*`, `DYLD_*`)
- Browser `file:`/`data:`/`javascript:` protocol navigation blocked
- Untrusted content marker spoofing prevention (per-wrapper random IDs)
- Browser upload symlink escape blocked
- Canvas endpoints require token/session capability (no shared-IP fallback)
- Credential header stripping on cross-origin redirects
- Gateway X-Forwarded-For proxy-chain spoofing hardened
- Browser sandbox: VNC password auth required, dedicated Docker network default
- 20+ additional security fixes across Discord, WhatsApp, Signal, BlueBubbles, systemd, skills

## [1.0.46] - 2026-02-18

### Fixed
- **Providers configuration now persists** - Fixed init script to properly bootstrap `claude_session_key` into providers section on first setup
- After initial setup, addon never overwrites providers section - multiple API keys configured via OpenClaw UI now persist across restarts
- Only gateway token is synced on subsequent restarts, all other config (including providers) is preserved

## [1.0.45] - 2026-02-18
<!-- last-upstream-sha: 81c5c02e -->

### Changed
- Upgraded to upstream openclaw/openclaw main (`81c5c02e`)
- 218 commits since last update including extensive test coverage and bug fixes

### Added (upstream)
- iOS: auto-select local signing team for automated builds
- Community plugins guide and vision documentation
- Maintainer application process documentation

### Fixed (upstream)
- Cron announce routing and timeout handling improvements
- BlueBubbles: outbound message ID recovery with sender metadata
- Telegram: sanitize native command names for API compliance
- Gateway: non-fatal stale token cleanup
- Mattermost: reactions support surfaced

## [1.0.44] - 2026-02-17
<!-- last-upstream-sha: 6d451c82 -->

### Changed
- **Rebased to upstream openclaw/openclaw main** (`6d451c82`) — no more fork patches
- Builds directly from upstream repo instead of mekenthompson fork
- 250+ commits since v2026.2.15 including:

### Fixed (upstream)
- DM forum/topic thread routing fully fixed ([#18021](https://github.com/openclaw/openclaw/pull/18021) + [#18586](https://github.com/openclaw/openclaw/pull/18586))
- Cron spin loop prevention, session key routing alignment ([#18637](https://github.com/openclaw/openclaw/pull/18637))
- Stale session lock release + watchdog for hung API calls ([#18060](https://github.com/openclaw/openclaw/pull/18060))
- Announce infinite retry loop broken ([#18264](https://github.com/openclaw/openclaw/pull/18264))
- Gateway crash loop prevention after failed self-update
- Atomic session store writes (prevents context loss)
- Security: credential theft via env var injection (OC-09), file permissions hardened
- Heartbeat transcript pruning for HEARTBEAT_OK turns

### Added (upstream)
- Linq channel (real iMessage via API)
- Gateway channel health monitor with auto-restart
- Post-compaction workspace context injection
- Memory: MMR re-ranking, temporal decay, FTS fallback, LLM query expansion
- Per-model thinkingDefault override
- Configurable tool loop detection
- /subagents spawn and /export-session commands

## [1.0.43] - 2026-02-17

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
