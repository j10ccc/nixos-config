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
    wezterm
    localsend
    whistle
  ];

  # misc files
  home.file = {
    ".gitignore_global" = { source = ../../modules/misc/.gitignore_global; };
  };

  home.file.".config/wezterm" = {
    source = ../../modules/wezterm;
    recursive = true;
  };

  home.file.".config/fish" = {
    source = ../../modules/fish;
    recursive = true;
  };

  home.file."Library/Application Support/VSCodium/User" = {
    source = ../../modules/vscodium;
    recursive = true;
  };

  home.file.".gemini" = {
    source = ../../modules/gemini;
    recursive = true;
  };

  programs.git = {
    enable = true;
    userName = "j10c";
    userEmail = "blyb1739@gmail.com";
    extraConfig = {
      init.defaultBranch = "master";
      core.excludesFile = "~/.gitignore_global";
    };
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
}
