#!/bin/bash

export XDG_RUNTIME_DIR=/run/user/$(id -u)
export WAYLAND_DISPLAY=wayland-0
export QT_QPA_PLATFORM=wayland

# 1. Multi-line parse to target and re-enable disabled physical displays
ENABLE_CMDS=$(kscreen-doctor -o | awk '
/^Output:/ {
    if (id && disabled && connected && !virtual) {
        print "output." id ".enable"
    }
    id = $2
    name = $3
    disabled = 0
    connected = 0
    virtual = (name ~ /Virtual/) ? 1 : 0
}
/^[[:space:]]+disabled$/ { disabled = 1 }
/^[[:space:]]+connected$/ { connected = 1 }
END {
    if (id && disabled && connected && !virtual) {
        print "output." id ".enable"
    }
}')

if [ -n "$ENABLE_CMDS" ]; then
    kscreen-doctor $ENABLE_CMDS
fi

# 2. Drop the virtual monitor process
pkill -f krfb-virtualmonitor
