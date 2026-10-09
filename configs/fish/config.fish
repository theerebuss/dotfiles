set -g fish_greeting # no welcome message

set -gx TZ Europe/Berlin

# Homebrew (Apple Silicon, Intel, Linux)
for brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew
    if test -x $brew
        $brew shellenv fish | source
        break
    end
end
set -e brew

fish_add_path -g ~/bin ~/.local/bin

# ls colors override
set -gx LS_COLORS (string join : 'di=1;38;2;102;178;228' 'ow=1;38;2;102;178;228' 'tw=1;38;2;102;178;228' \
    'st=1;38;2;102;178;228' 'ln=38;2;52;139;195' 'ex=38;2;244;155;69' 'or=38;2;64;85;146' 'mi=38;2;64;85;146')

# Repo root, found by following this file's symlink
set -gx DOTFILES (path resolve (status filename) | path dirname | path dirname | path dirname)

if set -q CODESPACES
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
    # Apply dope ass theme
    test -f $__fish_config_dir/themes/fisheries.theme; and fish_config theme choose fisheries

    if command -q starship
        starship init fish | source
        enable_transience
        # keep the ❯ red after a failed command
        function starship_transient_prompt_func
            starship module character $argv
        end
    end

    # Ctrl+C leaves the echo without a newline, which fish marks with ¶, so we remove it because it's ugly
    function __newline_after_ctrl_c --on-event fish_postexec
        test $status -eq 130; and echo
    end

    # Abbreviations expand as you type. Port aliases from configs/.zshrc as you miss them, e.g.:
    # abbr -a gk git checkout
end
