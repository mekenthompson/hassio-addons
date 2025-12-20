# RustDesk Server Pro Add-on - Complete Setup Guide

This guide walks you through setting up your own private RustDesk server for remote desktop access.

## What is RustDesk?

RustDesk is an open-source remote desktop application similar to TeamViewer or AnyDesk. By running your own server, you get:

- **Privacy**: All connections route through YOUR server
- **No limits**: Unlimited devices and connections
- **Control**: Full control over your remote access infrastructure
- **Security**: Your data stays on your network

## Prerequisites

Before you begin, ensure you have:

- ✅ Home Assistant installed and running
- ✅ Static IP address or DDNS for your Home Assistant server (if accessing remotely)
- ✅ RustDesk Pro license (required for this Pro version)

## Step-by-Step Setup

### Step 1: Install the Add-on

1. Navigate to **Settings** → **Add-ons** → **Add-on Store**
2. Find "RustDesk Server Pro" in the list
3. Click on it and press **INSTALL**
4. Wait for the installation to complete

### Step 2: Start the Server

1. After installation, click **START**
2. Enable **Start on boot** if you want it to run automatically
3. Enable **Watchdog** to auto-restart if it crashes
4. Click on the **Log** tab and verify you see:
   ```
   Starting RustDesk Server Pro...
   Starting hbbr service...
   Starting hbbs service...
   ```

### Step 3: Obtain Your Server's Public Key

The public key is used by clients to verify they're connecting to your server.

**Method 1: From Logs**
1. Go to the **Log** tab
2. Look for a line containing the public key (long string of characters)
3. Copy this key - you'll need it for client configuration

**Method 2: From File System**
1. Install the "File Editor" add-on if you haven't already
2. Navigate to `/addon_configs/[slug]_rustdesk-server-pro/`
3. Open the file `id_ed25519.pub`
4. Copy the contents

**Save this key somewhere safe - you'll need it for every client!**

### Step 4: Get Your RustDesk Pro License

1. Visit [RustDesk Pricing](https://rustdesk.com/pricing.html)
2. Purchase a Pro license or request a trial
3. Download the license files provided
4. Place them in the add-on's data directory:
   - Use File Editor add-on to upload to `/addon_configs/[slug]_rustdesk-server-pro/`
   - Or use Samba/SSH to copy files
5. Restart the add-on after adding license files

### Step 5: Access the Web Console (Optional)

The web console allows you to manage your RustDesk server:

1. Open your browser
2. Navigate to: `http://YOUR_HOME_ASSISTANT_IP:21118`
   - Example: `http://192.168.1.100:21118`
   - Or: `http://homeassistant.local:21118`
3. Log in with credentials from your license documentation
4. You can now manage devices, view connections, and configure settings

### Step 6: Configure Your First Client

On the computer/device you want to access remotely:

#### Download RustDesk Client

1. Go to [rustdesk.com/download](https://rustdesk.com/download)
2. Download for your platform (Windows, macOS, Linux, Android, iOS)
3. Install and open RustDesk

#### Configure Server Settings

1. In RustDesk, click the **three dots menu** (⋮) next to "Ready"
2. Select **ID/Relay Server**
3. Click **Unlock Network Settings** (padlock icon)
4. Enter your server details:

   **ID Server:**
   ```
   YOUR_HOME_ASSISTANT_IP:21116
   ```
   
   **Relay Server:**
   ```
   YOUR_HOME_ASSISTANT_IP:21117
   ```
   
   **API Server:**
   ```
   http://YOUR_HOME_ASSISTANT_IP:21114
   ```
   
   **Key:** (paste the public key from Step 3)

5. Click **OK** to save

#### Verify Connection

1. RustDesk should now show "Ready" status
2. Note the **ID number** displayed (e.g., 123 456 789)
3. This ID is how others will connect to this device

### Step 7: Connect to a Remote Device

To control another device:

1. On your local device, open RustDesk
2. Enter the **remote device's ID** in the text field
3. Click **Connect**
4. Accept the connection on the remote device (first time)
5. You're now controlling the remote device!

## Advanced Configuration

### Setting Up Domain Name (Recommended)

Instead of using IP addresses, use a domain name:

1. Set up DDNS (DuckDNS, No-IP, etc.) pointing to your public IP
2. In client configuration, use:
   - ID Server: `your-domain.com:21116`
   - Relay Server: `your-domain.com:21117`
   - API Server: `http://your-domain.com:21114`

### Port Forwarding for Remote Access

To access your devices from outside your home network:

1. Log into your router's admin panel
2. Set up port forwarding rules:
   - Forward **21116** (TCP & UDP) → Your Home Assistant IP
   - Forward **21117** (TCP) → Your Home Assistant IP
   - Optionally forward **21118** (TCP) for web console
3. Use your public IP or domain in client configurations

### Using SSL/TLS (Secure Connections)

For production use, consider:

1. Setting up a reverse proxy (Nginx Proxy Manager, Caddy)
2. Getting SSL certificates (Let's Encrypt)
3. Routing RustDesk traffic through the proxy

See RustDesk documentation for SSL configuration details.

## Network Architecture

```
[RustDesk Client] 
    ↓ (ID Registration/Heartbeat)
    ↓ Port 21116
    ↓
[Your Home Assistant] → [RustDesk Server Add-on]
    ↑                          ↓
    ↑ (Relay Traffic)          ↓ (Web Console)
    ↑ Port 21117               ↓ Port 21118
    ↑
[Another RustDesk Client]
```

## Common Issues & Solutions

### Issue: Clients show "Connection failed"

**Solutions:**
- Verify the add-on is running (check Logs)
- Confirm correct IP address in client settings
- Check firewall isn't blocking ports 21116-21117
- Ensure you copied the full public key correctly

### Issue: "Invalid license" error in logs

**Solutions:**
- Verify license files are in `/addon_configs/[slug]/` directory
- Ensure license is valid and not expired
- Restart the add-on after adding license
- Contact RustDesk support for license issues

### Issue: Web console not loading

**Solutions:**
- Try `http://` instead of `https://`
- Use IP address instead of hostname
- Check if port 21118 is accessible
- Look for errors in add-on logs

### Issue: Connection works locally but not remotely

**Solutions:**
- Verify port forwarding is configured correctly
- Check your public IP address hasn't changed
- Ensure DDNS is updating if you use it
- Test ports with online port checker tools

## Performance Tips

- **Network Speed**: RustDesk works best with at least 5 Mbps upload speed
- **Codec Settings**: H.264 provides better quality, VP9 better compression
- **Direct Connections**: When possible, use direct IP mode for better performance
- **Relay Usage**: Relay server is used when direct connection fails

## Security Best Practices

1. **Change Default Passwords**: If web console has defaults, change them immediately
2. **Use Strong Keys**: Never share your private key (`id_ed25519`)
3. **Limit Access**: Only forward ports if you need remote access
4. **Update Regularly**: Keep both server and clients updated
5. **Monitor Logs**: Regularly check add-on logs for suspicious activity
6. **Use 2FA**: Enable two-factor authentication if available in Pro version

## Backup & Recovery

### Backing Up Your Configuration

Important files to backup (in `/addon_configs/[slug]/`):
- `id_ed25519` (private key)
- `id_ed25519.pub` (public key)
- License files
- Any configuration files

### Restoring

1. Reinstall the add-on
2. Stop the add-on
3. Copy backed-up files to `/addon_configs/[slug]/`
4. Start the add-on
5. Clients should reconnect automatically

## Getting Help

- **Add-on Bugs**: Report on GitHub repository
- **RustDesk Questions**: [RustDesk Docs](https://rustdesk.com/docs/)
- **Community Support**: [RustDesk Discord](https://discord.com/invite/nDceKgxnkV)
- **License Issues**: Contact RustDesk support directly

## Frequently Asked Questions

**Q: Do I need RustDesk Pro license?**  
A: Yes, this add-on runs RustDesk Server Pro which requires a paid license.

**Q: Can I use this with the free RustDesk version?**  
A: No, this is specifically for the Pro version. Use the standard RustDesk server for free tier.

**Q: How many devices can I connect?**  
A: Depends on your license tier and server resources.

**Q: Does this work over the internet?**  
A: Yes, with proper port forwarding and DDNS/static IP configuration.

**Q: Is my data encrypted?**  
A: Yes, RustDesk uses end-to-end encryption for all connections.

**Q: Can I use this commercially?**  
A: Check your RustDesk Pro license terms for commercial use rights.

---

**Need more help?** Check the [official RustDesk documentation](https://rustdesk.com/docs/) or ask in the [community forums](https://github.com/rustdesk/rustdesk/discussions).
