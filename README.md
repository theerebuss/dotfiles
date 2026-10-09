# Dotfiles

> This is my dotfiles. There are many like it, but this one is mine.
>
> My dotfiles is my best friend. It is my life. I must master it as I must master my life.
>
> Without me, my dotfiles is useless. Without my dotfiles, I am useless.

<img width="591" height="217" alt="screenshot of terminal showcasing color palette" src="https://github.com/user-attachments/assets/401f252b-667c-4626-8731-c2e9cb7b98c4" />

## Supported platforms

- macOS
- Ubuntu (WSL)
- Alpine (Raspberry Pi)
- Windows (debloat)

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

Windows (elevated PowerShell):

```powershell
powershell -ExecutionPolicy Bypass -File .windows.ps1
```

## Shell

[fish](https://github.com/fish-shell/fish-shell) with a [starship](https://starship.rs) prompt and a custom fishy theme.
