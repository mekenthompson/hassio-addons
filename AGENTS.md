# Agent Instructions - Home Assistant Add-ons Repository

## Repository Overview

This is a multi-addon Home Assistant repository containing several add-ons. Home Assistant discovers add-ons by scanning subdirectories for `config.yaml` files.

## Repository Structure

```
hassio-addons/
├── repository.json          # Repository metadata (name, maintainer, URL)
├── README.md                 # User-facing documentation
├── AGENTS.md                 # This file
├── channels-dvr/             # Channels DVR Server add-on
├── coder/                    # VS Code Server add-on
└── rustdesk-server-pro/      # RustDesk Server Pro add-on
```

## Add-on Structure

Each add-on subdirectory follows the Home Assistant add-on specification:

| File | Purpose |
|------|---------|
| `config.yaml` | Add-on metadata, ports, options, schema (REQUIRED) |
| `Dockerfile` | Container build instructions (REQUIRED) |
| `build.yaml` | Build configuration, base images per architecture |
| `DOCS.md` | Detailed documentation (shown in HA UI) |
| `README.md` | Quick overview and installation |
| `CHANGELOG.md` | Version history |
| `icon.png` | Add-on icon (512x512) |
| `logo.png` | Add-on logo (optional) |
| `rootfs/` | Files copied into container |
| `translations/` | UI translations |

## Critical Fields

### config.yaml
- **slug**: Unique identifier - NEVER change after release (breaks user data)
- **version**: Semantic versioning (update for every change)
- **url**: Must point to `https://github.com/mekenthompson/hassio-addons`
- **arch**: Supported architectures (aarch64, amd64, armv7, armhf)

### repository.json
- Located at repo root
- Defines repository name and maintainer
- Home Assistant reads this to display repo info

## Development & Release Workflow

1. **Make changes** in the relevant add-on directory
2. **Update version** in `<addon>/config.yaml` (use SemVer)
3. **Update changelog** in `<addon>/CHANGELOG.md`
4. **Test locally** if possible (see add-on AGENTS.md)
5. **Commit and push** to trigger updates for users

## Data Preservation

Add-on data is stored based on `slug`, not repository URL:
- `channels-dvr` → `/addon_configs/channels-dvr/`
- `coder` → `/addon_configs/coder/`
- `rustdesk-server-pro` → `/addon_configs/rustdesk-server-pro/`

Users can switch from individual repos to this consolidated repo without losing data.

## Common Commands

```bash
# Verify slugs haven't changed
grep "^slug:" */config.yaml

# Check all versions
grep "^version:" */config.yaml

# Validate YAML syntax
yamllint */config.yaml

# Test Docker build (example for coder)
cd coder && docker build -t test-coder .
```

## Adding a New Add-on

1. Create new directory: `new-addon/`
2. Add required files: `config.yaml`, `Dockerfile`
3. Add documentation: `README.md`, `DOCS.md`, `CHANGELOG.md`
4. Add assets: `icon.png` (512x512)
5. Create `AGENTS.md` with add-on specific guidance
6. Update root `README.md` to list new add-on
7. Commit and push

## Sub-directory Guidance

See `AGENTS.md` in each add-on directory for add-on specific:
- Build/test instructions
- Architecture-specific notes
- Service management (s6-overlay, etc.)
- Configuration options
