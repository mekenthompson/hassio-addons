# Channels DVR Server - Home Assistant Add-on

Run Channels DVR Server directly on your Home Assistant installation for watching and recording live TV.

## About

[Channels DVR Server](https://getchannels.com) is a flexible, standalone media server that lets you watch TV your way. This add-on runs the official Channels DVR Server on your Home Assistant device.

**Features:**
- Watch and record live TV
- Electronic Program Guide (EPG)
- Hardware transcoding support (where available)
- Mobile apps for iOS and Android
- Web interface for management
- Support for HDHomeRun tuners
- TV Everywhere sources

## Installation

1. Install this add-on from the Home Assistant Add-on Store
2. Click **START** to run the add-on
3. Check the **Log** tab to verify the service started successfully
4. Click **OPEN WEB UI** to access the Channels DVR interface
5. Follow the setup wizard to configure your TV sources

## Configuration

This add-on requires minimal configuration and works out of the box.

The web interface is available on port 8089.

## Storage

Recordings are stored in `/share/channels-dvr` by default. You can access this through:
- Samba share
- File Editor add-on
- SSH/Terminal add-on

## Getting Started

1. Access the web UI at `http://YOUR_HOME_ASSISTANT_IP:8089`
2. Follow the setup wizard
3. Add your TV sources (HDHomeRun, TVE, etc.)
4. Start watching and recording!

## Supported TV Sources

- HDHomeRun network tuners
- TV Everywhere (cable/satellite provider login)
- Custom M3U playlists
- Other network tuners

## Requirements

- Minimum 1GB RAM recommended
- Storage space for recordings (HDTV averages ~8GB/hour)
- Network TV tuner (like HDHomeRun) or TV Everywhere account

## Support

For issues with this add-on, please open an issue on GitHub.

For Channels DVR Server specific support and documentation, visit:
- [GetChannels.com](https://getchannels.com)
- [Channels Community Forum](https://community.getchannels.com)
