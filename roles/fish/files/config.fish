
# vi mode with default key bindings on normal mode
fish_hybrid_key_bindings

# set default editor
# (this is also required by tmux to handle vim like behavior)
set -U -x EDITOR nvim
set -U -x VISUAL nvim

# set default terminal identifier
# usefull for ssh sessions (some servers dont like alacritty)
set -U -x TERM xterm-256color

# add dir to path
fish_add_path "$HOME/.local/bin"
fish_add_path "$HOME/Applications"
fish_add_path "$HOME/.nix-profile/bin"

if status is-interactive
    # Commands to run in interactive sessions can go here
    atuin init fish --disable-up-arrow | source
end

# activate mise environment
~/.local/bin/mise activate fish | source

# activate keychain environment
eval (keychain --eval --quiet)

# starship prompt
starship init fish | source
