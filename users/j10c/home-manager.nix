{ pkgs, ... }:

{
  home.stateVersion = "25.05";
  home.homeDirectory = /Users/j10c;

  home.packages = with pkgs; [
    devbox
    nodejs_24
    pnpm
    bun
    ni
    gemini-cli
    localsend
    whistle
    gh
    glab
    noti
    soco-cli
    tmux
    claude-code
  ];

  home.file.".config/ghostty" = {
    source = ../../modules/ghostty;
    recursive = true;
  };

  home.file.".config/fish" = {
    source = ../../modules/fish;
    recursive = true;
  };

  home.file.".config/tmux/tmux.conf" = {
    source = ../../modules/smux/tmux.conf;
  };

  home.file.".local/bin/tmux-buddy" = {
    source = ../../modules/smux/bin/tmux-buddy;
    executable = true;
  };

  home.file.".local/bin/tmux-bridge" = {
    source = ../../modules/smux/bin/tmux-bridge;
    executable = true;
  };

  home.file.".local/bin/smux" = {
    source = ../../modules/smux/bin/smux;
    executable = true;
  };

  home.file."Library/Application Support/Antigravity/User" = {
    source = ../../modules/code-oss;
    recursive = true;
  };

  home.file.".gemini" = {
    source = ../../modules/gemini;
    recursive = true;
  };

  home.file.".claude/settings.json" = {
    source = ../../modules/claude-code/settings.json;
  };

  programs.git = {
    enable = true;
    ignores = [
      ".envrc" # direnv
      "devbox.json" # devbox
      "devbox.lock"
    ];
    includes = [
      {
        contents = {
          user = {
            name = "j10c";
            email = "blyb1739@gmail.com";
          };
          init.defaultBranch = "master";
        };
      }
    ];
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = "source ~/.config/fish/config-entry.fish";
  };

  programs.vivid = {
    enable = true;
    enableFishIntegration = true;
    activeTheme = "nord";
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
  };

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
