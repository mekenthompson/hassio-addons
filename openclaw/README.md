# OpenClaw AI Assistant for Home Assistant

[![License][license-shield]](LICENSE)
[![Project Stage][project-stage-shield]][project-stage]

A multi-agent AI assistant running directly on your Home Assistant instance. Chat via Telegram, browse the web, manage files, search memory, and automate tasks.

## About

OpenClaw is an open-source AI assistant framework. This add-on packages it for Home Assistant with persistent storage, Telegram integration, and multi-agent support — run separate agents for different family members from a single add-on.

## Features

- 🤖 **Multi-Agent** — Run separate agents with isolated workspaces, memory, and personas
- 💬 **Telegram** — Each agent gets its own Telegram bot with topic threads, reactions, and inline buttons
- 🌐 **Web Browsing** — Built-in Chromium with optional Intel iGPU acceleration
- 🧠 **Semantic Memory** — QMD-powered vector + BM25 hybrid retrieval per agent
- ⏰ **Cron Jobs** — Scheduled tasks with isolated sessions
- 🔧 **Power Tools** — Pre-installed gh CLI, Bun, Playwright, ripgrep, tmux
- 🔐 **Config-as-Code** — SecretRef support, `${VAR}` substitution, modular `$include` configs
- 🔒 **Secure** — No supervisor API access; HA control via scoped SSH + REST API tokens

## Architecture

```
┌─────────────────────────────────────────┐
│  Home Assistant OS                       │
│  ┌─────────────────────────────────────┐ │
│  │ OpenClaw Add-on (single container)  │ │
│  │                                     │ │
│  │  Agent: "main"    Agent: "lisa"     │ │
│  │  ├─ Workspace     ├─ Workspace      │ │
│  │  ├─ Memory        ├─ Memory         │ │
│  │  ├─ Sessions      ├─ Sessions       │ │
│  │  └─ @BotOne       └─ @BotTwo      │ │
│  │                                     │ │
│  │  Shared: models, tools, gateway     │ │
│  └─────────────────────────────────────┘ │
│           │              │               │
│    SSH (ha CLI)    REST API (entities)   │
│           ↓              ↓               │
│  ┌─────────────────────────────────────┐ │
│  │  Home Assistant Core                │ │
│  └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

## Quick Start

### Prerequisites

1. **Telegram Bot(s)** — Create via [@BotFather](https://t.me/BotFather) (one per agent)
2. **Anthropic API Key** or **Claude Pro session key**
3. **Telegram User ID(s)** — Message [@userinfobot](https://t.me/userinfobot) to find yours

### Install

1. Add this repository to HA: `https://github.com/mekenthompson/hassio-addons`
2. Install **OpenClaw AI Assistant** from the add-on store
3. Enter your Telegram bot token in the add-on configuration
4. Start the add-on and message your bot

### Adding a Second Agent

1. Create a second Telegram bot via @BotFather
2. Enter the second bot token and user ID in the add-on config
3. Restart the add-on — both agents start automatically
4. Each agent has its own workspace, memory, and persona

## Configuration

### Add-on Options (HA UI)

These are **bootstrap settings** — used on first run to generate the initial `openclaw.json`. After first boot, `openclaw.json` is the source of truth.

| Option | Purpose | When Used |
|--------|---------|-----------|
| `telegram_bot_token` | Primary agent's Telegram bot | First run only |
| `telegram_user_id` | Primary agent's allowed Telegram user | First run only |
| `lisa_telegram_bot_token` | Second agent's Telegram bot | First run only |
| `lisa_telegram_user_id` | Second agent's allowed Telegram user | First run only |
| `claude_session_key` | Initial Claude Pro auth | First run only |
| `gateway_token` | Web UI / API auth token | Every restart |
| `additional_packages` | Extra apt packages to install | Every restart |
| `log_level` | Logging verbosity | First run only |

### openclaw.json (Source of Truth)

After first boot, all configuration lives in `/data/openclaw-config/openclaw.json`:
- Agent definitions, workspaces, and models
- Channel accounts and bindings
- Tool settings and permissions
- Cron jobs and hooks

Edit via the OpenClaw web UI (sidebar panel) or directly.

### Config-as-Code

For version-controlled configuration:

1. Use **SecretRef** objects in `openclaw.json` for API keys:
   ```json
   { "source": "file", "provider": "creds", "id": "/anthropic/apiKey" }
   ```
2. Store actual secrets in `/data/openclaw-config/credentials/secrets.json`
3. Commit `openclaw.json` to git (safe — no plaintext secrets)
4. Keep `secrets.json` out of git, backed up with `age` encryption

See [DOCS.md](DOCS.md) for the full config-as-code guide.

## Data Persistence

All data survives add-on restarts and updates:

| Path | Contents |
|------|----------|
| `/data/openclaw-config/` | Main config, credentials, gateway token |
| `/data/openclaw-workspace/` | Primary agent's workspace and memory |
| `/data/openclaw-workspace-lisa/` | Second agent's workspace and memory |
| `/data/openclaw-home/` | CLI tools, browser cache, custom scripts |

## Home Assistant Integration

This add-on does **not** use the Supervisor API. HA control is via scoped credentials:

- **SSH** to HA SSH add-on → `ha` CLI for admin tasks (add-ons, backups, host)
- **REST API** with long-lived token → entity control, service calls, automations
- **MCP Server** (optional) → structured tools for entity control via OpenClaw's mcporter

Setup:
1. Generate an SSH keypair and add to the HA SSH add-on
2. Create an HA user and long-lived access token
3. Store credentials in `/data/openclaw-config/credentials/`
4. Use the `ha-admin` and `ha-api` wrapper scripts (auto-installed on first boot)

## Utility Scripts

Installed to `/data/openclaw-home/bin/` on first run:

| Script | Purpose |
|--------|---------|
| `ha-admin` | Proxy `ha` CLI commands through HA SSH add-on |
| `ha-api` | Thin wrapper for HA REST API calls |
| `backup-secrets` | Age-encrypt credentials directory for disaster recovery |

## Support

- [OpenClaw Documentation](https://docs.openclaw.ai)
- [Telegram Setup Guide](https://docs.openclaw.ai/channels/telegram)
- [Issue Tracker](https://github.com/mekenthompson/hassio-addons/issues)

## License

MIT License — See [LICENSE](LICENSE) for details.

[license-shield]: https://img.shields.io/github/license/mekenthompson/hassio-addons.svg
[project-stage-shield]: https://img.shields.io/badge/project%20stage-stable-green.svg
[project-stage]: https://github.com/mekenthompson/hassio-addons
