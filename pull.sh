dotfiles_username="theerebuss"
default_workspace_path="$HOME/workspace"

# Ubuntu workaround
if ! command -v unzip &>/dev/null && [ "$(uname)" = "Linux" ]; then
    echo "Installing unzip..."
    sudo apt-get update && sudo apt-get install -y unzip
fi

# Setup default source code directory
mkdir -p $default_workspace_path
cd $default_workspace_path

curl -L -O https://github.com/$dotfiles_username/dotfiles/archive/refs/heads/main.zip
unzip -o main.zip
rm main.zip

mv dotfiles-main dotfiles
cd dotfiles
