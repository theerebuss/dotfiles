#!/usr/bin/env bash
# Install Docker Engine (CE) on Ubuntu / WSL2 from Docker's apt repo, replacing Docker Desktop.
# https://docs.docker.com/engine/install/ubuntu/
set -euo pipefail

# Desktop's mount (/mnt/wsl/docker-desktop) is shared by every distro while the app runs,
# so look for the per-distro integration itself: its proxy process and bind mounts.
# The [d] stops pgrep from matching a shell whose command line quotes this pattern.
if pgrep -f '[d]ocker-desktop-user-distro|[d]ocker-desktop-proxy' >/dev/null ||
    [ -d "/mnt/wsl/docker-desktop-bind-mounts/${WSL_DISTRO_NAME:-}" ]; then
    echo "Docker Desktop's WSL integration is active for this distro."
    echo "Turn it off first (Docker Desktop > Settings > Resources > WSL integration),"
    echo "run 'wsl --shutdown' from Windows, reopen the distro and re-run this script."
    exit 1
fi

if grep -qi microsoft /proc/version && ! grep -qs 'systemd=true' /etc/wsl.conf; then
    echo "Enabling systemd in /etc/wsl.conf (Docker needs it)..."
    printf '[boot]\nsystemd=true\n' | sudo tee -a /etc/wsl.conf >/dev/null
    echo "Run 'wsl --shutdown' from Windows, reopen the distro and re-run this script."
    exit 1
fi

# Leftover symlink from Docker Desktop would shadow the apt package
if [ -L /usr/bin/docker ] && [ ! -e /usr/bin/docker ]; then
    sudo rm /usr/bin/docker
fi

if ! dpkg -s docker-ce &>/dev/null; then
    echo "Installing Docker Engine..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    codename="$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")"
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $codename stable" |
        sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

sudo usermod -aG docker "$(id -un)"
sudo systemctl enable --now docker

if command -v brew &>/dev/null && brew list --formula docker &>/dev/null; then
    echo "Note: Homebrew's docker CLI shadows /usr/bin/docker. Remove it with: brew uninstall docker"
fi

echo "Docker Engine is running. Open a new shell (or run 'newgrp docker') to use it without sudo."
