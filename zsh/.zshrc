source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

eval "$(/opt/homebrew/bin/brew shellenv)"
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# history setup
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ---- Eza (better ls) -----
alias ls="eza --icons=always"

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"
alias cd="z"
alias nr="npm run"
alias dc="docker-compose"
alias gp="git push"
alias gpuo="git push --set-upstream origin"
alias node="$(which node)"

JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home/
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:/opt/homebrew/bin/idb
export PATH="/usr/local/bin:$PATH"

export ANTHROPIC_API_KEY=<key>
export GEMINI_API_KEY=<key>

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export NODE_BINARY=$(command -v node)
export NODE_OPTIONS="--max_old_space_size=8096"

git() {
  # First, check if the command is 'git status'
  if [[ "$1" == "status" ]]; then

    # --- YOUR PROXY LOGIC STARTS HERE ---
    # Initialize an empty array to hold the filtered arguments
    filtered_args=()

    # Loop through all arguments passed to 'git status' (skipping the 'status' part itself)
    for arg in "${@:2}"; do
      # Check if the argument is '--untracked-files=all'
      if [[ "$arg" == "--untracked-files=all" ]]; then
        # If it is, skip it
        continue
      fi
      # Otherwise, add the argument to our filtered list
      filtered_args+=("$arg")
    done

    # Execute the real 'git status' command with only the filtered arguments
    command git status "${filtered_args[@]}"
    # --- YOUR PROXY LOGIC ENDS HERE ---

  else
    # For any other command (e.g., 'git pull', 'git commit'),
    # execute it normally without any changes.
    command git "$@"
  fi
}
