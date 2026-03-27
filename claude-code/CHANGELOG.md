# Changelog

## 1.0.3

- Fix remote-control crash loop: auto-accept interactive prompt

## 1.0.2

- Add GitHub CLI (gh) with persistent auth across restarts

## 1.0.1

- Fix ingress 404: remove ttyd `--base-path` (HA ingress strips the prefix)
- Fix s6 script permissions in Dockerfile
- Change sidebar icon to `mdi:creation` (sparkle)
- Add addon icon

## 1.0.0

- Initial release
- Claude Code CLI installed via npm
- Web terminal via ttyd accessible through HA ingress
- Automatic `claude remote-control` at startup
- Claude Pro/Max subscription support via `claude login`
- API key authentication as alternative
- HA Network Storage integration for code directories (NFS/SMB)
- Full Home Assistant API and admin access
- Persistent auth tokens and config across restarts
