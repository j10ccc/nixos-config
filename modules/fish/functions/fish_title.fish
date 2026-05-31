function fish_title
    # Shown as the terminal title; tmux picks this up as #{pane_title}.
    # Inside tmux, the pane border appends the cwd basename separately,
    # so we emit just the host to avoid duplicating the path.
    set -l host (command hostname -s)
    if set -q TMUX
        echo -n "$host"
    else
        echo -n "$host: "(prompt_pwd)
    end
end
