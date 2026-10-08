# fish config, linked to ~/.config/fish/config.fish by scripts/install.sh.
# Settings for one machine only go in ~/.config/fish/conf.d/local.fish (not tracked).

set -g fish_greeting # no welcome message

# Homebrew (Apple Silicon, Intel, Linux)
for brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew
    if test -x $brew
        $brew shellenv fish | source
        break
    end
end
set -e brew

fish_add_path -g ~/bin ~/.local/bin

# Repo root, found by following this file's symlink
set -gx DOTFILES (path resolve (status filename) | path dirname | path dirname | path dirname)

if set -q CODESPACES
    set -gx TZ Europe/Berlin # Codespaces default to UTC
    set -q CODESPACE_DISPLAYNAME; or set -gx CODESPACE_DISPLAYNAME $CODESPACE_NAME
end

# One ssh-agent per machine (macOS already runs one). Keys load on first use via AddKeysToAgent in ~/.ssh/config.
if not set -q SSH_AUTH_SOCK; and test -d ~/.ssh
    set -gx SSH_AUTH_SOCK ~/.ssh/agent.sock
    ssh-add -l &>/dev/null
    if test $status -eq 2 # nothing listening on the socket
        rm -f $SSH_AUTH_SOCK
        ssh-agent -a $SSH_AUTH_SOCK >/dev/null
    end
end

function update_dotfiles -d "Pull the latest dotfiles and restart fish"
    git -C $DOTFILES pull --ff-only; and exec fish
end

if status is-interactive
    if command -q starship
        starship init fish | source
        enable_transience # past prompts shrink to ❯ so scrollback stays tidy
    end

    # Abbreviations expand as you type. Port aliases from configs/.zshrc as you miss them, e.g.:
    # abbr -a gk git checkout
end
