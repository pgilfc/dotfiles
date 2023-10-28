
source $HOME/.antigen.zsh

# Uncomment if you want zsh to start on every terminal
#ZSH_TMUX_AUTOSTART=true # Autostart tmux on zsh
ZSH_TMUX_AUTOQUIT=false # Dont exit zsh on tmux detach/exit

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle direnv
antigen bundle docker
antigen bundle git
antigen bundle brew
antigen bundle python
antigen bundle pip
antigen bundle golang
antigen bundle mix
antigen bundle npm
antigen bundle ssh-agent
antigen bundle tmux
antigen bundle tmuxinator
antigen bundle vscode
antigen bundle zoxide
antigen bundle zsh-interactive-cd

# # VI mode for zsh
# antigen bundle jeffreytse/zsh-vi-mode
# # bind k and j for VI mode
# bindkey -M vicmd 'k' history-substring-search-up
# bindkey -M vicmd 'j' history-substring-search-down

# Fish like auto sugestions
antigen bundle zsh-users/zsh-autosuggestions
# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting
# aditional completions
antigen bundle zsh-users/zsh-completions
# fish like substring search
antigen bundle zsh-users/zsh-history-substring-search

# Tell Antigen that you're done.
antigen apply

# History config
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
HISTDUP=erase                   #Erase duplicates in the history file
setopt EXTENDED_HISTORY         # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY       # Write to the history file immediately, not when the shell exits.
unsetopt SHARE_HISTORY          # Unset Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST   # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS         # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS     # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS        # Do not display a line previously found.
setopt HIST_SAVE_NO_DUPS        # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS       # Remove superfluous blanks before recording entry

# Bind up and down key to history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[OA' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OB' history-substring-search-down
# Bind ctrl+p and ctrl+n to history-substring-search
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down

# set default editor
# (this is also required by tmux to handle vim like behavior)
export EDITOR='nvim'
export VISUAL='nvim'

# Enable history in IEX through Erlang(OTP)
export ERL_AFLAGS="-kernel shell_history enabled"

# Set PATH so it includes private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
  PATH="$PATH:$HOME/.local/bin"
fi

# Set PATH so it includes Applications folder if exists
if [ -d "$HOME/Applications" ] ; then
  PATH="$PATH:$HOME/Applications"
fi

# activate rtx environment
eval "$(~/.nix-profile/bin/rtx activate zsh)"

# starship prompt
eval "$(starship init zsh)"

# Alacritty completions
fpath+="$HOME/.alacritty/extra/completions/"

source ~/.zprofile
zstyle ':completion:*' menu select
fpath+=~/.zfunc

