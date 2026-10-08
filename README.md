# Dotfiles

> This is my dotfiles. There are many like it, but this one is mine.
>
> My dotfiles is my best friend. It is my life. I must master it as I must master my life.
>
> Without me, my dotfiles is useless. Without my dotfiles, I am useless.

## Supported platforms

- macOS
- Linux (Debian/Ubuntu) / WSL
- Windows (debloat and fonts, PowerShell)

## Usage

Clone (or update) the repo into `~/workspace/dotfiles`:

```bash
curl -fsSL https://raw.githubusercontent.com/theerebuss/dotfiles/refs/heads/main/pull.sh | bash
```

Then run the script for your platform:

```bash
cd ~/workspace/dotfiles
./.macos.sh # macOS
./.wsl.sh   # WSL / Ubuntu
```

Windows, from an elevated PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .windows.ps1
```

Configs are symlinked into `$HOME`, so edit them in place and commit. `update_dotfiles` pulls the latest and reloads the shell. Install output is logged to `~/dotfiles_install.log`.
