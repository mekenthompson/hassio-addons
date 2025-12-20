# Home Assistant Add-on: Channels DVR Server

Channels DVR Server is a flexible, standalone media server that lets you watch TV your way. This add-on allows you to run Channels DVR Server directly on your Home Assistant installation.

## Installation

1. Add this repository to your Home Assistant add-on store
2. Install the "Channels DVR Server" add-on
3. Start the add-on
4. Check the logs of the "Channels DVR Server" to see if everything went well
5. Click the "OPEN WEB UI" button to access the web interface
6. Follow the setup wizard to configure your TV sources (HDHomeRun, TVE, etc.)

## Configuration

This add-on requires minimal configuration and should work out of the box.

The web interface is available on port 8089.

## Storage

The add-on maps the following directories:
- `/share` - For storing recordings and data
- `/media` - For accessing media files

Your recordings will be stored in `/share/channels-dvr` by default.

### Using Network Storage (NAS)

To use a network share (NFS/SMB) for your recordings (e.g., from a NAS or another server):

1.  **Mount the storage in Home Assistant**:
    - Go to **Settings** > **System** > **Storage** in Home Assistant.
    - Click **Add Network Storage**.
    - Choose **NFS** (or SMB).
    - **Name**: Give it a name (e.g., `dvr`).
    - **Server**: Enter your IP (e.g., `192.168.2.5`).
    - **Remote Path**: Enter the path on the server (e.g., `/dvr`).
    - **Usage**: Select **Media** (recommended) or **Share**.
    - Click **Connect**.

2.  **Configure Channels DVR**:
    - Open the Channels DVR Web UI.
    - Go to **Settings**.
    - Under **DVR Database** or **Storage Paths**, uncheck "DVR" checkbox to add a new path.
    - Browse to `/media/dvr` (if you chose Usage: Media) or `/share/dvr` (if you chose Usage: Share).
    - Set this as your recording location.

## Features

- Watch and record live TV
- Electronic Program Guide (EPG)
- Hardware transcoding support (where available)
- Mobile apps for iOS and Android
- Web interface for management
- Support for HDHomeRun tuners
- TV Everywhere sources

## Known Limitations

- TV Everywhere sources require the `fancybits/channels-dvr:tve` Docker image
- Hardware transcoding availability depends on your Home Assistant host hardware

## Support

For issues with this add-on, please open an issue on the GitHub repository.

For Channels DVR Server specific support and documentation, visit:
- [GetChannels.com](https://getchannels.com)
- [Channels Community Forum](https://community.getchannels.com)

## License

MIT License

Copyright (c) 2025 mekenthompson
