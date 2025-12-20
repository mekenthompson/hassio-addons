# Home Assistant Add-on: VS Code Server

This add-on runs [code-server][code-server] (v4.107.0), providing a full
VS Code experience in your browser. Edit your Home Assistant configuration
files, automations, and scripts directly from the web.

## Installation

1. Add this repository to your Home Assistant Add-on Store:

   [![Add Repository][repo-badge]][repo-add]

   Or manually add: `https://github.com/mekenthompson/hassio-addons`

2. Install **VS Code Server** from the add-on store.
3. Configure the add-on (see Configuration below).
4. Start the add-on.
5. Click **OPEN WEB UI** to access VS Code in your browser.

## Configuration

**Note**: _Restart the add-on after changing configuration._

### Example configuration

```yaml
password: "your-secure-password"
default_workspace: /homeassistant
init_commands:
  - git config --global user.name "Your Name"
  - git config --global user.email "you@example.com"
log_level: info
```

### Option: `password`

The password to access VS Code Server. If left empty, authentication is
disabled and access is controlled by Home Assistant's authentication via
Ingress.

**Recommendation**: Leave empty and use Ingress for the most secure setup.
Only set a password if you need direct port access from outside Home Assistant.

### Option: `default_workspace`

The directory that opens when VS Code starts. Defaults to `/homeassistant`.

Available directories:

| Path | Description |
|------|-------------|
| `/homeassistant` | Your Home Assistant configuration directory |
| `/share` | Shared data accessible by all add-ons |
| `/config` | Add-on specific configuration |
| `/ssl` | SSL certificates (read-only) |
| `/addons` | Installed add-ons (read-only) |
| `/backup` | Backup files (read-only) |

### Option: `init_commands`

A list of shell commands to run when the add-on starts. Useful for:

- Setting up Git configuration
- Installing additional tools
- Running setup scripts

```yaml
init_commands:
  - git config --global user.name "Your Name"
  - git config --global core.editor "code --wait"
```

### Option: `log_level`

Controls the verbosity of add-on logs:

| Level | Description |
|-------|-------------|
| `trace` | Show every detail, including internal function calls |
| `debug` | Detailed debug information |
| `info` | Normal interesting events (default) |
| `warning` | Exceptional occurrences that are not errors |
| `error` | Runtime errors that do not require immediate action |
| `fatal` | Something went terribly wrong |

## Accessing VS Code

### Via Ingress (Recommended)

Click **OPEN WEB UI** in the add-on panel or use the sidebar icon.
Authentication is handled by Home Assistant automatically.

### Via Direct Port (Optional)

If you need access from outside Home Assistant:

1. In the add-on **Configuration** tab, under **Network**, set a port for
   `8080/tcp` (e.g., `8443`)
2. Set a strong `password` in the configuration
3. Access via `http://your-home-assistant:8443`

**Note**: Direct port access bypasses Home Assistant authentication. Always
use a strong password and consider using HTTPS via a reverse proxy.

## Features

- **Full VS Code Experience**: Complete editor with IntelliSense, debugging,
  and terminal access
- **Extension Marketplace**: Install extensions directly from the UI
- **Git Integration**: Built-in Git support with SSH key authentication
- **Persistent Storage**: Settings and extensions survive restarts/updates
- **Ingress Support**: Secure access through Home Assistant's authentication
- **Health Monitoring**: Automatic restart on failure via watchdog

## Recommended Extensions for Home Assistant

Install these extensions for the best Home Assistant development experience:

| Extension | ID | Description |
|-----------|-----|-------------|
| Home Assistant Config Helper | `keesschollaart.vscode-home-assistant` | Syntax validation, auto-complete |
| YAML | `redhat.vscode-yaml` | Enhanced YAML support |
| ESPHome | `esphome.esphome-vscode` | ESPHome device configuration |
| Jinja | `samuelcolvin.jinjahtml` | Jinja2 template highlighting |

To install: Open VS Code → Extensions (Ctrl+Shift+X) → Search → Install

## Backup & Restore

The add-on automatically excludes cache directories from backups to reduce
size. Your important data is preserved:

- **Included**: Settings, extensions, workspace configurations
- **Excluded**: Cache files, logs, temporary data

## Troubleshooting

### VS Code is slow or unresponsive

- Check available memory on your Home Assistant host
- Disable unused extensions
- Clear the cache: Delete `/data/code-server/CachedData`

### Extensions fail to install

- Check your internet connection
- Some extensions require specific architectures and may not work on ARM

### Terminal not working

- The terminal runs inside the add-on container, not on your host system
- Use SSH add-on if you need direct host access

### Git authentication fails

1. Generate an SSH key inside VS Code terminal:
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   cat ~/.ssh/id_ed25519.pub
   ```
2. Add the public key to your Git provider (GitHub, GitLab, etc.)

## Known Limitations

- Some extensions requiring native binaries may not work on all architectures
- The terminal runs inside the container, not on the host system
- File watchers are limited; very large projects may experience delays

## Version Information

This add-on pins code-server to a specific version for stability. When
updating the add-on, check the changelog for code-server version changes.

| Add-on Version | code-server Version |
|----------------|---------------------|
| 2.0.0 | 4.107.0 |
| 1.0.0 | Latest at install time |

## Support

- **Add-on Issues**: [GitHub Issues][addon-issues]
- **code-server Issues**: [code-server GitHub][code-server-issues]
- **Community**: [Home Assistant Community Forum][ha-forum]

## License

MIT License - see [LICENSE.md][license]

[addon-issues]: https://github.com/mekenthompson/hassio-addons/issues
[code-server]: https://github.com/coder/code-server
[code-server-issues]: https://github.com/coder/code-server/issues
[ha-forum]: https://community.home-assistant.io/
[license]: https://github.com/mekenthompson/hassio-addons/blob/main/LICENSE.md
[repo-badge]: https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg
[repo-add]: https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fmekenthompson%2Fhassio-addons
