function fish_title
    # Shown as the terminal title; tmux picks this up as #{pane_title},
    # which the pane border uses to show the current host.
    set -l host (command hostname -s)
    set -l cwd (prompt_pwd)
    echo -n "$host: $cwd"
end
