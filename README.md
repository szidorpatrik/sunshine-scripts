# Wayland Virtual Display Automation for Sunshine & Moonlight

This repository contains automation scripts for setting up a headless, dynamic virtual display environment on **CachyOS (KDE Plasma Wayland)** using **Sunshine** and **Moonlight**.

The scripts automatically match the host's virtual monitor resolution and refresh rate to the connecting Moonlight client, disable physical monitors during the session to save power/prevent local viewing, and cleanly restore the physical layout upon disconnection.

---

## Features

* **Dynamic Resolution & FPS Matching:** Uses Sunshine environment variables (`SUNSHINE_CLIENT_WIDTH`, `SUNSHINE_CLIENT_HEIGHT`, `SUNSHINE_CLIENT_FPS`) to spin up an exact display match.
* **Automated Physical Monitor Toggling:** Disables physical monitors on connection and re-enables them on disconnection via a multi-line `kscreen-doctor` parser.
* **Headless Friendly:** Integrates with kernel-level EDID injection to allow full system boot and service initialization without any physical monitors attached.

---

## Prerequisites

Ensure the following packages are installed on your CachyOS system:

```bash
sudo pacman -S krfb kscreen sunshine

```

---

## Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/szidorpatrik/sunshine-scripts.git && cd sunshine-scripts
```

### 2. Install the Scripts

Copy the files manually in your local binaries directory:

```bash
mkdir -p ~/.local/bin && cp sunshine-start.sh sunshine-stop.sh ~/.local/bin/
```

Make them executable:

```bash
chmod +x ~/.local/bin/sunshine-start.sh ~/.local/bin/sunshine-stop.sh
```

### 3. Link Scripts in Sunshine Web UI

1. Open the Sunshine Configuration Web UI (`https://localhost:47990`).
2. Navigate to **Configuration** -> **General**.
3. Under **Command Preparations**, add the following paths:

* **DO COMMAND:** `/home/your_username/.local/bin/sunshine-start.sh`
* **UNDO COMMAND:** `/home/your_username/.local/bin/sunshine-stop.sh`

1. Navigate to **Configuration** -> **Advanced**.
2. Set **Force Capture Method** to `kwin`.
3. Click **Save** and restart Sunshine.
