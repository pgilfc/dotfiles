
# set default editor
# (this is also required by tmux to handle vim like behavior)
set -U -x EDITOR nvim
set -U -x VISUAL nvim

# add dir to path
fish_add_path "$HOME/.local/bin"
fish_add_path "$HOME/Applications"

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# activate rtx environment
~/.nix-profile/bin/rtx activate fish | source

# starship prompt
starship init fish | source
