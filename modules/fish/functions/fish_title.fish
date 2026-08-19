function fish_title
    # Shown as the terminal title; zellij picks this up as the pane title and
    # renders it in the pane frame. Nothing else shows the cwd there, so include it.
    set -l host (command hostname -s)
    echo -n "$host: "(prompt_pwd)
end
