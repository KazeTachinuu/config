# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Disable Oh My Zsh theme (using custom prompt instead)
ZSH_THEME=""

# Configure command history
HISTSIZE=10000                    # Number of commands to keep in memory
SAVEHIST=10000                    # Number of commands to save to history file
HISTFILE=~/.zsh_history          # History file location
setopt hist_ignore_all_dups      # Don't store duplicate commands
setopt extended_glob             # Extended pattern matching
setopt prompt_subst              # Enable command substitution in prompt

# Load useful Zsh plugins
plugins=(
    git                         # Git aliases and functions
    zsh-autosuggestions        # Fish-like command suggestions
    zsh-syntax-highlighting    # Command syntax highlighting
    history                    # History commands and searching
    web-search                 # Search web from terminal
)

# Configure Git information in prompt
autoload -Uz vcs_info           # Load version control info system
zstyle ':vcs_info:*' enable git # Enable git support
# Format git branch info: (branch_name)
zstyle ':vcs_info:git*' formats ' %F{blue}(%F{green}%b%F{blue})%f%F{red}%u%c%f'
# Format git action info: (branch_name|action)
zstyle ':vcs_info:git*' actionformats ' %F{blue}(%F{green}%b|%a%F{blue})%f%F{red}%u%c%f'
zstyle ':vcs_info:*' check-for-changes true  # Check for uncommitted changes
zstyle ':vcs_info:*' unstagedstr '*'         # Symbol for unstaged changes
zstyle ':vcs_info:*' stagedstr '+'           # Symbol for staged changes
precmd() { vcs_info }                        # Update git info before each prompt

# Set up the prompt (PS1)
# Format: username🍎hostname-[current_directory](git_branch)
PROMPT=$'%F{blue}┌──(%F{cyan}%B%n%F{magenta}🍎%F{cyan}%m%b%F{blue})-[%F{yellow}%B%(8~|%-4~/.../%3~|%~)%b%F{blue}]%f${vcs_info_msg_0_}\n%F{blue}└─%F{cyan}%B$%b%F{blue}%f '

# Set up right prompt (RPROMPT)
# Shows error code and background jobs if any
RPROMPT=$'%(?.. %F{magenta}%?%f %F{red}✘%f)%(1j. %F{cyan}%j%f %F{yellow}⚙%f.)'

# Source Oh My Zsh and additional configuration files
source $ZSH/oh-my-zsh.sh                                    # Load Oh My Zsh
[[ -f ~/.my_aliases.txt ]] && source ~/.my_aliases.txt      # Load aliases if exists
[[ -f ~/.zsh_profile ]] && source ~/.zsh_profile           # Load profile if exists
source <(fzf --zsh)                                         # Load fuzzy finder integration with CTRL+R
