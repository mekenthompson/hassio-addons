# Agent Instructions - RustDesk Server Pro Add-on

## Add-on Overview

RustDesk Server Pro add-on for Home Assistant. Provides a self-hosted remote desktop server as an alternative to TeamViewer/AnyDesk.

## Key Files

| File | Purpose |
|------|---------|
| `config.yaml` | Add-on metadata, ports (21114-21119), host networking |
| `Dockerfile` | Based on `rustdesk/rustdesk-server-pro:latest` |
| `run.sh` | Entrypoint script starting hbbs and hbbr services |

## Architecture

- **Base Image**: `rustdesk/rustdesk-server-pro:latest`
- **Services**: hbbs (ID server), hbbr (relay server)
- **Networking**: Host mode (required for licensing)
- **Data Storage**: `/config` mapped to `addon_config`

## Port Configuration

| Port | Protocol | Purpose |
|------|----------|---------|
| 21114 | TCP | API Server |
| 21115 | TCP | NAT type test |
| 21116 | TCP/UDP | ID registration & heartbeat |
| 21117 | TCP | Relay services |
| 21118 | TCP | Web admin console |
| 21119 | TCP | Web console support |

## Critical Configuration

```yaml
slug: rustdesk-server-pro   # DO NOT CHANGE - breaks user data
host_network: true          # REQUIRED for licensing - do not remove
map:
  - config:rw               # License and key storage
```

## Development & Testing

```bash
# Build locally
docker build -t rustdesk-test .

# Run with host networking (required for licensing)
docker run --network host -v $(pwd)/test-data:/config rustdesk-test
```

## Version Updates

1. Update `version` in `config.yaml` (SemVer)
2. Add entry to `CHANGELOG.md` with date and category
3. Commit: `rustdesk-server-pro: vX.Y.Z - description`

## run.sh Script

The entrypoint script:
1. Starts hbbr (relay) in background
2. Starts hbbs (ID server) in foreground
3. Uses `/config` for persistent data
4. Logs public key for user convenience

## Common Issues

- **Licensing fails**: Ensure `host_network: true` is set
- **Clients can't connect**: Check ports 21116-21117 are forwarded
- **Web console inaccessible**: Try port 21118, check firewall
- **Keys missing**: Check `/addon_configs/rustdesk-server-pro/` for id_ed25519.pub

## Data Persistence

License files and keys stored in `/config`:
- `id_ed25519` - Private key (keep secure)
- `id_ed25519.pub` - Public key (share with clients)
- License files from RustDesk
