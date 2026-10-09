#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# Ask for the administrator password upfront
sudo -v

# A bit from https://github.com/mathiasbynens/dotfiles and a bit from https://macos-defaults.com/
configure_macos_defaults() {
    # Swap Option and Command keys - by Copilot ❤️
    defaults write -g "com.apple.keyboard.modifiermapping.1452-610-0" -array "<dict><key>HIDKeyboardModifierMappingDst</key><integer>30064771113</integer><key>HIDKeyboardModifierMappingSrc</key><integer>30064771129</integer></dict>"

    ##### ⚠️ to be tested

    # Disable the keyboard settings menu bar item
    defaults write com.apple.TextInputMenu visible -bool false

    # Disable the wifi menu bar item
    defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -bool false

    # Disable the media menu bar item
    defaults write com.apple.controlcenter "NSStatusItem Visible NowPlaying" -bool false

    ##### ⚠️ to be tested

    # Wipe all (default) app icons from the Dock
    defaults write com.apple.dock persistent-apps -array

    # Increase sound quality for Bluetooth headphones/headsets
    defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

    # Disable smooth scrolling
    defaults write -g NSScrollAnimationEnabled -bool false

    # Disable natural scrolling for mouse
    defaults write -g com.apple.swipescrolldirection -bool false

    # Expand save panel by default
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

    # # Disable press-and-hold for keys in favor of key repeat
    # defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

    # # Set a blazingly fast keyboard repeat rate
    # defaults write NSGlobalDomain KeyRepeat -int 1
    # defaults write NSGlobalDomain InitialKeyRepeat -int 10

    # Save screenshots to the desktop
    defaults write com.apple.screencapture location -string "${HOME}/Desktop"

    # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
    defaults write com.apple.screencapture type -string "png"

    # Enable subpixel font rendering on non-Apple LCDs
    # Reference: https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
    defaults write NSGlobalDomain AppleFontSmoothing -int 1

    # Finder: show all filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
    defaults write com.apple.finder QuitMenuItem -bool true

    # Finder: show path bar
    defaults write com.apple.finder ShowPathbar -bool true

    # When performing a search, search the current folder by default
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

    # Keep folders on top when sorting by name
    defaults write com.apple.finder _FXSortFoldersFirst -bool true

    # Disable the warning before emptying the Trash
    defaults write com.apple.finder WarnOnEmptyTrash -bool false

    # Avoid creating .DS_Store files on network or USB volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    # Set the auto-hiding Dock delay
    defaults write com.apple.dock autohide-delay -float 0

    # Remove the animation when hiding/showing the Dock
    defaults write com.apple.dock autohide-time-modifier -float 0

    # Don’t show recent applications in Dock
    defaults write com.apple.dock show-recents -bool false

    # Set language and text formats
    defaults write NSGlobalDomain AppleLanguages -array "en" "de" "pt"
    defaults write NSGlobalDomain AppleLocale -string "en_US@currency=EUR"
    defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
    defaults write NSGlobalDomain AppleMetricUnits -bool true

    # # Show icons for hard drives, servers, and removable media on the desktop
    # defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
    # defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
    # defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
    # defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

    # Show language menu in the top right corner of the boot screen
    sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true

    # Enable HiDPI display modes (requires restart)
    sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

    # Disable the sound effects on boot
    sudo nvram SystemAudioVolume=" "

    # Enable lid wakeup
    sudo pmset -a lidwake 1

    # Set the timezone; see `sudo systemsetup -listtimezones` for other values
    sudo systemsetup -settimezone "Europe/Berlin" >/dev/null

    # Restart automatically if the computer freezes
    sudo systemsetup -setrestartfreeze on

    # Restart apps
    for app in "cfprefsd" \
        "Dock" \
        "Finder" \
        "SystemUIServer"; do
        killall "${app}" &>/dev/null
    done
}

setup_mac() {
    if ! xcode-select -p &>/dev/null; then
        echo "Installing Xcode command line tools..."
        echo "Please follow the instructions in the pop-up window to continue."
        xcode-select --install &>/dev/null || true
        until xcode-select -p &>/dev/null; do
            sleep 5
        done
    fi

    if ! command -v brew &>/dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || exit 1
        eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
    fi

    echo "Installing packages from Brewfile..."
    brew bundle --file=Brewfile

    local fish_path
    fish_path="$(brew --prefix)/bin/fish"
    if [ "$SHELL" != "$fish_path" ]; then
        echo "Setting fish as the default shell..."
        grep -qx "$fish_path" /etc/shells || echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
        sudo chsh -s "$fish_path" "$(id -un)"
    fi


    if ! gh auth status &>/dev/null; then
        echo "Logging into GitHub CLI..."
        gh auth login -s user
    fi

    local emails
    emails=$(gh api --method GET /user/emails --jq '.[] | "- \(.email)"' | cat)
    echo "Your GitHub emails:"
    echo "$emails"

    if [ ! -f "$HOME/.ssh/github_ed25519" ]; then
        ./scripts/setup_git.sh
    fi

    echo "Setting up Node via n..."
    sudo n install lts_latest

    ./scripts/install.sh

    # iTerm2 profile (iterm2 itself comes from the Brewfile)
    ITERM_PATH="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
    mkdir -p "$ITERM_PATH"
    cp ./configs/iterm2.json "$ITERM_PATH/profiles.json"
    defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "00000000-0000-0000-0000-000000000001"
}


configure_macos_defaults
setup_mac
