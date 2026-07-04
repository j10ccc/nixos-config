{ ... }:

{
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    defaultCommand = "fd --type f --hidden --exclude .git";
    changeDirWidget = {
      command = "fd --type d --hidden --exclude .git";
      options = [
        "--ansi"
        "--preview 'eza --tree --level=2 --color=always {}'"
      ];
    };
    fileWidget = {
      command = "fd --type f --hidden --exclude .git";
      options = [
        "--ansi"
        "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
        "--preview-window 'right:60%'"
      ];
    };
  };
}
