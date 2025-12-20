# VS Code Server - Home Assistant Add-on

Run VS Code directly in your browser for editing Home Assistant configuration files.

## About

This add-on runs [code-server](https://github.com/coder/code-server) (v4.107.0), providing a full VS Code experience in your browser. Edit your Home Assistant configuration files, automations, and scripts without leaving the web interface.

**Features:**
- Full VS Code editor in your browser
- IntelliSense, syntax highlighting, and debugging
- Extension marketplace support
- Integrated terminal
- Git integration with SSH key support
- Ingress support for secure access via Home Assistant authentication

## Installation

1. Add this repository to your Home Assistant Add-on Store
2. Install **VS Code Server** from the add-on store
3. Start the add-on
4. Click **OPEN WEB UI** or use the sidebar icon

## Configuration

```yaml
password: ""                        # Leave empty for Ingress auth (recommended)
default_workspace: /homeassistant   # Directory to open on start
init_commands: []                   # Shell commands to run on startup
log_level: info                     # Logging verbosity
```

### Available Directories

| Path | Description |
|------|-------------|
| `/homeassistant` | Home Assistant configuration |
| `/share` | Shared data for all add-ons |
| `/config` | Add-on specific configuration |
| `/ssl` | SSL certificates (read-only) |
| `/addons` | Installed add-ons (read-only) |
| `/backup` | Backup files (read-only) |

## Recommended Extensions

| Extension | Description |
|-----------|-------------|
| Home Assistant Config Helper | Syntax validation, auto-complete |
| YAML | Enhanced YAML support |
| ESPHome | ESPHome device configuration |
| Jinja | Jinja2 template highlighting |

## Support

- **Add-on Issues**: [GitHub Issues](https://github.com/mekenthompson/hassio-addons/issues)
- **code-server**: [code-server GitHub](https://github.com/coder/code-server)
- **Community**: [Home Assistant Community Forum](https://community.home-assistant.io/)
