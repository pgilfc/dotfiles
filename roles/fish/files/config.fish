
# set default editor
# (this is also required by tmux to handle vim like behavior)
set -U -x EDITOR nvim
set -U -x VISUAL nvim

# add dir to path
fish_add_path "$HOME/.local/bin"
fish_add_path "$HOME/Applications"
fish_add_path "$HOME/.nix-profile/bin"

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# activate mise environment
~/.local/bin/mise activate fish | source

# activate keychain environment
eval (keychain --eval --quiet)

# starship prompt
starship init fish | source
