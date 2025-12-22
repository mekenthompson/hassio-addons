# Changelog

## 1.0.13

- Change: Move server data to /media/dvr/channels-dvr-server/ for persistence alongside recordings/backups

## 1.0.12

- Fix: Move database to /share/channels-dvr/server/ to persist across reinstalls

## 1.0.11

- Fix: Ensure /media/dvr directory exists for recordings

## 1.0.10

- Fix: Persist entire channels-dvr installation to /data to support self-updates and state persistence

## 1.0.9

- Fix: Use /data directory for persistent configuration storage

## 1.0.8

- Fix: Remove empty rootfs COPY causing build failure

## 1.0.7


- Fix: Revert webui format to satisfy regex validation

## 1.0.6


- Fix: Align config with RustDesk example (host_network=true, options={}, schema={})

## 1.0.5


- Fix: Revert config to known visible state (remove host_network, use schema: false)

## 1.0.4


- Fix: Add logo.png and update URL to match repository root

## 1.0.3


- Fix: Update S6 shebang to /command/with-contenv for Debian Bookworm base

## 1.0.2


- Fix permissions issue on startup
- Fix installation path for Channels DVR binary

## 1.0.1


- Initial release
