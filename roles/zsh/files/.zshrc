
source $HOME/.antigen.zsh

# Uncomment if you want zsh to start on every terminal
#ZSH_TMUX_AUTOSTART=true # Autostart tmux on zsh
ZSH_TMUX_AUTOQUIT=false # Dont exit zsh on tmux detach/exit

# Make sure tmux server is running
[[ -n $(pgrep tmux) ]] || tmux start \; new-session -d -s kill-me 'sleep 4 && exit' \; new-session -d -s 0

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle asdf
antigen bundle git
antigen bundle brew
antigen bundle macos
antigen bundle history
antigen bundle python
antigen bundle pip
antigen bundle golang
antigen bundle mix
antigen bundle npm
antigen bundle tmux
antigen bundle tmuxinator
antigen bundle vscode

# Fish like auto sugestions
antigen bundle zsh-users/zsh-autosuggestions
# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting
# aditional completions
antigen bundle zsh-users/zsh-completions
# fish like substring search
antigen bundle zsh-users/zsh-history-substring-search

# Load the theme.
antigen theme romkatv/powerlevel10k

# Tell Antigen that you're done.
antigen apply

# History config
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
HISTDUP=erase                   #Erase duplicates in the history file
setopt appendhistory            #Append history to the history file (no overwriting)
setopt sharehistory             #Share history across terminals
setopt incappendhistory         #Immediately append to the history file, not just when a term is killed
setopt EXTENDED_HISTORY         # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY       # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY            # Share history between all sessions.
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

# Enable history in IEX through Erlang(OTP)
export ERL_AFLAGS="-kernel shell_history enabled"

# Set PATH so it includes private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
  PATH="$PATH:$HOME/.local/bin"
fi

# Alacritty completions
fpath+="$HOME/.alacritty/extra/completions/"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
