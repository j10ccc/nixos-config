{ pkgs, ... }:

{
  home.stateVersion = "25.05";
  home.homeDirectory = /home/j10c;

  home.packages = with pkgs; [
    neovim
    ripgrep
    fd
    direnv
    nixfmt
    devbox
    nodejs_24
    pnpm
    bun
    ni
    gemini-cli
    gh
    noti
  ];

  home.file.".config/fish" = {
    source = ../../modules/fish;
    recursive = true;
  };

  home.file.".gemini" = {
    source = ../../modules/gemini;
    recursive = true;
  };

  home.file.".config/nvim" = {
    source = ../../modules/nvim;
    recursive = true;
  };

  programs.git = {
    enable = true;
    ignores = [
      ".envrc" # direnv
      "devbox.json" # devbox
      "devbox.lock"
    ];
    includes = [{
      contents = {
        user = {
          name = "j10c";
          email = "blyb1739@gmail.com";
        };
        init.defaultBranch = "master";
      };
    }];
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
