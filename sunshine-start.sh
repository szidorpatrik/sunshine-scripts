#!/bin/bash

export XDG_RUNTIME_DIR=/run/user/$(id -u)
export WAYLAND_DISPLAY=wayland-0
export QT_QPA_PLATFORM=wayland

# 1. Spin up the virtual display exactly matching the client's dimensions natively
krfb-virtualmonitor --resolution ${SUNSHINE_CLIENT_WIDTH}x${SUNSHINE_CLIENT_HEIGHT} --name sunshine-vm --password pass --port 5905 & 
sleep 2

# 2. Only inject the custom mode if KWin doesn't already know about it
# We check for a mode matching the target width, height, and approximate refresh rate
MODE_EXISTS=$(kscreen-doctor -j | jq --arg w "${SUNSHINE_CLIENT_WIDTH}" --arg h "${SUNSHINE_CLIENT_HEIGHT}" --arg fps "${SUNSHINE_CLIENT_FPS}" '
  .outputs[] 
  | select(.name == "Virtual-sunshine-vm") 
  | .modes[] 
  | select(.width == ($w|tonumber) and .height == ($h|tonumber) and ((.refreshRate / 1000 | round) == ($fps|tonumber)))
')

if [ -z "$MODE_EXISTS" ]; then
    kscreen-doctor output.Virtual-sunshine-vm.addCustomMode.${SUNSHINE_CLIENT_WIDTH}.${SUNSHINE_CLIENT_HEIGHT}.${SUNSHINE_CLIENT_FPS}000.full
fi

# 3. Explicitly apply the resolution and refresh rate
kscreen-doctor output.Virtual-sunshine-vm.mode.${SUNSHINE_CLIENT_WIDTH}x${SUNSHINE_CLIENT_HEIGHT}@${SUNSHINE_CLIENT_FPS}

# 4. Apply the scaling factor to match the client's DPI settings
#kscreen-doctor output.Virtual-sunshine-vm.scale.1.25

# 5. Parse JSON to target active physical displays
DISABLE_CMDS=$(kscreen-doctor -j | jq -r '.outputs[] | select(.enabled == true and .connected == true and (.name | contains("Virtual") | not)) | "output." + .name + ".disable"')

if [ -n "$DISABLE_CMDS" ]; then 
    kscreen-doctor $DISABLE_CMDS 
fi
