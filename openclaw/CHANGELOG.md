## [2.0.90] - 2026-04-26

### Changed
- **Upstream sync**: Cachebust bumped to pull latest `openclaw/openclaw` main (HEAD `5037298d82`).

## [2.0.89] - 2026-04-19

### Fixed
- **Gateway boot no-op config rewrite**: The addon wrapper now only runs the legacy TTS migration when old `openai`/`edge`/`elevenlabs`/`microsoft` TTS keys are actually present, instead of rewriting `openclaw.json` on every boot.

## [2.0.88] - 2026-04-19

### Fixed
- **Gateway crash loop: `Refusing to traverse symlink in exec approvals path`**: Upstream >= 2026.4.15 added `assertNoSymlinkPathComponents` on the exec-approvals file, which walked `~/.openclaw` and rejected the addon's `/home/node/.openclaw -> /data/openclaw-config` symlink. Fixed by setting `OPENCLAW_HOME=/data/openclaw-home` and making `~/.openclaw` resolve to the real directory `/data/openclaw-home/.openclaw`. Config is migrated from the legacy `/data/openclaw-config` location on first boot; a compat symlink (outside HOME, so not walked by the check) preserves the old path for any scripts still referencing it.

## [2.0.87] - 2026-04-19

### Changed
- **Build from upstream `openclaw/openclaw` directly**: Dropped the `mekenthompson/openclaw` fork as the OpenClaw source. Addon now clones from `https://github.com/openclaw/openclaw.git` at `main` (HEAD `da228660` at release time, ~6468 commits ahead of the last fork rebase at `45675c1698`). Simplifies maintenance — no more fork rebases.

### Removed
- **Headless Chrome GPU acceleration** (`browser.gpuEnabled` config option): dropped with the fork. Upstream PR [#20845](https://github.com/openclaw/openclaw/pull/20845) was closed unmerged on 2026-04-03. Browser plugin now runs headless Chrome without Vulkan GPU, even though `video: true` and `mesa-vulkan-drivers` remain in the addon for other potential uses. If upstream re-lands GPU support, a future release can re-enable it.

## [2.0.86] - 2026-04-04

### Fixed
- **Gateway crash loop: `bindings.0: Invalid input`**: Stale `topicId` field in binding match objects caused strict schema validation to reject the config on every startup. Added a gateway startup migration that merges `topicId` into the canonical `peer.id:topic:N` format and removes the invalid field.

## [2.0.85] - 2026-04-04

### Changed
- **Upstream sync to latest**: Rebased fork onto upstream `45675c1698` (913 new upstream commits since last rebase). 2 GPU cherry-picks (GPU config, GPU zod schema) applied cleanly. Includes Task Flow substrate, compaction improvements, session routing cleanup, exec YOLO defaults, provider transport hardening, and more.

## [2.0.84] - 2026-04-03

### Changed
- **Upstream sync to 2026.4.3 (latest)**: Rebased fork onto upstream `9b80344e58`. Dropped threading cherry-pick (superseded by upstream Telegram topic fixes). 2 cherry-picks remain (GPU config, GPU zod schema).
- **Telegram topic fixes from upstream**: `c001c09` (keep topic thread on message tool reply) + `a5d6e51` (preserve explicit topic targets on replies)

## [2.0.83] - 2026-04-03

### Changed
- **Upstream sync to 2026.4.3**: Rebased fork onto upstream `1efa923ab8` (278 new upstream commits). All 3 cherry-picks (GPU config, GPU zod schema, threading fix) applied cleanly — no conflicts.

## [2.0.82] - 2026-04-02

### Changed
- **Upstream sync to 2026.4.2**: Rebased fork onto upstream `1cc5526f7f` (575 new upstream commits). All 3 cherry-picks (threading fix, GPU config, GPU zod schema) applied cleanly.

## [2.0.78] - 2026-03-29

### Changed
- **Rebuild with latest fork**: picks up auto-topic-label `new-only`/`every-session` mode and `isNewTopic` fix from fork HEAD.

## [2.0.77] - 2026-03-29

### Added
- **Auto-topic-label mode config**: New `mode` option on `autoTopicLabel` — `"new-only"` (default) only labels brand-new topics, `"every-session"` re-labels on each session start (old behavior). Prevents overwriting manual topic renames on resumed conversations.

## [2.0.76] - 2026-03-29

### Fixed
- **Agent crash: `spawn docker EACCES`**: sandbox mode was not explicitly disabled, causing the agent to attempt Docker container spawning which is unavailable in HA addon containers. Bootstrap config now sets `sandbox.mode: "off"` for new installs, and gateway startup forces it off on every restart for existing installs.

## [2.0.75] - 2026-03-28

### Fixed
- **Gateway crash-loop on unset env vars**: bashio's `set -u` mode caused `unbound variable` errors when checking `$ANTHROPIC_API_KEY`, `$OPENAI_API_KEY`, `$GOOGLE_API_KEY`, and `$CLAUDE_CODE_OAUTH_TOKEN` before they were set. Changed all checks to `${VAR:-}` syntax.

## [2.0.74] - 2026-03-28

### Changed
- **Fork rebased to upstream** (337 new commits): clean reset to upstream HEAD (`49f693d06a`), re-applied 3 targeted cherry-picks:
  1. `currentThreadTs` in buildToolContext fallback — upstream accidentally reverted this in a test migration commit; needed for Telegram forum topic threading
  2. GPU/Vulkan browser config — not in upstream, needed for HA addon headless Chrome
  3. TTS legacy migration rules — not in upstream, prevents crash-loop on configs with legacy TTS keys
- **Dropped** telegram toolContext forwarding cherry-pick — superseded by upstream's plugin-based `resolveAutoThreadId` architecture
- Fork ref: `e33ba7c484`

## [2.0.73] - 2026-03-28

### Fixed
- **"No API key for provider: anthropic"**: the upstream rebase (2.0.66) broke file-based secrets resolution — the gateway couldn't read API keys from `secrets.json` via the internal secret-ref system. Added fallback in gateway startup to read Anthropic, OpenAI, and Google API keys directly from `secrets.json` and export them as environment variables.

## [2.0.72] - 2026-03-28

### Fixed
- **Root cause: 2.5GB corrupt openclaw.json** — racing `jq > /tmp && mv` writes from concurrent background doctor, init, and persist scripts produced ~65K concatenated JSON copies. Every jq command then tried to parse 2.5GB and spun at 100% CPU, blocking init indefinitely. Fixed on-device by extracting the first valid 38KB JSON object.
- **Prevent future corruption**: all `jq` read-modify-write operations on `openclaw.json` now use `flock -w 30 /tmp/openclaw-config.lock` to serialize concurrent writes
- **Restore exec**: remove diagnostic error capture from 2.0.71, restore `exec` for proper s6 process supervision

## [2.0.70] - 2026-03-28

### Fixed
- **Watchdog restart during startup**: nginx now returns 200 on `/health` while the gateway is still starting — the HA Supervisor watchdog (independent from Docker HEALTHCHECK) was getting 502s from nginx when the gateway wasn't ready yet and killing the container before it could finish starting

## [2.0.69] - 2026-03-28

### Fixed
- **Restart loop fix**: `openclaw doctor --fix` takes ~2 minutes (old binary), causing the HA watchdog health check to kill the container before init finishes. Moved doctor to background so init completes instantly and the gateway starts
- **jq generator bug**: `has("openai","edge","elevenlabs","microsoft")` is a jq generator that produces 4 separate booleans, not one. Replaced with `[has("openai"), has("edge"), has("elevenlabs"), has("microsoft")] | any` in both init and gateway scripts — fixes silent migration skip and potential config corruption from multiple JSON outputs
- **nginx 502 on startup**: add s6 dependency from `openclaw-nginx` to `openclaw-gateway` so nginx only starts after the gateway process launches — eliminates false 502 health-check failures during init
- **Slow gateway restart**: replace `chown -R node:node /data/openclaw-*` (recursive over entire workspace) with targeted `chown` on just the config file modified by root — removes 10-30s delay on every gateway restart

## [2.0.68] - 2026-03-28

### Fixed
- **TTS crash-loop hotfix v2**: add `jq` migration using `has()` to both init AND gateway startup scripts — runs on every gateway restart attempt, not just once at boot. Uses single `jq` expression with `has()` key detection instead of fragile `jq -e` value checks

## [2.0.67] - 2026-03-28

### Fixed
- **TTS crash-loop hotfix**: add `jq`-based config migration to init script that moves legacy TTS provider keys (`openai`, `edge`, `elevenlabs`, `microsoft`) into the `providers` sub-object before OpenClaw starts

## [2.0.66] - 2026-03-28

### Fixed
- **TTS config crash-loop fix**: add legacy detection rules for TTS provider keys (`openai`, `edge`, `elevenlabs`, `microsoft`) so the existing migration actually triggers — configs with legacy `messages.tts.openai`/`messages.tts.edge` or `channels.discord.voice.tts.edge` no longer cause strict schema validation to reject the config before migration runs

### Changed
- **Fork rebased to upstream** (399 new commits): dropped large telegram isForum refactor (conflicted heavily, upstream hasn't adopted); kept 3 targeted fixes (threading, browser GPU, toolContext forwarding)
- Fork ref: `3367f675d0`

## [2.0.65] - 2026-03-28

### Fixed
- **Telegram isForum simplification**: replace async `resolveTelegramForumFlag` API call with direct `msg.chat.is_forum` check in main message handler — removes unnecessary `getChat` round-trip
- **Telegram session refactor**: remove group thread persistence from `updateLastRoute` (DM-only now), fixing stale thread routing in groups
- **Telegram callback auth**: DM callbacks now enforce sender authorization gate matching normal DM commands
- **Telegram reply format**: use `reply_parameters` instead of deprecated `reply_to_message_id`
- Test suite reorganization and cleanup (108 files)
- Fork ref: `8d6aefc2d3` (superseded by 2.0.66 rebase)

## [2.0.64] - 2026-03-27

### Changed
- **build**: switch OPENCLAW_REF to 'main' branch for simpler updates
- Updates now only require cachebust bump to pull latest fork

## [2.0.63] - 2026-03-27

### Fixed
- **Telegram threading fix complete**: forward toolContext through plugin dispatch for auto thread resolution — files/messages via tools now correctly route to topic threads instead of top-level DMs
- Sync build.yaml ref to match fork HEAD (was stale)
- Fork ref: `b8c1531f3a` (1 commit ahead of `08ba1db3f4`, completes threading fix from `1f605f8eed`)

## [2.0.60] - 2026-03-26

### Fixed
- **Discord stale-socket crash resolved**: health-monitor restart caused uncaught exception (`Max reconnect attempts (0) reached`) — fixed upstream (#54697)
- **Telegram DM topic routing resolved**: files/messages sent via tools now route to correct topic thread — fixed upstream (#52217)
- **Telegram plugin ReferenceError resolved**: `createTopLevelChannelReplyToModeResolver is not defined` — fixed upstream

### Changed
- Upstream sync to `a3b85e1583` (1349 new commits since `5b31b34`)
- Dropped all cherry-picks except GPU/Vulkan config — all others superseded by upstream
- Fork HEAD: `08ba1db3f4`

## [2.0.55] - 2026-03-25

### Fixed
- `claude_session_key` OAuth tokens (`sk-ant-oat01-*`) now correctly routed to `CLAUDE_CODE_OAUTH_TOKEN` instead of `ANTHROPIC_API_KEY`, fixing Claude Code CLI authentication failures
- `claude-code-token.txt` credentials file no longer overrides OAuth token set via `claude_session_key`

## [2.0.53] - 2026-03-23

### Fixed
- **fix(telegram): make buttons schema contribution Optional** — fixes ALL silent message send failures when inlineButtons is enabled (critical)
- **fix(mattermost): make buttons schema contribution Optional** (same root cause)
- **fix(telegram): use topLevelReplyToMode correctly**
- **fix(telegram): coalesce DM streaming into single message in partial mode**
- Fork HEAD: `7f96ed8a45`
- Addon cachebust: 83

## [2.0.52] - 2026-03-22

### Fixed
- **Telegram plugin crash resolved**: `ReferenceError: createTopLevelChannelReplyToModeResolver is not defined` — the telegram extension called this function without importing it after the `bfcfc17` plugin SDK refactor. Fixed upstream by switching to `topLevelReplyToMode: "telegram"` shorthand, which `createChatChannelPlugin` handles internally.
- Fork HEAD: `bbd158293`
- Addon cachebust: 82

## [2.0.51] - 2026-03-22

### Changes
- Upstream sync to `5b31b3400` (86 new commits since `39a4fe5`)
- Rebased 3 cherry-picks cleanly onto upstream HEAD
- Cherry-pick #2 (telegram buildToolContext) amended with 16 new tests — all pass
- PR #50068 updated with test coverage

## [2.0.50] - 2026-03-22

### Changes
- Upstream sync to `5b31b3400` (~86 new commits)
- Rebased 3 cherry-picks cleanly onto upstream HEAD
- fix(telegram): buildToolContext tests added + channel.ts conflict resolved against bfcfc17 refactor
- feat(browser): GPU config support for headless Chrome (cherry-pick)
- build: INEFFECTIVE_DYNAMIC_IMPORT downgraded to warning (cherry-pick)
- Fork HEAD: `147f48df4`
- Addon cachebust: 81

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.49] - 2026-03-21 (cachebust 80)

### Fixed
- **Telegram streaming regression resolved**: streaming now correctly uses edit-in-place (single updating message) instead of sending multiple separate message bubbles during generation. Root cause: upstream rewrote `draft-stream.ts` replacing the buggy `revive()` method with `forceNewMessage()`, which correctly clears `lastSentText` — eliminating the dedup-swallowed-edits bug that caused us to drop the streaming cherry-pick on 2026-03-17
- Upstream streaming PR #50917 included: `message:sent` hooks now fire correctly on preview finalization for Telegram streaming replies

### Changed
- Upstream sync to `39a4fe5` (2026-03-21) — includes Telegram transport fallback chain unification (#49148), streaming hook fixes (#50917), seq-gap broadcast fix, and 100+ upstream commits since last sync
- Rebased custom cherry-picks onto new upstream HEAD:
  - `feat(browser)`: GPU configuration support for headless Chrome
  - `fix(telegram)`: add `buildToolContext` to resolve `message_thread_id` for DM topics
  - `build`: downgrade `INEFFECTIVE_DYNAMIC_IMPORT` from error to warning

## [2.0.48] - 2026-03-20 (cachebust 79)

### Fixed
- Stale plugin detection now catches `"plugins": []` (array type) in addition to relative-path entries — fixes "expected object, received array" restart loop when a previous manual fix incorrectly set `plugins` to an empty array instead of deleting the key

## [2.0.47] - 2026-03-20 (cachebust 79)

### Fixed
- Plugin cleanup uses `del(.plugins)` not `.plugins = []` — `plugins` is an object in openclaw.json schema, setting it to an array caused "expected object, received array" validation error
- Stale entry detection updated for object-type plugins field (was using array iterator `[]?`)

## [2.0.46] - 2026-03-20 (cachebust 79)

### Fixed
- **Upstream best practice applied**: set `OPENCLAW_BUNDLED_PLUGINS_DIR=/app/dist/extensions` (Dockerfile ENV + gateway run env) — bypasses `isSourceCheckoutRoot()` detection and `dist-runtime` symlink path entirely; uses compiled `dist/extensions/` directly, eliminating the "extension entry escapes package directory" restart loop
- **Auto-clear stale plugin registry on startup**: `openclaw-init` now detects relative `./index.js` plugin entries in `openclaw.json` (stale from prior image) and clears them before `doctor --fix` runs — self-healing upgrade path
- **Build target**: `pnpm build` → `pnpm build:docker` (Docker-optimized, skips plugin SDK DTS generation and Canvas A2UI bundle — faster, same runtime output)
- Removed redundant `doctor --fix` in gateway run script (it runs once in openclaw-init already)

### Added
- `openai_api_key` optional bootstrap config option — passed as `OPENAI_API_KEY` env var to gateway on every restart (useful for GPT models and Whisper transcription alongside Claude)
- Updated DOCS.md: config options section, gateway restart loop troubleshooting, matrix-js-sdk entrypoint explanation

## [2.0.45] - 2026-03-20 (cachebust 78)

### Fixed
- Add `openclaw doctor --fix` before gateway start to auto-repair stale plugin entry paths in `openclaw.json` — prevents infinite restart loop caused by "extension entry escapes package directory" config validation failure on startup after upgrade

## [2.0.44] - 2026-03-20 (cachebust 78)

### Fixed
- Root cause fix for `Multiple matrix-js-sdk entrypoints detected!` — remove `.git` dir after clone so `isSourceCheckoutRoot()` returns `false` and bundled plugins load from compiled `dist/extensions/` (native ESM) instead of source `.ts` via Jiti (CJS path). This eliminates the CJS/ESM split that triggered the duplicate entrypoint error for every plugin on startup.
- Not yet fixed upstream: `bundled-dir.ts` `isSourceCheckoutRoot` still checks for `.git`; `runtime-channel.ts` still has static import of `runtime-matrix.js`

## [2.0.43] - 2026-03-20 (cachebust 77)

### Fixed
- Force-rebuild to pick up upstream matrix-js-sdk entrypoint fix (ae02f4014) — resolves `Multiple matrix-js-sdk entrypoints detected!` error that prevented all plugins from loading on startup
- Fork HEAD `94f0f010` (3 commits ahead of 2.0.42, includes GPU config + Telegram threading + build warning downgrade merged into main)

## [2.0.42] - 2026-03-20 (cachebust 76)

### Fixed
- Synced fork to upstream HEAD `628b55a825` (+many commits since 2026-03-19)
- Cherry-picks re-applied: GPU config (`990d5585ae`), Telegram DM topic threading (`f496e5bffb`), build warning downgrade (`94f0f01052`)
- Submitted PR #50657 upstream: fix buttons schema contribution not being Optional in Telegram + Mattermost channel plugins (caused cron/isolated session message sends to fail silently)

## [2.0.40] - 2026-03-19 (cachebust 75)

### Fixed
- Telegram threading fix now also guards against overriding explicit topic targets (e.g. `chatId:topic:42`) — auto-injection skipped when `to` already encodes a `messageThreadId`
- Upstream synced to HEAD `b9c4db1a77` (+9 more commits since cachebust 74)
- Clean PR #50068 opened against upstream (single file, single commit, addresses all review feedback)
- Old PR #49389 closed (was incorrectly PRing from `main`, included unrelated GPU/build commits)

## [2.0.40] - 2026-03-19

### Changed
- Synced fork to upstream HEAD `b526098eb2` (+79 commits since 2026-03-18)
- Cherry-picks applied: GPU config, Telegram DM topic threading fix, INEFFECTIVE_DYNAMIC_IMPORT build warning downgrade
- Telegram threading conflict resolved: kept our `buildToolContext` implementation alongside upstream's `resolveReplyToMode` refactor (functionally equivalent, non-overlapping)
- Upstream added retry fallback for "thread not found" in delivery.ts — complementary to our proactive fix

## [2.0.39] - 2026-03-18

### Changed
- Bumped cachebust to match last sync

## [2.0.38] - 2026-03-18

### Fixed
- **Telegram DM topic threading** — message tool, cron delivery, and sessions_send now correctly include `message_thread_id` for DM topics. Previously messages silently landed in parent chat instead of the topic thread. Root cause: Telegram was the only channel without `buildToolContext` implementation. Fixes #14762, #27560, #28523.

### Changed
- Rebased fork to upstream HEAD (ed72695). Cherry-picks: GPU config + threading fix.
- Dropped stale `guard pinned registry` and streaming coalesce commits.

## [2.0.37] - 2026-03-18

### Fixed
- **Dropped DM streaming coalesce cherry-pick** — was causing "typing but no delivery" bug. `revive()` in `draft-stream.ts` doesn't clear `lastSentText`, so dedup check silently skips edits. `allowRefinalize` bypasses guards without validating preview message ID. Reverted to upstream split-message behavior.

### Changed
- Cherry-picks now 3: GPU browser config, pinned channel registry, guard fix

## [2.0.36] - 2026-03-18

### Changed
- **Synced with upstream**: 251 new commits from `openclaw/openclaw` (5a2a4abc1)
- Notable upstream: Telegram transport fallback chain unification, sticky IPv4 fallback across polling restarts, compaction safeguard loop fix, image generation tool, host exec sandbox security hardening, Chutes extension
- All 4 cherry-picks rebased cleanly: GPU config, DM streaming coalesce, pinned channel registry, guard fix

## [2.0.35] - 2026-03-17

### Fixed
- **Pinned channel registry** — proper fix for "Unknown channel: telegram" message tool bug. Mirrors upstream's httpRoute pinning approach (#47902) to also protect channel plugin registrations from being lost when `loadOpenClawPlugins()` creates a new registry at runtime. Gateway startup pins the channel registry; runtime reloads can't wipe it.
- **Cache invalidation hardening** — `resolveCachedChannelPlugins()` now checks both registry object identity AND version, preventing stale lookups after pin release.

### Changed
- **Synced with upstream**: 420+ new commits from `openclaw/openclaw` (c1ef5748e)
- Cherry-picks now 3: GPU browser config, DM streaming coalesce, pinned channel registry (our fix)
- **Dropped** previous band-aid fixes: PR #32414 (channel bootstrap), PR #45568 carry-forward

## [2.0.34] - 2026-03-16

### Fixed
- **Plugin registry desync fix**: Cherry-picked PR #45568 (carry forward httpRoutes) and extended to also carry forward `channels` across registry replacements. Fixes "Unknown channel: telegram" errors from the message tool caused by `loadOpenClawPlugins()` creating new empty registries at runtime.
- **Dropped PR #32414** (channel bootstrap) — its `maybeBootstrapChannelPlugin()` call to `loadOpenClawPlugins()` was actually triggering more registry swaps, making the desync worse.

### Changed
- **Synced with upstream**: 129 new commits from `openclaw/openclaw` (d8e138c74)
- Custom cherry-picks now 4: GPU browser config, DM streaming coalesce, httpRoutes carry-forward (#45568), channels carry-forward (our extension)

## [2.0.33] - 2026-03-16

### Fixed
- **Cherry-picked PR #32414**: Bootstrap plugin registry in `resolveMessageChannelSelection` — fixes `Unknown channel` / `Unknown target` errors from message tool when channel plugins haven't loaded yet
- Custom cherry-picks now 3: GPU browser config, DM streaming coalesce, channel bootstrap fix

## [2.0.32] - 2026-03-16

### Changed
- **Synced upstream fork**: 20 new commits from `openclaw/openclaw` (963237a1), rebased cherry-picks
- Key upstream changes:
  - **Plugins**: fix bundled plugin roots and skill assets (#47601), harden context engine ownership — fixes `Context engine "legacy" is not registered` error
  - **Plugins**: restore provider compatibility fallbacks, move provider runtimes into bundled plugins
  - **Plugins**: relocate/clean bundled skill assets, skip nested node_modules
  - **CLI**: support package-manager installs from GitHub main (#47630), lazy-load non-interactive plugin provider runtime (#47593)
  - **Gateway**: sync runtime post-build artifacts
- Custom cherry-picks (2, rebased): GPU browser config, DM streaming coalesce

## [2.0.31] - 2026-03-16

### Changed
- **Synced with upstream**: 91 new commits from `openclaw/openclaw` (b795ba1)
- Key upstream changes:
  - **Plugins**: reserve context engine ownership, load bundled extensions from dist (#47560)
  - **Models**: preserve stream usage compat opt-ins (#45733)
  - **CLI**: fix generator OOM and harden plugin registries (#45537), lazy-load auth/model picker providers
  - **Config**: avoid failing startup on implicit memory slot (#47494)
  - **Security**: tighten forwarded client and pairing guards (#46800), scrub credentials from endpoint snapshots (#46799), tighten pre-auth body handling (#46802), revalidate workspace-only patch targets (#46803)
  - **Gateway**: scope Control UI sessions per gateway (#47453)
  - **Release**: block oversized npm packs that regress low-memory startup (#46850)
- Custom cherry-picks (2): GPU browser config, DM streaming coalesce

## [2.0.30] - 2026-03-15

### Changed
- **Synced with upstream**: ~500 new commits from `openclaw/openclaw` (cbec476b6)
- **Dropped SSRF IPv4 cherry-pick** — upstream PR #44639 threads the full TelegramTransport policy through the media download pipeline, properly fixing the IPv4 fallback regression
- Custom cherry-picks reduced to 2: GPU browser config, DM streaming coalesce

## [2.0.29] - 2026-03-14

### Changed
- **Synced with upstream**: 287 new commits from `openclaw/openclaw` (3957f29)
- Key upstream changes:
  - **Browser**: Chrome MCP existing-session support
  - **Compaction**: preserve persona and language continuity in summaries (#10456)
  - **Ollama**: hide native reasoning-only output (#45330)
  - **Cron**: restore manual run type narrowing
  - **Docker**: exclude .env from build context (#44956)
  - **Security**: harden external content marker sanitization, harden exec obfuscation, enforce browser origin check, harden nodes owner-only tool gating
  - **Plugins**: fix update dependency failures and dedupe warnings, modularize provider architecture
  - **Subagents**: resolve target agent workspace for cross-agent spawns (#40176)
  - **Telegram**: quiet command overflow retry logs, avoid polling restart hang after stall detection
- Custom cherry-picks (3 commits): GPU browser config, DM streaming coalesce, SSRF IPv4 fallback fix (adapted to upstream's new PinnedDispatcherPolicy API)

## [2.0.28] - 2026-03-13

### Changed
- **Synced with upstream**: 223 new commits from `openclaw/openclaw` (771066d12)
- Key upstream changes:
  - **Compaction**: use full-session token count for post-compaction sanity check (#28347), show status reaction during compaction (#35474), guard compact() throw + fire hooks (#41361)
  - **Telegram**: quiet command overflow retry logs, clear polling cleanup timers, avoid polling restart hang after stall detection
  - **Cron**: avoid false legacy payload kind migrations, stop false doctor warnings (#44012), enable fast mode for isolated runs
  - **Security**: strip Mongolian selectors in exec obfuscation detector, escape invisible exec approval format chars, block GIT_EXEC_PATH in host env, harden nodes owner-only tool gating, enforce browser origin check
  - **Models**: Anthropic fast mode support, OpenAI fast mode toggle, modularize provider plugin architecture, normalize bundled provider ids
  - **ACP**: preserve final assistant message snapshot before end_turn (#44597), rehydrate restarted main ACP sessions (#43285)
  - **Gateway**: strip unbound scopes for shared-auth connects, expose runtime version in status
  - **Browser**: restore proxy attachment media size cap
- Custom cherry-picks (3 commits): GPU browser config, DM streaming coalesce, SSRF IPv4 fallback fix

## [2.0.27] - 2026-03-12

### Fixed
- **Telegram media download IPv4 regression**: Thread `connectOptions` through SSRF fetch pipeline so Telegram media downloads pass `autoSelectFamily: false` to pinned dispatcher — fixes ETIMEDOUT in dual-stack containers with broken IPv6 routes (regression from `45b74fb56c`)

### Changed
- **Synced with upstream**: latest from `openclaw/openclaw` (e11be576f)
- Key new upstream changes:
  - **Terminal**: sanitize skills JSON and fallback on legacy Windows
  - **Gateway/Dashboard**: surface config validation issues
  - **Build**: repair bundled plugin dirs after npm install

## [2.0.26] - 2026-03-12

### Fixed
- *Superseded by v2.0.27* — initial blanket-default approach replaced with surgical pipeline fix

### Changed
- **Synced with upstream**: 29 new commits from `openclaw/openclaw` (8cc0c9baf)
- Key upstream changes:
  - **Gateway**: run `before_tool_call` for HTTP tools
  - **WebSocket**: preserve payload overrides
  - **Ollama**: share model context discovery, fix default custom URL
  - **Memory**: normalize Gemini embeddings, add gemini-embedding-2-preview support
  - **Agents**: prevent false billing error replacing valid response text, check billing errors before context overflow heuristics
  - **Discord**: add missing `autoThread` to config type
  - **Telegram**: clear stale retain before transient final fallback, add missing `editMessage`/`createForumTopic` to actions schema
  - **Config**: add missing Signal `accountUuid`, voice-call TTS `speed`/`instructions` to schemas
  - **Web tools**: restore to coding profile
  - **Venice**: recognize 402 billing errors for model fallback

## [2.0.25] - 2026-03-12

### Changed
- **Synced with upstream**: 65 new commits from `openclaw/openclaw` (f063e57d4)
- Key upstream changes:
  - **Security**: harden subagent control boundaries, bind system.run approvals to exact argv, enforce target account configWrites, pin fs-bridge staged writes, fail closed for unresolved local gateway auth refs, harden archive extraction destinations, harden secret-file readers, sanitize Docker env before marking OPENCLAW_CLI
  - **Context pruning**: prune image-containing tool results instead of skipping them (#41789)
  - **Telegram**: prevent duplicate messages with slow LLM providers (#41932), fall back on ambiguous first preview sends
  - **ACP**: scope cancellation and event routing by runId (#41331), strip provider auth env for child ACP processes (#42250), implicit streamToParent for mode=run without thread (#42404)
  - **Browser**: surface 429 rate limit errors with actionable hints (#40491)
  - **Gateway**: harden token fallback/reconnect behavior (#42507), split conversation reset from admin reset, fail closed unresolved local auth SecretRefs (#42672)
  - **Discord**: add autoArchiveDuration config option (#35065)
  - **macOS**: add chat model selector, persist thinking, fix browser proxy POST serialization (#43069)
  - **iOS**: add local beta release flow
  - **Providers**: add Opencode Go support (#42313), include azure-openai in Responses API store override
  - **Cron**: fix embedded lane deadlock, cover nested lane selection
  - **Refactoring**: large dedup pass across channels, security, onboarding, and approval code
- **Cherry-picks reapplied**: GPU config (f63492aad), DM streaming coalesce (73923e01d)

## [2.0.24] - 2026-03-11

### Changed
- **Synced with upstream**: 42 new commits from `openclaw/openclaw` (283570de4)
- Key upstream changes:
  - **Telegram**: chunk long HTML outbound messages (#42240), prevent duplicate messages when preview edit times out (#41662), thread runtime config through Discord/Telegram sends (#42352)
  - **Security**: reject exec SecretRef traversal ids across schema/runtime/gateway (#42370)
  - **Failover**: classify Gemini MALFORMED_RESPONSE as retryable timeout (#42292), recognize Poe 402 billing for fallback (#42278)
  - **Logging**: include model and provider in overload/error log (#41236), log auth profile resolution failures (#41271)
  - **Cron**: record lastErrorReason in job state (#14382)
  - **Web search**: recover OpenRouter Perplexity citations from message annotations (#40881)
  - **iOS**: welcome home canvas, refresh home toolbar, generic pairing instructions
  - **Onboarding**: integrate Alibaba Bailian/ModelStudio (#40634)
  - **CI**: npm release workflow and CalVer checks (#42414)
- Custom cherry-picks (2 commits): GPU browser config, DM streaming coalesce

## [2.0.23] - 2026-03-10

### Changed
- **Synced with upstream**: 60 new commits from `openclaw/openclaw` (cf9db91b6)
- Key upstream fixes:
  - **Auth**: reset cooldown error counters on expiry — prevents infinite escalation (#41028)
  - **Cron**: fix NO_REPLY misclassified as interim ack — stops forced reruns on heartbeat (#41401)
  - **Cron**: record lastErrorReason in job state (#14382)
  - **Cron**: enforce cron-owned delivery contract (#40998)
  - **Discord**: apply effective maxLinesPerMessage in live replies (#40133)
  - **Telegram**: prevent duplicate messages when preview edit times out (#41662)
  - **Telegram**: exec approvals for OpenCode/Codex (#37233)
  - **Telegram**: bridge direct delivery to internal message:sent hooks (#40185)
  - **Secrets**: resolve web tool SecretRefs atomically at runtime
  - **Agents**: probe single-provider billing cooldowns (#41422)
  - **Agents**: fix Brave llm-context empty snippets (#41387)
  - **Agents**: bound compaction retry wait and drain embedded runs on restart (#40324)
  - **Plugins**: expose model auth API to context-engine plugins (#41090)
  - **ACP**: harden follow-up reliability, attachments, streaming, error handling (5 commits)
  - **Gateway**: add pending node work primitives (#41409)
  - **UI**: preserve control-ui auth across refresh (#40892)
  - **Web Search**: recover OpenRouter Perplexity citations from annotations (#40881)
  - **Memory**: protect bootstrap files during memory flush (#38574)
  - **Fallback**: add HTTP 499 to transient error codes (#41468)
  - **Exec**: mark child command env with OPENCLAW_CLI (#41411)
  - **Doctor**: fix non-interactive cron repair gating (#41386)
- Cherry-picks preserved: GPU browser config, Telegram DM streaming coalesce (adapted to new lifecycle model)

## [2.0.21] - 2026-03-09

### Changed
- **Synced with upstream**: 422 new commits from `openclaw/openclaw` (abb8f6310)
- Key upstream changes:
  - **Backup**: new local backup CLI (#40163), harden backup verify path validation
  - **Cron**: consolidate announce delivery, fire-and-forget trigger, and minimal prompt mode (#40204)
  - **Browser**: scope CDP sessions and harden stale target recovery, configurable relay bind address (#39364), wait for extension relay tab reconnects (#32461), normalize wildcard remote CDP websocket URLs (#17760), share context engine registry across bundled chunks (#40115)
  - **iOS/macOS**: auto-load scoped gateway canvas with safe fallback (#40282), replay queued foreground actions safely after resume (#40281), improve tailscale gateway discovery (#40167), add remote gateway token field for remote mode
  - **Plugin SDK**: lazily load legacy root alias
  - **Security**: harden backup verify path validation, refresh detect-secrets baseline, scope secrets scan to branch changes
  - **Docs**: WSL2 + Windows remote Chrome CDP troubleshooting (#39407)
- Custom cherry-picks (3 commits): GPU browser config, DM streaming coalesce

## [2.0.20] - 2026-03-08

### Changed
- **Synced with upstream**: 242 new commits from `openclaw/openclaw` (733f7af92)
- Key upstream changes:
  - **Heartbeat**: fix requests-in-flight retries from drifting schedule (#39182)
  - **Telegram**: reset webhook cleanup latch after polling 409 conflicts (#39205), guard null persisted update id, resolve status SecretRefs with provider-safe env checks, harden persisted offset confirmation and stall recovery, route native topic commands to active session (#38871)
  - **Security**: harden install base drift cleanup, strip custom auth headers on cross-origin redirects, require admin for chat config writes, harden fs-safe copy writes, stage installs before publish
  - **Cron**: eliminate double-announce, replace delivery polling with push-based flow (#39089)
  - **Gateway**: harden service-mode stale process cleanup (#38463), flush chat delta before tool-start events (#39128), order bootstrap cache clear after embedded run wait, harden plugin HTTP route auth
  - **Browser**: keep dispatcher context with no-retry hints
  - **Models**: refresh gpt/gemini alias defaults (#38638), prevent plaintext apiKey writes to models state (#38889), respect explicit provider baseUrl in merge mode (#39103)
  - **Agents**: avoid double websocket retry accounting on reconnect failures (#39133), apply contextTokens cap for compaction threshold (#39099), increment compaction counter on overflow-triggered compaction (#39123)
  - **Docker**: slim image option (#38479)
  - **Config**: degrade gracefully on missing env vars (#39050), sanitize validation log output (#39116)
  - **Discord**: avoid native plugin command collisions, make message listener non-blocking (#39154)
  - **Refactor**: large deduplication pass across channels (telegram, discord, slack, feishu), unify DM pairing challenge flows, centralize gateway auth env credential readers
- Custom patches maintained: 3 GPU commits + 1 streaming coalesce commit (PR #33844 still pending upstream)

## [2.0.19] - 2026-03-07

### Changed
- **Synced with upstream**: 145 new commits from `openclaw/openclaw` (82eebc905)
- Key upstream changes:
  - **Security**: reject spoofed input_image MIME payloads (#38289), enforce 600 perms for cron store (#36078)
  - **Telegram**: clear DM draft after materialize (#36746), narrow failed-after retry match, honor outbound mediaMaxMb uploads (#38065)
  - **Gateway**: keep probe routes reachable with root-mounted control UI (#38199), normalize HEIC input images (#38122), discriminate input sources, path-scoped config schema lookup (#37266)
  - **Features**: custom context management plugin system (#22201), web search in onboarding (#34009), opt-in extension deps via OPENCLAW_EXTENSIONS build arg (#32223)
  - **Failover**: classify HTTP 402 as rate_limit (#36802), zhipuai limit fix (#33813)
  - **Session routing**: prefer webchat routes for direct UI turns (#37135), respect source channel for agent event surfacing (#36030)
  - **Codex OAuth**: fix bogus probe + scope mutation
  - **Cron**: stabilize one-shot migration tests, migrate legacy delivery hints
- **Custom commits re-applied**: 3 GPU + 1 DM streaming coalesce cherry-picked cleanly (no conflicts)

## [2.0.17] - 2026-03-05

### Changed
- **Synced with upstream**: 29 new commits from `openclaw/openclaw` (9c6847074)
- Key upstream changes: gateway restart health fixes, AGENTS.md compaction alignment, Ollama header passthrough, outbound media fallback fixes, poll-vote actions, ACP session streaming relay, draft preview materialization
- **Custom commits re-applied**: 3 GPU + 1 DM streaming coalesce cherry-picked cleanly

## [2.0.13] - 2026-03-04

### Changed
- **Rebased on upstream**: Synced with upstream `openclaw/openclaw` HEAD (19 commits). Includes serial callback queue, async materialization, smarter archive cleanup.
- **Simplified streaming fix**: Replaced complex `keepStreamAlive`/`needsFlushForKeepAlive` with simple `revive()` after finalization. Down from 5 changed files to 2.
- **GPU commits re-applied**: All 3 GPU browser config commits cherry-picked on top of upstream HEAD.

### Fixed
- **Telegram DM streaming coalesce**: Gate rotation behind `shouldSplitPreviewMessages` so partial mode keeps editing same message across tool-call boundaries. Add `revive()` to reopen stream after finalization.
- **DM message transport**: Force `"message"` transport for ALL DM lanes (not just reasoning), ensuring `editMessageText` has a real `messageId`.
- **`@tloncorp/api` build fix**: Upstream `5ce5309` fixes git URL format; also added `npm install -g npm@latest` as belt-and-suspenders.

## [2.0.9] - 2026-03-03

### Fixed
- **Telegram DM streaming**: Disabled `sendMessageDraft` for DM streaming — causes `TEXTDRAFT_PEER_INVALID` for regular bots (#7803), loses reply_to support, breaks progressive message editing. Reverted DM default to `sendMessage`+`editMessageText` transport.

## [2.0.11] - 2026-03-04

### Fixed
- **Telegram DM streaming coalesce**: In `partial` mode, responses now coalesce into a single progressively-edited message across tool-call boundaries instead of creating separate messages per turn. Aligns Telegram with Discord's existing `shouldSplitPreviewMessages` pattern. Forces message transport for all DM lanes, resets stream state in `forceNewMessage()`, adds `keepStreamAlive` to lane-delivery. Controlled by existing `streaming` config (`partial` = one message, `block` = split).

## [2.0.10] - 2026-03-04
<!-- last-upstream-sha: 2cd3be896 -->

### Changed
- **Synced fork to upstream openclaw/openclaw main** (473 commits since v2.0.8)
- **Dropped sendMessageDraft cherry-pick** — upstream merged the same fix in #33169
- GPU commits (3) cherry-picked cleanly, one test conflict resolved (upstream refactored test to suite imports)

### Fixed (upstream)
- **Telegram:** draft stream boundaries stabilized, NO_REPLY lead-fragment leaks suppressed (#33169), duplicate messages in DM draft mode (#32118), preserve original filenames
- **Discord:** per-channel message queues for parallel dispatch, allowBots mention gating, dropped opus dependency
- **Config:** sensitive-schema warnings moved to debug, backup permissions hardened
- **Plugins:** bundled plugin id preference, fallback when npm resolves non-OpenClaw package
- **Sessions:** orphan same-pid lock recovery
- **Cron:** legacy schedule/command migration, schedule evaluator caching

### Performance (upstream)
- Core routing, pairing, security scan caching
- Agent-id lookup memoization, redundant schema work skipped

## [2.0.8] - 2026-03-03
<!-- last-upstream-sha: d98a61a97 -->

### Changed
- **Synced fork to upstream openclaw/openclaw main** (358 commits since last sync)
- GPU commits cherry-picked cleanly on top

### Fixed (upstream)
- **Telegram:** preserve original filename from document/audio/video uploads, compact model callback fallback for long names
- **Browser:** GPU warn without headless mode (our commit now in upstream context)
- **Cron:** migrate legacy string schedule and command jobs, cache schedule evaluators
- **Sessions:** reclaim orphan same-pid lock files, harden session path credit rollup
- **Config:** move sensitive-schema hint warnings to debug, harden backup permissions and cleanup
- **Plugins:** prefer bundled plugin ids over bare npm specs, fall back to bundled when npm resolves to non-OpenClaw package
- **Heartbeat:** suppress HEARTBEAT_OK fallback leak
- **Discord:** per-channel message queues to restore parallel agent dispatch
- **Slack:** apply mrkdwn conversion in streaming/preview, memoize allow-from and mention paths
- **MS Teams:** harden webhook timeouts, scope auth across media redirects, guarded dispatcher redirects
- **Tools:** strip xAI-unsupported JSON Schema keywords from tool definitions
- **Reasoning:** prevent reasoning text leak through handleMessageEnd fallback

### Performance (upstream)
- Core routing, pairing, slack, and security scan speedups
- Cache normalized agent-id lookups, skip redundant schema/session-store work
- Cache scanner directory walks, cron schedule evaluators

### Refactored (upstream)
- Unify queueing and normalize telegram/slack flows
- Dedupe CLI config, cron, and install flows
- Dedupe protocol schema typing and session/media helpers

## [2.0.7] - 2026-03-02
<!-- last-upstream-sha: 0c2d85529 -->

### Changed
- **Synced fork to upstream openclaw/openclaw main** (176 additional commits, version bump to 2026.3.2)
- GPU commits cherry-picked cleanly on top

### Fixed (upstream)
- **Telegram:** DM topic thread keys scoped by chat id, retry sends without message_thread_id, IPv4 media fetch fallback, first-chunk voice fallback reply refs, replyToMode 'first' scoped to first chunk
- **Browser:** prefer openclaw profile in headless/noSandbox, honor attachOnly for loopback CDP, Chrome stderr in startup errors, relay navigation retry after frame detach, stale relay target eviction, configurable CDP auto-port range
- **Cron:** re-arm one-shot at-jobs when rescheduled, year-rollback guard
- **Sessions:** harden recycled PID lock recovery, preserve external routing for internal turns
- **Thinking:** default Claude 4.6 to adaptive, support `thinkingDefault: "adaptive"`
- **Pairing:** handle missing accountId in allowFrom reads
- **Gateway:** origin wildcard honour, healthz/readyz probes, ws:// to private network
- **Usage:** clamp negative input token counts to zero

### Security (upstream)
- Harden spoofed system marker handling
- Harden diffs viewer security
- 0o644 for inbound media files (sandbox read access)

### Added (upstream)
- PDF analysis tool with native provider support
- `openclaw config validate` CLI command
- Docker opt-in sandbox support
- Gateway healthz/readyz probe endpoints
- OPENCLAW_SHELL env injection for exec/ACP
- Diffs: image quality configs + PDF format option
- Improved Telegram DM topics support

## [2.0.6] - 2026-03-02
<!-- last-upstream-sha: aaa7de45f -->

### Changed
- **Synced fork to upstream openclaw/openclaw main** (236 commits since last sync)
- GPU commits (browser `gpuEnabled` config) cherry-picked cleanly on top

### Fixed (upstream)
- **Cron:** prevent armTimer tight loop when job has stuck runningAtMs
- **Cron:** fix 1/3 timeout on fresh isolated CLI runs
- **Cron:** recover flat patch params for update action and fix schema
- **Cron:** reject sessionTarget "main" for non-default agents at creation time
- **CLI:** set cron run exit code from run outcome
- **Telegram:** skip nullish final text sends
- **Routing:** treat group/channel peer.kind as equivalent
- **Gateway:** support wildcard in controlUi.allowedOrigins for remote access
- **Gateway:** handle CLI session expired errors gracefully instead of crashing
- **Gateway:** enforce owner boundary for agent runs
- **Session:** retire stale dm main route after dmScope migration
- **Signal:** prevent sentTranscript sync messages from bypassing loop protection
- **Doctor:** use posix path semantics for linux sd detection; warn when state dir is on SD/eMMC

### Security (upstream)
- Harden root-scoped writes against symlink races
- Enforce sandbox inheritance for sessions_spawn
- Block private-network web_search citation redirects
- Harden sandbox media reads against TOCTOU escapes
- Fix minor security vulnerability (#30948)

### Added (upstream)
- `sessions_spawn` sandbox require mode
- Control UI/Cron: persist delivery mode none on edit
- Node install: persist gateway token in service env

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
