export TZ="Europe/Prague"
export PATH=$HOME/bin:/usr/local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

NPM_PACKAGES="${HOME}/.npm-packages"
export PATH="$PATH:$NPM_PACKAGES/bin"
export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"

plugins=(
    git
    zsh-z
    zsh-syntax-highlighting
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

## To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Aliases

## Git

### Delete local and remote branch
gdb() {
    git branch -d $1
    git push origin --delete $1
}

### Add all and ammend last commit
alias gfix="git add --all && git commit --amend --no-edit"

alias gl="git log"
alias ga="git add ."
alias gk="git checkout"
alias gs="git stash"
alias gsp="git stash pop"
alias gb="git for-each-ref --sort=-creatordate --format='%(creatordate:short) %(refname:short)' refs/heads/"
alias gum="git checkout main && git fetch origin main && git merge FETCH_HEAD && git checkout -"
alias gummy="gum && git rebase main"

# Usage: gb_special [<args>]
# Arguments:
#   <args>: Additional arguments to pass to `git branch`
# Example: `gb -D <branch_name>` to delete a branch
#
# If no arguments are provided, it will list branches with creation date and highlight the current branch
gb_special() {
  if [ "$#" -gt 0 ]; then
    git branch "$@"
    return
  fi
  
  local current_branch=$(git rev-parse --abbrev-ref HEAD)
  git for-each-ref --sort=-creatordate --format='%(creatordate:short) %(creatordate:format:%H:%M:%S) %(refname:short)' refs/heads/ | \
    awk -v branch="$current_branch" '
      $0 ~ branch"$" {
        print "\033[32m\033[4m" $0 "\033[0m"
        next
      }
      { print }
    '
}
alias gb="gb_special"

### Get TODOs you authored - https://twitter.com/almonk/status/1576294814831718400
alias todo='git grep -l TODO | xargs -n1 git blame -f -n -w | grep "$(git config user.name)" | grep TODO | sed "s/.\{9\}//" | sed "s/(.*)[[:space:]]*//"'

alias sc="source $HOME/.zshrc"


# Fetch Slack thread, wrap in <details>, use accessible link as <summary> and copy into clipboard.
# Requires gh CLI with Slack extension installed.
#
# Usage: slack <slack_url>
# Arguments:
#   <slack_url>: The URL of a thread or message
slack() {
  local url=$1
  if [ -z "$url" ]; then
    echo "Usage: slack <slack_url>"
    return 1
  fi
  
  local thread=$(gh slack read $url)

  local output=$(cat <<EOF
<details>
  <summary>
    <a href="$url">Slack thread</a>
  </summary>

$thread
</details>
EOF
)

  if command -v pbcopy &>/dev/null; then
    echo "$output" | pbcopy
  elif command -v xclip &>/dev/null; then
    echo "$output" | xclip -selection clipboard
  else
    echo "No clipboard utility found. Install pbcopy (macOS) or xclip (Linux) to automatically copy the output."
    echo "\n$output\n"
    return 1
  fi

  echo "Slack thread copied to clipboard."
}
