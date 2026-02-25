#!/bin/sh
# Official RustDesk setup: volumes map to /root, run from /root
# Ref: https://rustdesk.com/docs/en/self-host/rustdesk-server-pro/installscript/docker/

# Home Assistant maps config to /config, but RustDesk expects /root
# Only recreate symlink if needed (avoid unnecessary rm during normal restarts)
if [ -L /root ] && [ "$(readlink /root)" = "/config" ]; then
    echo "Persistent storage already linked (/root → /config)"
elif [ -d /root ] && [ ! -L /root ]; then
    # /root is a real directory (fresh container build) — replace with symlink
    rm -rf /root
    ln -s /config /root
    echo "Linked /root → /config"
else
    # Broken symlink or missing — recreate
    rm -f /root
    ln -s /config /root
    echo "Linked /root → /config"
fi

cd /root

# Verify key persistence
if [ -f id_ed25519 ]; then
    echo "Found existing keypair (id_ed25519)"
else
    echo "WARNING: No keypair found — hbbs will generate new keys on first start"
    echo "WARNING: Clients will need the new public key"
fi

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

# Start hbbs first (ID/rendezvous server — handles license check + client auth)
hbbs &
HBBS_PID=$!

# Wait for hbbs to be ready before starting relay (prevents clients hitting
# relay before the ID server can authenticate them)
echo "Waiting for hbbs to initialise..."
for i in $(seq 1 30); do
    if nc -z 127.0.0.1 21116 2>/dev/null; then
        echo "hbbs ready on :21116"
        break
    fi
    sleep 0.5
done

# Start hbbr (relay server)
hbbr &
HBBR_PID=$!

echo "RustDesk Server Pro running (hbbs=$HBBS_PID, hbbr=$HBBR_PID)"

# Wait for either process to exit — if one dies, stop the other
wait -n $HBBS_PID $HBBR_PID 2>/dev/null || wait $HBBS_PID
echo "A server process exited, shutting down..."
kill $HBBS_PID $HBBR_PID 2>/dev/null
wait
