# ==============================================================================
# 1. ENVIRONMENT VARIABLES & PATHS
# ==============================================================================
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nano'
fi
export LANG=en_US.UTF-8

# ==============================================================================
# 2. HISTORY CONFIGURATION (Feeds the auto-suggestions)
# ==============================================================================
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE

# ==============================================================================
# 3. ADVANCED AUTO-COMPLETE & TAB COMPLETION
# ==============================================================================
# Initialize Zsh menu completion
autoload -Uz compinit && compinit

# Show a visible menu when pressing Tab
zstyle ':completion:*' menu select

# Case-insensitive tab completion (e.g., 'cd down' -> 'Downloads')
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

# Colorize the completion menu to match your 'ls' colors
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Use arrow keys to navigate the Tab completion menu
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s

# ==============================================================================
# 4. FISH-LIKE AUTO-SUGGESTIONS (Type-ahead predictions)
# ==============================================================================
# Automatically clones and sources the auto-suggestions plugin if missing
AUTO_SUGGEST_DIR="$HOME/.zsh/zsh-autosuggestions"
if [ ! -d "$AUTO_SUGGEST_DIR" ]; then
  echo "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTO_SUGGEST_DIR"
fi
source "$AUTO_SUGGEST_DIR/zsh-autosuggestions.zsh"

# Strategy: suggest from history first, then fallback to completion engine
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# ==============================================================================
# 5. PROMPT SETUP
# ==============================================================================
autoload -Uz vcs_info
precmd() { vcs_info; }
zstyle ':vcs_info:git:*' formats '%F{cyan}(%b)%f '

setopt PROMPT_SUBST
PROMPT='%F{green}[%n@%m]%f %F{blue}%~%f ${vcs_info_msg_0_}%F{yellow}%% %f'

# ==============================================================================
# 6. ALIASES
# ==============================================================================
alias v='nvim'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias zshconfig="nvim ~/.zshrc"
alias zshreload="source ~/.zshrc"

eval "$(paneship init zsh)"

# ==============================================================================
# 7. INTERACTIVE CLI TOOLS (FZF & ATUIN)
# ==============================================================================
# 1. Initialize FZF (Claims Ctrl+R and Ctrl+T)
if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
elif [ -d /usr/share/fzf ]; then
  source /usr/share/fzf/completion.zsh
  source /usr/share/fzf/key-bindings.zsh
elif [ -x "$(command -v brew)" ] && [ -f "$(brew --prefix)/opt/fzf/shell/completion.zsh" ]; then
  source "$(brew --prefix)/opt/fzf/shell/completion.zsh"
  source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
fi

# 2. Initialize Atuin (Custom Keybinding for Ctrl+F)
if command -v atuin &>/dev/null; then
  # Disable default Ctrl+R and Up-Arrow bindings to prevent conflicts
  eval "$(atuin init zsh --disable-ctrl-r --disable-up-arrow)"

  # Manually bind Atuin search widget to Ctrl+F
  bindkey '^F' atuin-search
fi
