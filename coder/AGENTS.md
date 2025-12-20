# Agent Instructions - VS Code Server Add-on

## Add-on Overview

VS Code Server (code-server) add-on for Home Assistant. Provides a full VS Code experience in the browser for editing Home Assistant configuration.

## Key Files

| File | Purpose |
|------|---------|
| `config.yaml` | Add-on metadata, ingress config, options schema |
| `Dockerfile` | Installs code-server using official install script |
| `build.yaml` | Base images per architecture (amd64, aarch64) |
| `rootfs/etc/s6-overlay/s6-rc.d/` | s6-rc service definitions |

## Architecture

- **Base Image**: `ghcr.io/hassio-addons/base` (Debian-based)
- **Service Manager**: s6-overlay v3 (s6-rc)
- **Port**: 8080 (internal, exposed via Ingress)
- **code-server Version**: 4.107.0 (pinned for stability)

## s6-overlay Service Structure

```
rootfs/etc/s6-overlay/s6-rc.d/
├── init-coder/           # Initialization (oneshot)
│   ├── type              # "oneshot"
│   ├── up                # Points to run script
│   ├── run               # Initialization script
│   └── dependencies.d/base
├── coder/                # Main service (longrun)
│   ├── type              # "longrun"
│   ├── run               # Starts code-server
│   ├── finish            # Cleanup on exit
│   └── dependencies.d/init-coder
└── user/contents.d/      # Service registration
    ├── init-coder
    └── coder
```

## Configuration Schema

```yaml
options:
  password: ""              # Empty = use Ingress auth
  default_workspace: /homeassistant
  init_commands: []         # Shell commands on startup
  log_level: info
```

## Development & Testing

```bash
# Build locally
docker build -t coder-test .

# Run with test config
docker run -p 8080:8080 coder-test
```

## Version Updates

1. Update `version` in `config.yaml`
2. Update code-server version in `Dockerfile` if changing
3. Update version table in `DOCS.md`
4. Add entry to `CHANGELOG.md`
5. Commit: `coder: vX.Y.Z - description`

## Scripts Convention

- Shebang: `#!/command/with-contenv bashio`
- Use `bashio::` functions for logging and config
- Config access: `bashio::config 'option_name'`
- Logging: `bashio::log.info "message"`

## Common Issues

- **Extensions fail on ARM**: Some extensions need x86 binaries
- **Slow startup**: Large workspaces take time to index
- **Auth issues**: Check Ingress vs password configuration
