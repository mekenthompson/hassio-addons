# RustDesk Server Pro - Home Assistant Add-on

[![Donate](https://img.shields.io/badge/donate-Coffee-yellow.svg)](https://www.example.com)

Run your own private RustDesk remote desktop server! This add-on provides a self-hosted alternative to TeamViewer, AnyDesk, and other commercial remote desktop solutions.

## About

[RustDesk](https://rustdesk.com/) is an open-source remote desktop application. This add-on runs the **Pro version** of the RustDesk server with advanced features including:

- Web-based admin console
- Multiple concurrent connections
- Better performance and reliability
- Address book and device management

## Quick Start

### 1️⃣ Installation

1. Install this add-on from the Home Assistant Add-on Store
2. Click **START** to run the add-on
3. Check the **Log** tab to verify both services started successfully

### 2️⃣ Get Your License

🔑 **You need a RustDesk Pro license to use this server.**

- Purchase from [RustDesk](https://rustdesk.com/pricing.html)
- Or request a trial license
- License files will be placed in your `/addon_configs/[addon-slug]_rustdesk-server-pro/` directory

### 3️⃣ Access Web Console

Once started, access the admin console at:
```
http://YOUR_HOME_ASSISTANT_IP:21114
```

**Default credentials:**
- Username: `admin`
- Password: `test1234`

⚠️ **Change the default password immediately after first login!**

### 4️⃣ Configure RustDesk Clients

On each device you want to control remotely:

1. Download [RustDesk client](https://rustdesk.com/download)
2. Open RustDesk, click the menu (⋮) next to "Ready"
3. Select **ID/Relay Server**
4. Enter your settings:
   - **ID Server**: `YOUR_HOME_ASSISTANT_IP:21116` or your domain
   - **Relay Server**: `YOUR_HOME_ASSISTANT_IP:21117` or your domain
   - **API Server**: `http://YOUR_HOME_ASSISTANT_IP:21114` (for Pro features)
   - **Key**: Found in logs or `/addon_configs/[slug]_rustdesk-server-pro/id_ed25519.pub`
5. Click **OK**

### 5️⃣ Start Using RustDesk

- Each device will get a unique ID
- Share your device ID with others to allow remote access
- Or use the ID to connect to your own devices remotely

## Configuration

This add-on works out of the box with no configuration required. All data persists in the `/data` directory mapped to your Home Assistant config.

## Ports Used

| Port | Protocol | Purpose |
|------|----------|---------|
| 21114 | TCP | API Server |
| 21115 | TCP | NAT type test |
| 21116 | TCP/UDP | ID registration & heartbeat |
| 21117 | TCP | Relay services |
| 21118 | TCP | Web admin console |
| 21119 | TCP | Web admin console support |

**⚠️ Important:** This add-on uses host networking (`host_network: true`) which is required for RustDesk Pro licensing to function.

## Firewall Configuration

If accessing from outside your network, forward these ports on your router:
- **21116** (TCP & UDP) - Required for client connections
- **21117** (TCP) - Required for relay
- **21118** (TCP) - Optional, for web console access

## Finding Your Public Key

The server's public key is needed by clients for secure connections:

1. Check the add-on **Log** tab after first start - the key will be displayed
2. Or access it via File Editor add-on at `/addon_configs/[slug]/id_ed25519.pub`
3. Or use SSH/Terminal to read the file

## Troubleshooting

**Clients can't connect:**
- Verify ports 21116 and 21117 are accessible
- Check firewall rules on your router/network
- Ensure you entered the correct server IP/domain in clients

**License issues:**
- Verify license files are in the data directory
- Check logs for license-related errors
- Ensure host networking is enabled (required for licensing)

**Web console not accessible:**
- Confirm add-on is running (check logs)
- Try `http://homeassistant.local:21118`
- Check if port 21118 is blocked by firewall

## Support

- **Add-on Issues**: Open a GitHub issue
- **RustDesk Help**: [Official Documentation](https://rustdesk.com/docs/)
- **Community**: [RustDesk Discord](https://discord.com/invite/nDceKgxnkV)
