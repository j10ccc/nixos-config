function fish_prompt
    set -l last_status $status
    set -l cwd (prompt_pwd)

    # Separate from mode prompt
    echo -n " "

    # Display hostname when connected via SSH
    if set -q SSH_CONNECTION
        set_color yellow -b normal
        echo -n "[$hostname] "
    end

    # Display current path
    set_color blue -b normal
    echo -n "$cwd "

    if not test "$TERM_PROGRAM" = "vscode"
        # Show git branch and dirty state
        set -l git_branch (command git branch --show-current 2> /dev/null)
        set -l git_hash (command git rev-parse --short HEAD 2> /dev/null)
        set -l git_dirty (command git status -s --ignore-submodules=dirty 2> /dev/null)

        set -l git_prompt
        if test -z "$git_branch"
            set git_prompt $git_hash
        else
            set git_prompt $git_branch
        end

        if test -n "$git_prompt"
            if test -n "$git_dirty"
                set_color yellow -b normal
                echo -n "$git_prompt "
            else
                set_color green -b normal
                echo -n "$git_prompt "
            end
        end
    end

    if not test $last_status -eq 0
        set_color normal
        set_color --bold red
        echo -n '! '
        set_color normal
    end

    # Reset color for user input
    set_color normal
end
