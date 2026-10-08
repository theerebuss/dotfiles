#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

sudo apt-get update && sudo apt-get install -y zsh

if ! command -v brew &>/dev/null; then
	echo "Installing Homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || exit 1
fi

sudo chsh -s "$(command -v zsh)" "$(id -un)"

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
