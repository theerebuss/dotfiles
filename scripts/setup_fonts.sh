curl https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Regular.ttf --output /tmp/meslo_font/MesloLGS_NF_Regular.ttf --create-dirs
curl https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Bold.ttf --output /tmp/meslo_font/MesloLGS_NF_Bold.ttf --create-dirs
curl https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Italic.ttf --output /tmp/meslo_font/MesloLGS_NF_Italic.ttf --create-dirs
curl https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Bold%20Italic.ttf --output /tmp/meslo_font/MesloLGS_NF_BoldItalic.ttf --create-dirs

# TODO: If Windows

# If Mac
[ -d "/Library/Fonts" ] && cp /tmp/meslo_font/* /Library/Fonts/