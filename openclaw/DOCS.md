# OpenClaw AI Assistant — Documentation

## Table of Contents

- [First-Time Setup](#first-time-setup)
- [Multi-Agent Setup](#multi-agent-setup)
- [Configuration Layers](#configuration-layers)
- [Config-as-Code Guide](#config-as-code-guide)
- [Home Assistant Integration](#home-assistant-integration)
- [Encrypted Backups](#encrypted-backups)
- [Data Layout](#data-layout)
- [Migration from Separate Add-ons](#migration-from-separate-add-ons)
- [Breaking Changes in v2.0.0](#breaking-changes-in-v200)
- [Troubleshooting](#troubleshooting)

---

## First-Time Setup

### 1. Create a Telegram Bot

1. Open Telegram and message [@BotFather](https://t.me/BotFather)
2. Send `/newbot`, choose a name and username
3. Copy the bot token (e.g. `1234567890:ABCdefGHI...`)

### 2. Find Your Telegram User ID

Message [@userinfobot](https://t.me/userinfobot) — it replies with your numeric ID.

### 3. Configure the Add-on

In HA: Settings → Add-ons → OpenClaw → Configuration:

- **telegram_bot_token**: Paste your bot token
- **telegram_user_id**: Your numeric Telegram ID

Save and start. The init script generates `openclaw.json` with your settings.

### 4. First Message

Message your bot in Telegram. On first contact you may need to:
- Send `/start`
- Approve the pairing code (shown in add-on logs)

Or, if you set `telegram_user_id`, pairing is automatic.

### 5. Add API Keys

Via the OpenClaw web UI (HA sidebar → OpenClaw):
- Add Anthropic API key for Claude
- Optionally add OpenAI (for Whisper), Google, Perplexity, etc.

Or edit `/data/openclaw-config/openclaw.json` directly.

---

## Multi-Agent Setup

Run two agents from a single add-on — each with their own Telegram bot, workspace, memory, and persona.

### Configuration

In the add-on options, fill in both sets of bot credentials:

```yaml
# Primary agent
telegram_bot_token: "your-bot-token"
telegram_user_id: "your-telegram-id"

# Second agent
lisa_telegram_bot_token: "second-bot-token"
lisa_telegram_user_id: "second-telegram-id"
```

Restart the add-on. The init script creates a multi-agent `openclaw.json` with:
- Two agents (`main` and `lisa`) with separate workspaces
- Two Telegram bot accounts bound to their respective agents
- Agent-to-agent messaging enabled

### What's Isolated

| Feature | Isolated per agent? |
|---------|-------------------|
| Workspace files (SOUL.md, USER.md, etc.) | ✅ |
| Memory (MEMORY.md, memory/*.md) | ✅ |
| Memory search index (qmd/SQLite) | ✅ |
| Sessions and history | ✅ |
| Cron jobs | ✅ |
| Telegram bot and chat | ✅ |

### What's Shared

| Feature | Shared? |
|---------|---------|
| API keys and model providers | ✅ (same `openclaw.json`) |
| Gateway port and web UI | ✅ |
| Installed tools (gh, bun, etc.) | ✅ |
| Browser (Chromium/Playwright) | ✅ |
| `/share/` and `/data/openclaw-home/` | ✅ |

### Agent-to-Agent

With `agentToAgent` enabled, the primary agent can:
- List the second agent's sessions
- Send messages to the second agent's sessions
- View session history

This is useful for the primary agent to help manage or configure the second agent.

---

## Configuration Layers

Understanding what configures what:

```
┌─────────────────────────────────────────┐
│  Add-on Config (HA UI)                  │
│  Purpose: Bootstrap + Infrastructure    │
│  - Bot tokens (first run only)          │
│  - Gateway token (every restart)        │
│  - Additional packages (every restart)  │
│  File: /data/options.json               │
├─────────────────────────────────────────┤
│  openclaw.json (Source of Truth)        │
│  Purpose: All runtime configuration     │
│  - Agents, workspaces, models           │
│  - Channels, bindings                   │
│  - Tools, hooks, cron                   │
│  - Sessions, context, memory settings   │
│  File: /data/openclaw-config/openclaw.json │
├─────────────────────────────────────────┤
│  Workspace Files (Per-Agent Persona)    │
│  Purpose: Agent identity and behaviour  │
│  - SOUL.md, USER.md, AGENTS.md          │
│  - MEMORY.md, IDENTITY.md, TOOLS.md     │
│  Path: /data/openclaw-workspace/        │
│        /data/openclaw-workspace-lisa/    │
├─────────────────────────────────────────┤
│  Credentials (Secrets)                  │
│  Purpose: API keys, tokens, SSH keys    │
│  Path: /data/openclaw-config/credentials/ │
└─────────────────────────────────────────┘
```

**After first boot:** changes to add-on config bot tokens are ignored — `openclaw.json` is authoritative. Only `gateway_token` and `additional_packages` are re-applied on restart.

---

## Config-as-Code Guide

Manage your OpenClaw configuration in a git repository for reproducibility and disaster recovery.

### Principles

1. **openclaw.json** uses SecretRef objects — safe to commit (no plaintext secrets)
2. **secrets.json** holds actual values — stays on disk, never in git
3. **Workspace files** (SOUL.md, etc.) are authored config — in git
4. **Memory files** (MEMORY.md, memory/*.md) are runtime state — not in git
5. **Credentials** (OAuth tokens, SSH keys) are backed up encrypted

### SecretRef Setup

1. Create `/data/openclaw-config/credentials/secrets.json`:
   ```json
   {
     "anthropic": { "apiKey": "sk-ant-..." },
     "openai": { "apiKey": "sk-..." },
     "telegram": {
       "kenBotToken": "8588...",
       "lisaBotToken": "..."
     }
   }
   ```

2. Configure the secrets provider in `openclaw.json`:
   ```json
   {
     "secrets": {
       "providers": {
         "creds": {
           "source": "file",
           "path": "/data/openclaw-config/credentials/secrets.json",
           "mode": "json"
         }
       }
     }
   }
   ```

3. Replace plaintext values with SecretRef objects:
   ```json
   {
     "models": {
       "providers": {
         "anthropic": {
           "apiKey": { "source": "file", "provider": "creds", "id": "/anthropic/apiKey" }
         }
       }
     }
   }
   ```

4. Verify: `openclaw secrets audit --check` should report zero plaintext findings.

### Repository Structure

```
your-openclaw-config/
├── openclaw.json              # SecretRef objects, safe to commit
├── ken/
│   ├── workspace/
│   │   ├── SOUL.md
│   │   ├── USER.md
│   │   ├── AGENTS.md
│   │   ├── IDENTITY.md
│   │   ├── HEARTBEAT.md
│   │   └── TOOLS.md
│   └── bin/                    # Custom scripts
├── lisa/
│   └── workspace/
│       ├── SOUL.md
│       ├── USER.md
│       └── ...
├── secrets.json.example        # Shape only, no values
├── deploy.sh                   # Sync to add-on data dirs
└── README.md
```

### Deploy Script

```bash
#!/bin/bash
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# Sync config (hot-reloaded by gateway)
cp "$REPO_DIR/openclaw.json" /data/openclaw-config/openclaw.json

# Sync workspaces (exclude memory — runtime state)
rsync -av --exclude='memory/' --exclude='MEMORY.md' \
    "$REPO_DIR/ken/workspace/" /data/openclaw-workspace/
rsync -av --exclude='memory/' --exclude='MEMORY.md' \
    "$REPO_DIR/lisa/workspace/" /data/openclaw-workspace-lisa/

# Sync custom scripts
rsync -av "$REPO_DIR/ken/bin/" /data/openclaw-home/bin/
chmod +x /data/openclaw-home/bin/*

echo "Deployed. Gateway will hot-reload config changes."
```

---

## Home Assistant Integration

This add-on does not use the Supervisor API (`$SUPERVISOR_TOKEN`). HA control is via scoped, credential-based access — safer for multi-agent setups.

### SSH (Admin Tasks)

For add-on management, backups, host operations:

1. Generate an SSH keypair:
   ```bash
   ssh-keygen -t ed25519 -f /data/openclaw-config/credentials/ha-ssh-key.pem -N ""
   ```

2. Add the public key to HA SSH add-on's `authorized_keys` config

3. Use the `ha-admin` wrapper:
   ```bash
   ha-admin host info
   ha-admin addons list
   ha-admin backups new --name "pre-update"
   ha-admin os update
   ```

### REST API (Entity Control)

For device states, service calls, automations:

1. Create an HA user (Settings → People → Users) with Administrator role
2. Generate a long-lived access token (Profile → Security)
3. Save to `/data/openclaw-config/credentials/ha-access-token`

4. Use the `ha-api` wrapper:
   ```bash
   ha-api GET states/sensor.temperature
   ha-api POST services/light/turn_on -d '{"entity_id":"light.lounge"}'
   ha-api GET states
   ```

### MCP Server (Optional)

For structured entity control via OpenClaw's mcporter:

1. Enable MCP Server integration in HA (Settings → Integrations)
2. Configure exposed entities (Settings → Voice Assistants → Exposed Entities)
3. Add to mcporter config with the REST API token

---

## Encrypted Backups

Protect credentials for disaster recovery using `age` encryption.

### Setup

1. Generate an age keypair:
   ```bash
   age-keygen -o /tmp/age-key.txt
   ```

2. Save the **private key** to your password manager (this is the master recovery key)

3. Save the **public key** on disk:
   ```bash
   grep "public key:" /tmp/age-key.txt | awk '{print $NF}' \
       > /data/openclaw-config/credentials/age-recipient.txt
   rm /tmp/age-key.txt
   ```

4. Run: `backup-secrets` — creates an encrypted archive in `/share/backups/openclaw/`

### Restore (Disaster Recovery)

```bash
# Decrypt with your private key (from password manager)
age -d -i /path/to/private-key.txt /share/backups/openclaw/secrets-2026-02-28.tar.age \
    | tar xf - -C /data/openclaw-config/
```

### Automate

Schedule `backup-secrets` as an OpenClaw cron job for daily encrypted backups.

---

## Data Layout

```
/data/
├── openclaw-config/              # Primary agent config
│   ├── openclaw.json             # Source of truth (all runtime config)
│   ├── gateway.token             # Generated/synced gateway auth token
│   ├── workspace -> /data/openclaw-workspace/
│   ├── credentials/
│   │   ├── secrets.json          # SecretRef values (API keys)
│   │   ├── ha-ssh-key.pem        # SSH key for HA admin
│   │   ├── ha-access-token       # HA REST API token
│   │   ├── age-recipient.txt     # Age public key for backups
│   │   └── ...                   # OAuth tokens, other creds
│   └── state/                    # Session history, indexes
├── openclaw-workspace/           # Primary agent workspace
│   ├── SOUL.md, USER.md, ...     # Agent persona files
│   ├── MEMORY.md                 # Long-term memory
│   └── memory/                   # Daily memory notes
│   └── workspace -> /data/openclaw-workspace-lisa/
├── openclaw-workspace-lisa/      # Second agent workspace
│   ├── SOUL.md, USER.md, ...
│   ├── MEMORY.md
│   └── memory/
├── openclaw-home/                # Shared persistent home
│   ├── bin/                      # Custom scripts (ha-admin, etc.)
│   ├── .config/gh/               # GitHub CLI auth
│   ├── .cache/ms-playwright/     # Chromium cache
│   └── .local/                   # Other CLI tools
└── options.json                  # Add-on config (bootstrap)
```

---

## Migration from Separate Add-ons

If you previously ran separate `openclaw` and `openclaw-lisa` add-ons:

### 1. Back Up Lisa's Data

From HA Terminal or SSH add-on:
```bash
docker exec addon_XXXXX_openclaw-lisa bash -c '
    mkdir -p /share/openclaw-lisa-migration
    cp -a /data/openclaw-config /share/openclaw-lisa-migration/config
    cp -a /data/openclaw-workspace /share/openclaw-lisa-migration/workspace
    cp -a /data/openclaw-home /share/openclaw-lisa-migration/home 2>/dev/null || true
'
```

### 2. Update the Add-on

- Pull the new version of the consolidated add-on
- Enter Lisa's bot token and user ID in the add-on config
- Rebuild and start

### 3. Restore Lisa's Workspace

```bash
# Copy workspace files (memory, persona, work files)
cp -a /share/openclaw-lisa-migration/workspace/* /data/openclaw-workspace-lisa/

# Copy any Lisa-specific credentials
cp -a /share/openclaw-lisa-migration/config/credentials/* \
```

### 4. Verify

- Message both bots in Telegram
- Check that memory search works for both agents
- Verify workspace files are intact

### 5. Clean Up

Once verified:
- Uninstall the old `openclaw-lisa` add-on from HA
- Remove `/share/openclaw-lisa-migration/`

---

## Troubleshooting

### Bot doesn't respond

1. Check add-on is running (Info tab → status)
2. Check logs for errors
3. Verify bot token: `curl https://api.telegram.org/bot<token>/getMe`
4. Check pairing: send `/start` to the bot

### Second agent not working

1. Verify `lisa_telegram_bot_token` is set in add-on config
2. Check logs for "Lisa Telegram: configured"
3. Verify `openclaw.json` has the `lisa` agent and binding
4. Check that Lisa's workspace directory exists

### "Pairing required"

Normal on first use. Send `/start`, check logs for the pairing code, approve it. Or set `telegram_user_id` in add-on config for auto-approval.

### Memory search not returning results

Each agent's memory search indexes only their own workspace. Check:
- `MEMORY.md` exists in the agent's workspace
- `memory/*.md` files exist
- qmd index may need rebuilding (restart the add-on)

### Permission errors

The init script sets ownership on boot. Try restarting the add-on. If persistent, check that `/data/openclaw-*` directories are owned by `node:node`.

---

## Breaking Changes in v2.0.0

### Supervisor API Access Removed

The add-on no longer requests `hassio_api`, `auth_api`, or `homeassistant_api` permissions. The `$SUPERVISOR_TOKEN` and `$HASSIO_TOKEN` environment variables are no longer available inside the container.

**Impact:** Any custom scripts or automations that used `curl http://supervisor/...` from within the add-on will stop working.

**Migration:** Use `ha-admin` (SSH to HA SSH add-on) or `ha-api` (REST API with long-lived token) instead. See [Home Assistant Integration](#home-assistant-integration).

### Directory Mappings Reduced

The following directory mappings have been removed:

- `homeassistant_config:rw` — the `/homeassistant/` path is no longer available inside the container
- `media:ro` — the `/media/` path is no longer available inside the container

**Impact:** Any agent workflows that read/write HA config files or access media files will break.

**Migration:** Access HA config via the REST API or SSH. For media files, use the `/share/` directory (still mapped `rw`).

### Lisa Add-on Replaced

The separate `openclaw-lisa` add-on is replaced by the multi-agent support in the main `openclaw` add-on. See [Migration from Separate Add-ons](#migration-from-separate-add-ons).
