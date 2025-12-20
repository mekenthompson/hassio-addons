#!/bin/sh
# Official RustDesk setup: volumes map to /root, run from /root
# Ref: https://rustdesk.com/docs/en/self-host/rustdesk-server-pro/installscript/docker/

# Home Assistant maps config to /config, but RustDesk expects /root
# Mount /config as /root for data persistence
if [ ! -L /root ] || [ "$(readlink /root)" != "/config" ]; then
    rm -rf /root
    ln -s /config /root
fi

cd /root

# Read configuration from Home Assistant
CONFIG_PATH=/data/options.json

# Check if always_use_relay is enabled
if [ -f "$CONFIG_PATH" ]; then
    ALWAYS_RELAY=$(grep -o '"always_use_relay"[[:space:]]*:[[:space:]]*true' "$CONFIG_PATH" || echo "")
    if [ -n "$ALWAYS_RELAY" ]; then
        export ALWAYS_USE_RELAY=Y
        echo "ALWAYS_USE_RELAY enabled"
    fi
fi

# Start hbbr in background (as per official docker-compose)
hbbr &

# Start hbbs in foreground (as per official docker-compose)
hbbs
