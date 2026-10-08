#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# fish 4 from the fish team's PPA (Ubuntu's own package is 3.7). zsh stays as a fallback.
sudo add-apt-repository -y ppa:fish-shell/release-4
sudo apt-get install -y fish zsh

if [ ! -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
	echo "Installing Homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || exit 1
fi
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew install starship

sudo chsh -s /usr/bin/fish "$(id -un)"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

if ! command -v gh &>/dev/null; then
	# https://github.com/cli/cli/blob/trunk/docs/install_linux.md
	sudo apt-get install -y wget
	sudo mkdir -p -m 755 /etc/apt/keyrings
	wget -nv -O- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
	sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
	sudo apt-get update && sudo apt-get install -y gh
fi

gh auth status &>/dev/null || gh auth login -s user

if [ ! -f "$HOME/.ssh/github_ed25519" ]; then
	./scripts/setup_git.sh
fi

./scripts/install.sh

# Docker Engine instead of Docker Desktop
./scripts/setup_docker.sh
