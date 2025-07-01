
./setup_fonts.sh

sudo xcode-select --install &> /dev/null
until $(xcode-select --print-path &> /dev/null); do
  sleep 5;
done

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

brew install gh
echo "Your GitHub emails:"
gh auth login -s user -s codespace
gh api --method GET /user/emails --jq ".[].email"

brew install zsh
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zshrc
sudo chsh -s /bin/zsh

brew install --cask visual-studio-code
brew install n
sudo n install latest

./install.sh

brew install --cask maccy
sleep 1
open -a Maccy

brew install --cask rectangle
# Copy Rectange profile
RECT_PATH="$HOME/Library/Application Support/Rectangle"
mkdir -p $RECT_PATH
cp ./configs/rectangle.json "$RECT_PATH/RectangleConfig.json"
sleep 1
open -a Rectangle

brew install --cask iterm2
# Copy iterm2 profiles and set default
ITERM_PATH="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
mkdir -p $ITERM_PATH
cp ./configs/iterm2.json "$ITERM_PATH/profiles.json"
defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "00000000-0000-0000-0000-000000000001"

# A11y queens
brew install --cask keycastr colour-contrast-analyser pika 
# brew install --cask background-music # Background audio capture
# Alternative screen recorder - https://rewatch.com/screen-recorder/

# Mac customization configs (https://macos-defaults.com/)
### Swap Option and Command keys - by Copilot ❤️
defaults write -g "com.apple.keyboard.modifiermapping.1452-610-0" -array "<dict><key>HIDKeyboardModifierMappingDst</key><integer>30064771113</integer><key>HIDKeyboardModifierMappingSrc</key><integer>30064771129</integer></dict>"

## Obliterate annoying space creator when dragging app to top of screen (not working 🤬)
# defaults write com.apple.dock mcx-expose-disabled -bool TRUE
# defaults write com.apple.dashboard mcx-disabled -bool TRUE
# killall Dock

## Remove recent apps from dock
defaults write com.apple.dock "show-recents" -bool false

## Disable natural scrolling for mouse
defaults write -g com.apple.swipescrolldirection -bool false

## Disable smooth scrolling
defaults write -g NSScrollAnimationEnabled -bool false

## Restart dock
killall Dock

# Other apps
brew install --cask spotify
brew install --cask datweatherdoe

# Slack thread extension
gh extension install https://github.com/rneatherway/gh-slack