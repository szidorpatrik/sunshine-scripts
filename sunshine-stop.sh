#!/bin/bash

export XDG_RUNTIME_DIR=/run/user/$(id -u)
export WAYLAND_DISPLAY=wayland-0
export QT_QPA_PLATFORM=wayland

# 1. Parse JSON to target and re-enable disabled physical displays
ENABLE_CMDS=$(kscreen-doctor -j | jq -r '.outputs[] | select(.enabled == false and .connected == true and (.name | contains("Virtual") | not)) | "output." + .name + ".enable"')

if [ -n "$ENABLE_CMDS" ]; then
    kscreen-doctor $ENABLE_CMDS
fi

# 2. Query the file to find the total historical backlog count
KWIN_CONFIG="$HOME/.config/kwinoutputconfig.json"
BACKLOG_COUNT=$(jq '[.[] | select(.name == "outputs") | .data[] | select(.connectorName == "Virtual-sunshine-vm") | .customModes[]] | length' "$KWIN_CONFIG" 2>/dev/null || echo 0)

# Add 1 to account for the mode injected during the current session
TOTAL_MODES_IN_MEMORY=$((BACKLOG_COUNT + 1))

# 3. Purge KWin's live memory buffer by stripping index 0 repeatedly
for ((i=0; i<TOTAL_MODES_IN_MEMORY; i++)); do
    kscreen-doctor output.Virtual-sunshine-vm.removeCustomMode.0 >/dev/null 2>&1
done

# 4. Drop the virtual monitor process (KWin flushes the clean state to disk now)
pkill -f krfb-virtualmonitor
