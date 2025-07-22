#!/bin/bash
exec > >(tee -i $HOME/dotfiles_install.log)
exec 2>&1
set -x

echo "Start install dotfiles as $USERNAME"
CURR_DIR=$(pwd)

echo "Download zsh plugins"
# install zsh plugins
git clone --depth=1 https://github.com/agkozak/zsh-z ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-z
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/romkatv/powerlevel10k ${ZSH_CUSTOM:-~/.oh-my-zsh}/themes/powerlevel10k

cp -f $CURR_DIR/configs/.zshrc $HOME/.zshrc
cp -f $CURR_DIR/configs/.p10k.zsh $HOME/.p10k.zsh

sudo chsh "$(id -un)" --shell "/usr/bin/zsh"

if $CODESPACES -eq true && test -z "$CODESPACE_DISPLAYNAME" ; then
    codespaces=$(gh codespace list)
    codespace_name=$(echo "$codespaces" | awk '{print $1, $2}' | grep $CODESPACE_NAME | awk '{print $2}')
    echo "export CODESPACE_DISPLAYNAME=${codespace_name}" >>~/.zshrc
fi

source ~/.zshrc