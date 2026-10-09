#!/bin/bash
exec > >(tee -i $HOME/dotfiles_install.log)
exec 2>&1
set -euxo pipefail

echo "Start install dotfiles as $(id -un)"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Symlink so edits made on the machine land in the repo. Plain files get a .bak.
link() {
    [ -f "$2" ] && [ ! -L "$2" ] && mv "$2" "$2.bak"
    ln -sfn "$1" "$2"
}
mkdir -p "$HOME/.config/fish/conf.d"
link "$REPO_DIR/configs/fish/config.fish" "$HOME/.config/fish/config.fish"
link "$REPO_DIR/configs/starship.toml" "$HOME/.config/starship.toml"
mkdir -p "$HOME/.config/fish/themes"
link "$REPO_DIR/configs/fish/themes/fisheries.theme" "$HOME/.config/fish/themes/fisheries.theme"

if [ "${CODESPACES:-}" = true ] && [ -z "${CODESPACE_DISPLAYNAME:-}" ]; then
    codespaces=$(gh codespace list)
    codespace_name=$(echo "$codespaces" | awk '{print $1, $2}' | grep "$CODESPACE_NAME" | awk '{print $2}')
    echo "set -gx CODESPACE_DISPLAYNAME ${codespace_name}" >>~/.config/fish/conf.d/local.fish
fi

# gh extensions need a logged-in gh; skip them otherwise (e.g. a non-root user on the Pi)
if gh auth status >/dev/null 2>&1; then
    gh_ext() { gh extension list 2>/dev/null | grep -q "$1" || gh extension install "$1"; }
    gh_ext rneatherway/gh-slack # Fetch Slack threads
    gh_ext seachicken/gh-poi    # Delete merged branches
fi
