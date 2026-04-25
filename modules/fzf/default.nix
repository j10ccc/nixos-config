{ ... }:

{
  programs.bat = {
    enable = true;
    config.theme = "Nord";
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    defaultCommand = "fd --type f --hidden --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --exclude .git";
    fileWidgetOptions = [ "--ansi" "--preview 'bat --color=always --style=numbers --line-range=:500 {}'" "--preview-window 'right:60%'" ];
    changeDirWidgetOptions = [ "--ansi" "--preview 'eza --tree --level=2 --color=always {}'" ];
  };
}
