# Agent Instructions - Claude Code Add-on

## Overview

This add-on runs Claude Code (Anthropic's CLI coding agent) inside a Home Assistant
container. It provides a web terminal via ttyd and runs `claude remote-control`
automatically at startup.

## Architecture

- **Base image**: `ghcr.io/hassio-addons/debian-base:7.3.3`
- **Supported architectures**: amd64, aarch64
- **Node.js**: v22 LTS (from NodeSource)
- **Web terminal**: ttyd
- **Process supervisor**: s6-overlay (standard for HA add-ons)

## Services (s6)

| Service | Type | Purpose |
|---------|------|---------|
| `init-claude-code` | oneshot | Sets env vars, validates workspace, runs init commands |
| `claude-code` | longrun | ttyd web terminal on port 7681 |
| `claude-remote` | longrun | `claude remote-control` background service |

## Key Design Decisions

- **ttyd for ingress**: ttyd natively supports `--base-path` which makes it work
  with HA ingress without needing nginx as a reverse proxy.
- **HA Network Storage**: Code directories are mounted via HA's built-in Network
  Storage feature (Settings > System > Storage). The add-on accesses them through
  the `/share` directory mapping (usage type: Share). No need for SYS_ADMIN or
  in-container NFS/CIFS mounts.
- **Persistent HOME**: Set to `/data/claude-code` so Claude Code config, auth
  tokens, and subscription login persist across container restarts.
- **Subscription auth**: Supports Claude Pro/Max subscription via `claude login`.
  The remote-control service polls for auth tokens and starts automatically once
  login completes.
- **HA API access**: Full admin access to both the Supervisor API and HA Core API
  via `SUPERVISOR_TOKEN`.

## Testing

```bash
# Build locally
cd claude-code && docker build -t test-claude-code .

# Quick smoke test (needs ANTHROPIC_API_KEY env var)
docker run --rm -it -e ANTHROPIC_API_KEY=sk-ant-... test-claude-code claude --version
```

## Updating Claude Code

Claude Code is installed via `npm install -g @anthropic-ai/claude-code` in the
Dockerfile. To pin a specific version, change it to:
```dockerfile
RUN npm install -g @anthropic-ai/claude-code@1.0.0
```

Bump the version in `config.yaml` when updating.
