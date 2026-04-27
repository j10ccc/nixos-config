function fzfa --description "fzf all files (including node_modules etc.)"
    fd --type f --hidden --no-ignore --exclude .git | fzf $argv
end
