#!/usr/bin/env bash
# Bootstrap: clone (or update) the dotfiles repo. Run via:
#   curl -fsSL https://raw.githubusercontent.com/theerebuss/dotfiles/refs/heads/main/pull.sh | bash
set -euo pipefail

repo="https://github.com/theerebuss/dotfiles.git"
target="${DOTFILES:-$HOME/workspace/dotfiles}"

# git is the only prerequisite
if [ "$(uname)" = "Darwin" ] && ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode command line tools..."
    xcode-select --install &>/dev/null || true
    until xcode-select -p &>/dev/null; do sleep 5; done
elif ! command -v git &>/dev/null; then
    echo "Installing git..."
    sudo apt-get update && sudo apt-get install -y git
fi

if [ -d "$target/.git" ]; then
    echo "Updating $target..."
    git -C "$target" pull --ff-only
else
    mkdir -p "$(dirname "$target")"
    git clone "$repo" "$target"
fi

echo
echo "Next: cd $target && ./.macos.sh   # or ./.wsl.sh"
