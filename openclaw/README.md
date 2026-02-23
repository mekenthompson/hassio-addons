# OpenClaw AI Assistant for Home Assistant

[![License][license-shield]](LICENSE)
[![Project Stage][project-stage-shield]][project-stage]

Your personal AI assistant powered by Claude, accessible via Telegram, running directly on your Home Assistant instance.

## About

OpenClaw is an open-source AI assistant that brings Claude's capabilities to your Home Assistant setup. Chat via Telegram, browse the web, manage files, search memory semantically, and automate tasks — all from your phone.

## Features

- 🤖 **Claude Opus 4**: Access to Anthropic's most capable AI model (configurable)
- 💬 **Telegram Integration**: Chat interface with topic threads, reactions, and inline buttons
- 🌐 **Web Browsing**: Built-in Chromium with optional GPU acceleration (Intel iGPU)
- 🧠 **Semantic Memory**: QMD-powered memory search with vector embeddings and BM25 hybrid retrieval
- 💾 **Persistent Storage**: Config, sessions, CLI tools, caches, and memory indexes survive rebuilds
- 🔧 **Power-User Ready**: Pre-installed gh CLI, bun, Playwright, and qmd
- ⏰ **Cron Jobs**: Scheduled tasks with isolated sessions and Telegram delivery
- 🔒 **Secure**: Pairing-based auth, containerized execution, exec allowlists
- 🚀 **Fast**: Optimized Docker build with layer caching

## Prerequisites

Before installing, you'll need:

1. **Telegram Bot**: Create one via @BotFather (takes 2 minutes)
2. **Claude Access**: Either Claude Pro subscription or Anthropic API key

See [full documentation](DOCS.md) for detailed setup instructions.

## Installation

1. Add this repository to Home Assistant:
   ```
   https://github.com/mekenthompson/hassio-addons
   ```

2. Install the **OpenClaw AI Assistant** addon

3. Configure your Telegram bot token

4. Start the addon and pair with your bot!

## Quick Start

1. Open Telegram and message your bot
2. Send `/start` to initiate pairing
3. Approve the pairing code in the addon logs
4. Start chatting with Claude!

```
You: What's the weather in San Francisco?
Bot: [Searches and provides current weather information]

You: Can you browse to example.com and summarize what you see?
Bot: [Uses Chromium to visit the site and provides a summary]
```

## Configuration

Minimal configuration:

```yaml
telegram_bot_token: "your-bot-token-from-botfather"
```

Full options available in the addon configuration UI.

## Documentation

- [Full Documentation](DOCS.md) - Complete setup and usage guide
- [OpenClaw Docs](https://docs.openclaw.ai) - Official OpenClaw documentation
- [Telegram Setup](https://docs.openclaw.ai/channels/telegram) - Telegram integration guide

## Support

Found a bug or have a feature request?

- [Open an issue](https://github.com/mekenthompson/hassio-addons/issues)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)

## Architecture

- **amd64** (Intel/AMD 64-bit)

## Credits

- [OpenClaw](https://github.com/openclaw/openclaw) - Open-source AI assistant framework
- [Anthropic Claude](https://www.anthropic.com) - AI model provider
- [Home Assistant](https://www.home-assistant.io) - Smart home platform

## License

MIT License - See [LICENSE](LICENSE) for details.

[license-shield]: https://img.shields.io/github/license/mekenthompson/hassio-addons.svg
[project-stage-shield]: https://img.shields.io/badge/project%20stage-stable-green.svg
[project-stage]: https://github.com/mekenthompson/hassio-addons
