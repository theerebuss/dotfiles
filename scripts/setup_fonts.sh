#!/usr/bin/env bash
# Install MesloLGS NF (the font powerlevel10k is tuned for) for the current user.
# Windows is handled by .windows.ps1
set -euo pipefail

case "$(uname)" in
Darwin) font_dir="$HOME/Library/Fonts" ;;
*) font_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts" ;;
esac
mkdir -p "$font_dir"

for variant in Regular Bold Italic "Bold Italic"; do
    file="MesloLGS NF $variant.ttf"
    [ -f "$font_dir/$file" ] && continue
    curl -fsSL "https://github.com/romkatv/powerlevel10k-media/raw/master/${file// /%20}" -o "$font_dir/$file"
done

if command -v fc-cache &>/dev/null; then
    fc-cache -f "$font_dir"
fi
echo "Fonts installed to $font_dir"
