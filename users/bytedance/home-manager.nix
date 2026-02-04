{ pkgs, ... }:

{
  home.stateVersion = "25.05";
  home.homeDirectory = /Users/bytedance;

  home.packages = with pkgs; [
    devbox
    wezterm
    obsidian
    vscodium
    localsend
    whistle
    pnpm
    ni
    gemini-cli
    nodejs_24
    bun
    bat
    bat-extras.prettybat
    uv
  ];

  home.file.".config/wezterm" = {
    source = ../../modules/wezterm;
    recursive = true;
  };

  home.file.".config/ghostty" = {
    source = ../../modules/ghostty;
    recursive = true;
  };

  home.file.".config/fish" = {
    source = ../../modules/fish;
    recursive = true;
  };

  home.file."Library/Application Support/VSCodium/User" = {
    source = ../../modules/code-oss;
    recursive = true;
  };

  home.file."Library/Application Support/Trae CN/User" = {
    source = ../../modules/code-oss;
    recursive = true;
  };

  home.file.".gemini" = {
    source = ../../modules/gemini;
    recursive = true;
  };

  programs.git = {
    enable = true;
    ignores = [
      ".envrc" # direnv
      "devbox.json" # devbox
      "devbox.lock"
    ];
    includes = [{ contents = { init.defaultBranch = "master"; }; }];
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

  programs.bat = {
    enable = true;
    config = { theme = "Nord"; };
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
  };
}
