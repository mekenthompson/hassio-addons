# OpenClaw AI Assistant for Home Assistant

[![License][license-shield]](LICENSE)
[![Project Stage][project-stage-shield]][project-stage]

Your personal AI assistant powered by Claude Opus 4.5, accessible via Telegram, running directly on your Home Assistant instance.

## About

OpenClaw is an open-source AI assistant that brings Claude's powerful capabilities to your Home Assistant setup. Chat with Claude via Telegram, have it browse the web, manage files, and help with tasks - all from the convenience of your phone.

## Features

- 🤖 **Claude Opus 4.5**: Access to Anthropic's most powerful AI model
- 💬 **Telegram Integration**: Simple, familiar chat interface
- 🌐 **Web Browsing**: Built-in Chromium for web automation
- 🔧 **Power-User Ready**: Pre-configured with Chromium and Playwright
- 💾 **Persistent Storage**: Conversations and settings survive restarts
- 🔒 **Secure**: Pairing-based authentication, containerized execution
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
