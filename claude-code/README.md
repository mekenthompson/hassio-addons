# Home Assistant Add-on: Claude Code

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fmekenthompson%2Fhassio-addons)

Run Anthropic's Claude Code CLI inside Home Assistant with a web terminal and automatic remote-control for mobile access. Supports Claude Pro/Max subscriptions.

## Features

- Claude Code CLI in a web terminal via the HA sidebar
- Automatic `claude remote-control` at startup for phone/mobile access
- Works with HA Network Storage for Synology NAS (or any NFS/SMB share)
- Claude Pro/Max subscription support via `claude login`
- Full Home Assistant API and admin access
- Persistent auth tokens and config across restarts

## Quick Start

1. Set up your code directory as Network Storage in HA (Settings > System > Storage)
2. Add this repository to your HA add-on store
3. Install **Claude Code**
4. Start the add-on and open from the sidebar
5. Run `claude login` in the terminal to authenticate with your subscription
