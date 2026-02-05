# Minecraft Bedrock Server

Run a Minecraft Bedrock Dedicated Server on your Home Assistant installation for local multiplayer gaming.

## About

This add-on provides a Minecraft Bedrock Dedicated Server that runs on your Home Assistant OS. Perfect for family LAN gaming — kids can find and join the server automatically on the local network.

## Installation

1. Add this repository to your Home Assistant add-on store
2. Install the "Minecraft Bedrock Server" add-on
3. Configure the add-on (see Configuration section)
4. Start the add-on

## Configuration

The add-on can be configured through the Home Assistant UI. Here are the available options:

### Option: `server_name`

The name of your Minecraft server (shown in the server list).

**Default:** `"Thompson Family Server"`

### Option: `gamemode`

Default game mode for players.

**Options:** `survival`, `creative`, `adventure`  
**Default:** `survival`

### Option: `difficulty`

Difficulty level for the game.

**Options:** `peaceful`, `easy`, `normal`, `hard`  
**Default:** `normal`

### Option: `max_players`

Maximum number of players that can connect simultaneously.

**Range:** 1-20  
**Default:** `10`

### Option: `allow_cheats`

Whether to allow cheat commands in the game.

**Default:** `false`

### Option: `view_distance`

The maximum view distance in chunks (higher values require more resources).

**Range:** 5-48  
**Default:** `32`

### Option: `level_name`

The name of your world save file.

**Default:** `"FamilyWorld"`

### Option: `level_seed`

Optional seed for world generation. Leave empty for random world.

**Default:** (empty)

### Option: `online_mode`

Requires Xbox Live authentication. Set to `false` for truly local-only play.

**Default:** `true`

### Option: `white_list`

Enable whitelist mode (only specified players can join).

**Default:** `false`

### Option: `server_port`

UDP port for the server.

**Default:** `19132`

## How to Connect

### On the Local Network

1. Open Minecraft Bedrock Edition (Windows 10/11, iOS, Android, Xbox, PlayStation, Nintendo Switch)
2. Go to the **Friends** tab
3. The server should appear automatically in the "LAN Games" section
4. Click to join!

### If Server Doesn't Appear Automatically

1. Go to the **Servers** tab
2. Click **Add Server**
3. Enter:
   - **Server Name:** Whatever you want
   - **Server Address:** Your Home Assistant IP address
   - **Port:** `19132` (or whatever you configured)
4. Save and connect

## World Data and Backups

Your Minecraft world data is stored persistently in:

```
/share/minecraft/
```

This directory is accessible through the Home Assistant file share (Samba/SMB).

### To Back Up Your World

1. Stop the Minecraft Bedrock Server add-on
2. Copy the `/share/minecraft/worlds/` folder to a safe location
3. Restart the add-on when done

### To Restore a World

1. Stop the add-on
2. Replace the world folder in `/share/minecraft/worlds/`
3. Update the `level_name` option to match the world folder name
4. Start the add-on

## Server Management

- **Logs:** Check the add-on logs in Home Assistant to see server status and player connections
- **Restart:** Stop and start the add-on to restart the server
- **Updates:** The server binary auto-updates to the latest Bedrock version on add-on restart

## Troubleshooting

### Players can't connect

- Verify the add-on is running (check logs)
- Make sure players are on the same Wi-Fi/network
- Check that UDP port 19132 isn't blocked by your router
- Try connecting manually using the Home Assistant IP address

### World won't load

- Check the `level_name` matches the actual folder name in `/share/minecraft/worlds/`
- Check add-on logs for errors
- Verify `/share/minecraft` directory permissions

### Performance issues

- Lower `view_distance` setting
- Reduce `max_players`
- Consider running on more powerful hardware

## Technical Details

- **Base:** [itzg/minecraft-bedrock-server](https://github.com/itzg/docker-minecraft-bedrock-server)
- **Process Manager:** s6-overlay
- **Networking:** Host network mode for LAN discovery
- **Auto-updates:** Server binary updates automatically on container restart

## Support

- [Report issues](https://github.com/mekenthompson/hassio-addons/issues)
- [Home Assistant Community](https://community.home-assistant.io/)

## License

This add-on is provided as-is. Minecraft is a trademark of Microsoft/Mojang.
