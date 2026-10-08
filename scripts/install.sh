#!/bin/bash
exec > >(tee -i $HOME/dotfiles_install.log)
exec 2>&1
set -x

echo "Start install dotfiles as $USERNAME"
CURR_DIR=$(pwd)

echo "Download zsh plugins"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
clone() { [ -d "$2" ] || git clone --depth=1 "$1" "$2"; }
clone https://github.com/agkozak/zsh-z "$ZSH_CUSTOM/plugins/zsh-z"
clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone https://github.com/romkatv/powerlevel10k "$ZSH_CUSTOM/themes/powerlevel10k"

cp -f $CURR_DIR/configs/.zshrc $HOME/.zshrc
cp -f $CURR_DIR/configs/.p10k.zsh $HOME/.p10k.zsh


if [ "${CODESPACES:-}" = true ] && [ -z "${CODESPACE_DISPLAYNAME:-}" ]; then
    codespaces=$(gh codespace list)
    codespace_name=$(echo "$codespaces" | awk '{print $1, $2}' | grep "$CODESPACE_NAME" | awk '{print $2}')
    echo "export CODESPACE_DISPLAYNAME=${codespace_name}" >>~/.zshrc
fi

gh_ext() { gh extension list 2>/dev/null | grep -q "$1" || gh extension install "$1"; }
gh_ext rneatherway/gh-slack # Fetch Slack threads
gh_ext seachicken/gh-poi    # Delete merged branches
