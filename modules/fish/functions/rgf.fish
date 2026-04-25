function rgf --description "rg + fzf: search content then open file at line"
    set -l result (rg --color=always --line-number --no-heading $argv | fzf --ansi --delimiter : --preview 'bat --color=always --highlight-line {2} {1}' --preview-window '+{2}-5')
    or return
    set -l file (echo $result | cut -d: -f1)
    set -l line (echo $result | cut -d: -f2)
    $EDITOR +$line $file
end
