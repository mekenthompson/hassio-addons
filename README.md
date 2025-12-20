#  Home Assistant Add-ons

[![Add repository to Home Assistant](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fmekenthompson%2Fhassio-addons)

A collection of Home Assistant add-ons for enhanced functionality.

## Installation

Click the button above, or manually add this repository URL in Home Assistant:

```
https://github.com/mekenthompson/hassio-addons
```

**Settings** → **Add-ons** → **Add-on Store** → **⋮** (menu) → **Repositories** → Paste URL → **Add**

## Add-ons

| Add-on | Description |
|--------|-------------|
| [Channels DVR Server](channels-dvr/) | Manage and record live TV with Channels DVR Server |
| [VS Code Server](coder/) | VS Code in the browser powered by code-server |
| [RustDesk Server Pro](rustdesk-server-pro/) | Self-hosted RustDesk Pro server for remote desktop access |

## Data Preservation

Each add-on stores its data based on its `slug` identifier. Reinstalling from this repository will **not** overwrite existing addon data:

- `channels-dvr` → `/addon_config/channels-dvr/`
- `coder` → `/addon_config/coder/`
- `rustdesk-server-pro` → `/addon_config/rustdesk-server-pro/`

## License

See individual add-on directories for license information.
