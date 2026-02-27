# OpenClaw AI Assistant - Home Assistant Addon

OpenClaw is your personal AI assistant powered by Claude Opus 4.5, accessible via Telegram. It can browse the web, execute code, manage files, and help with tasks - all through simple Telegram messages.

## Features

- **Claude Opus 4.5**: Access to Anthropic's most powerful model
- **Telegram Integration**: Chat with your AI assistant via Telegram
- **Browser Automation**: Built-in Chromium for web browsing and screenshots
- **Power-User Features**: Persistent cache, tool installations, faster execution
- **Data Persistence**: Conversations and settings survive restarts
- **Secure**: Pairing-based authentication, runs in isolated container

## Prerequisites

Before installing this addon, you need:

### 1. Telegram Bot (Required)

Create a Telegram bot to communicate with OpenClaw:

1. Open Telegram and search for **@BotFather**
   - Make sure it's the verified account with a checkmark
2. Start a chat and send `/newbot`
3. Follow the prompts:
   - Choose a display name (e.g., "My OpenClaw Assistant")
   - Choose a username ending in "bot" (e.g., "myopenclaw_bot")
4. **Copy the bot token** - it looks like `1234567890:ABCdefGHIjklMNOpqrsTUVwxyz`
5. Save this token securely - you'll need it for the addon configuration

### 2. Claude Pro Account (Optional but Recommended)

To use Claude Opus 4.5, you have two options:

**Option A: Claude Pro Subscription** (Easier)
- Subscribe to Claude Pro at https://claude.ai
- After installation, run `claude setup-token` in the addon console
- Copy the session key to the addon configuration

**Option B: Anthropic API** (More reliable for heavy use)
- Sign up at https://console.anthropic.com
- Add billing information
- Create an API key
- Use the key directly in OpenClaw configuration

## Installation

1. Add this repository to Home Assistant:
   - Go to **Settings** → **Add-ons** → **Add-on Store** → **⋮ menu** → **Repositories**
   - Add: `https://github.com/mekenthompson/hassio-addons`

2. Find **OpenClaw AI Assistant** in the add-on store and click **Install**

3. Wait for the installation to complete (this may take 10-15 minutes as it builds OpenClaw from source)

## Configuration

### Basic Configuration

1. Open the addon's **Configuration** tab

2. Enter your **Telegram Bot Token**:
   ```yaml
   telegram_bot_token: "1234567890:ABCdefGHIjklMNOpqrsTUVwxyz"
   ```

3. (Optional) Enter your **Telegram User ID** for auto-approval:
   - Don't know your ID? Leave empty and follow the pairing process below
   - To find your ID: Message `@userinfobot` on Telegram

4. (Optional) Enter **Claude Pro Session Key**:
   - Get this by running `claude setup-token` in the addon terminal (after first start)

5. Click **Save**

### Full Configuration Options

```yaml
telegram_bot_token: "your-bot-token-here"
gateway_token: ""  # Leave empty to auto-generate
claude_session_key: ""  # Optional - for Claude Pro access
telegram_user_id: ""  # Optional - your Telegram user ID
additional_packages: []  # Optional - e.g., ["ffmpeg", "imagemagick"]
log_level: info  # Options: trace, debug, info, warning, error
```

## First Use

### Start the Addon

1. Go to the **Info** tab
2. Click **Start**
3. Watch the **Log** tab for initialization messages
4. Wait for "OpenClaw initialization complete!" and "Starting gateway on port 18789..."

### Pair with Your Bot

1. Open Telegram and find your bot (the username you created)
2. Send `/start` to the bot
3. The bot will respond with a **pairing code**
4. Check the addon **Log** tab
5. Look for the pairing approval message
6. Approve the code:
   - Option A: In the logs, it will show you how to approve
   - Option B: Add your Telegram User ID to the addon config to auto-approve

### First Conversation

Once paired, try chatting with your bot:

```
You: Hello, what model are you?
Bot: I'm Claude, specifically Claude Opus 4.5...

You: Can you browse to example.com and tell me what you see?
Bot: [Uses Chromium to visit the site and reports back]

You: What's the weather like in San Francisco?
Bot: [Searches and responds with current weather]
```

## Advanced Features

### Claude Pro Setup

If you have a Claude Pro subscription:

1. Start the addon
2. Go to **Terminal** tab (or use SSH addon)
3. Execute the addon's shell:
   ```bash
   docker exec -it addon_<uuid>_openclaw bash
   ```
4. Run as node user:
   ```bash
   su - node
   cd /app
   node dist/index.js claude setup-token
   ```
5. Follow the prompts to authenticate
6. Copy the session key
7. Add it to the addon configuration
8. Restart the addon

### Additional System Packages

Install extra tools for your AI assistant:

```yaml
additional_packages:
  - ffmpeg          # Audio/video processing
  - imagemagick     # Image manipulation
  - build-essential # Compile tools
  - python3-pip     # Python packages
```

Save and restart the addon to install these packages.

### Data Persistence

Your data is automatically persisted in `/data/`:

- **Configuration**: `/data/openclaw-config/` - Bot settings, tokens
- **Workspace**: `/data/openclaw-workspace/` - User files
- **Home Directory**: `/data/openclaw-home/` - Browser cache, tool installations

This data survives addon restarts and updates.

### Power-User Features (Enabled by Default)

This addon has power-user features enabled by default:

- **Chromium Browser**: Pre-installed for web automation
- **Playwright**: Ready for browser-based tasks
- **Persistent Cache**: Faster subsequent runs
- **Tool Storage**: Installed tools remain available

## Telegram Commands

Chat with your bot using these commands:

- `/start` - Initialize pairing
- `/status` - Check bot status
- `/reset` - Reset conversation
- `/model` - Show current model
- `/help` - Show available commands

## Troubleshooting

### Bot doesn't respond

**Check 1: Addon is running**
- Go to addon Info tab
- Verify status is "started"
- Check logs for errors

**Check 2: Bot token is correct**
- Verify token in configuration
- Test token: `curl https://api.telegram.org/bot<token>/getMe`
- Should return bot info if token is valid

**Check 3: Pairing completed**
- Check logs for pairing code
- Ensure you approved the pairing
- Or add your Telegram User ID to config

### "Pairing required" message

This is normal on first use:
1. Send `/start` to your bot
2. Bot responds with a code
3. Check addon logs
4. Approve the code as shown in logs
5. Or add your Telegram User ID to addon config to skip pairing

### Claude responses failing

**Check Claude authentication:**
- If using Claude Pro: Verify session key is set
- If using API: Verify API key is correct
- Check logs for authentication errors
- Try re-running `claude setup-token`

### Browser automation not working

**Verify Chromium installation:**
1. Check logs during init for Playwright installation
2. Look for errors in `/data/openclaw-home/.cache/ms-playwright`
3. Try restarting the addon to re-run initialization

### Logs show "permission denied"

Permissions are automatically set during init. If you see this:
1. Restart the addon
2. Check that `/data/openclaw-*` directories exist
3. Verify ownership is `node:node`

## Security Considerations

- **Bot Token**: Keep your bot token secret - anyone with it can control your bot
- **Gateway Token**: Auto-generated and stored securely in `/data/`
- **Pairing**: Only approved Telegram users can chat with your bot
- **Isolation**: Runs in containerized environment
- **Local**: All processing happens on your Home Assistant instance

## Performance

- **First start**: 10-15 minutes (builds OpenClaw, installs Chromium)
- **Subsequent starts**: 30-60 seconds
- **Response time**: Varies by request complexity (2-30 seconds typical)
- **Memory**: ~500MB-1GB depending on usage
- **Storage**: ~2-3GB for full install with cache

## Support

- **OpenClaw Documentation**: https://docs.openclaw.ai
- **Telegram Channel Setup**: https://docs.openclaw.ai/channels/telegram
- **Issue Tracker**: https://github.com/mekenthompson/hassio-addons/issues

## Credits

- **OpenClaw**: https://github.com/openclaw/openclaw
- **Anthropic Claude**: https://www.anthropic.com
- **Home Assistant**: https://www.home-assistant.io
