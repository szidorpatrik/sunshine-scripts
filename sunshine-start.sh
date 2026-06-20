#!/bin/bash

export XDG_RUNTIME_DIR=/run/user/$(id -u)
export WAYLAND_DISPLAY=wayland-0
export QT_QPA_PLATFORM=wayland

# 1. Spin up the virtual display exactly matching the client's dimensions natively
krfb-virtualmonitor --resolution ${SUNSHINE_CLIENT_WIDTH}x${SUNSHINE_CLIENT_HEIGHT} --name sunshine-vm --password pass --port 5905 & 
sleep 2

# 2. Inject the custom refresh rate timing (converts Hz to mHz: e.g., 60 -> 60000)
kscreen-doctor output.Virtual-sunshine-vm.addCustomMode.${SUNSHINE_CLIENT_WIDTH}.${SUNSHINE_CLIENT_HEIGHT}.${SUNSHINE_CLIENT_FPS}000.full

# 3. Explicitly apply the injected resolution and refresh rate
kscreen-doctor output.Virtual-sunshine-vm.mode.${SUNSHINE_CLIENT_WIDTH}x${SUNSHINE_CLIENT_HEIGHT}@${SUNSHINE_CLIENT_FPS}

# 4. Apply the scaling factor to match the client's DPI settings
#kscreen-doctor output.Virtual-sunshine-vm.scale.1.25

# 5. Multi-line parse to target active physical displays
DISABLE_CMDS=$(kscreen-doctor -o | awk '
/^Output:/ {
    if (id && enabled && connected && !virtual) {
        print "output." id ".disable"
    }
    id = $2
    name = $3
    enabled = 0
    connected = 0
    virtual = (name ~ /Virtual/) ? 1 : 0
}
/^[[:space:]]+enabled$/ { enabled = 1 }
/^[[:space:]]+connected$/ { connected = 1 }
END {
    if (id && enabled && connected && !virtual) {
        print "output." id ".disable"
    }
}')

if [ -n "$DISABLE_CMDS" ]; then 
    kscreen-doctor $DISABLE_CMDS 
fi
