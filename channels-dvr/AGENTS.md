# Agent Instructions - Channels DVR Add-on

## Add-on Overview

Channels DVR Server add-on for Home Assistant. Runs the official Channels DVR Server for watching and recording live TV.

## Key Files

| File | Purpose |
|------|---------|
| `config.yaml` | Add-on metadata, ports (8089), storage mappings |
| `Dockerfile` | Builds from `fancybits/channels-dvr` base image |
| `build.yaml` | Architecture-specific base images |
| `rootfs/etc/services.d/` | s6 service scripts |

## Architecture

- **Base Image**: `fancybits/channels-dvr:latest` (or `:tve` for TV Everywhere)
- **Service Manager**: s6-overlay
- **Port**: 8089 (web UI)
- **Storage**: `/share` and `/media` mapped for recordings

## Configuration Details

```yaml
slug: channels-dvr          # DO NOT CHANGE - breaks user data
host_network: true          # Required for tuner discovery
ports:
  8089/tcp: 8089           # Web UI
map:
  - share:rw               # Recordings storage
  - media:rw               # Media access
```

## Development & Testing

```bash
# Build locally
docker build -t channels-dvr-test .

# Run with test storage
docker run -p 8089:8089 -v $(pwd)/test-data:/share channels-dvr-test
```

## Version Updates

1. Update `version` in `config.yaml` (SemVer: MAJOR.MINOR.PATCH)
2. Add entry to `CHANGELOG.md`
3. Commit with message: `channels-dvr: vX.Y.Z - description`

## Common Issues

- **Tuner not found**: Ensure `host_network: true` is set
- **TVE not working**: May need `:tve` Docker image variant
- **Storage issues**: Check `/share` permissions
