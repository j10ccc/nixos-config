{ pkgs, ... }:

{
  imports = [
    ../../modules/bat
    ../../modules/fzf
  ];
  home.username = "j10c";
  home.stateVersion = "25.05";
  home.homeDirectory = /home/j10c;

  home.packages = with pkgs; [
    toybox
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
    gemini-cli-bin
    gh
    lazygit
    noti
    bottom
    uv
    go
    soco-cli
    viu
    tmux
    xclip
    claude-code
  ];

  home.file.".config/fish" = {
    source = ../../modules/fish;
    recursive = true;
  };

  home.file.".config/tmux/tmux.conf" = {
    source = ../../modules/smux/tmux.conf;
  };

  home.file.".local/bin/tmux-bridge" = {
    source = ../../modules/smux/bin/tmux-bridge;
    executable = true;
  };

  home.file.".local/bin/smux" = {
    source = ../../modules/smux/bin/smux;
    executable = true;
  };

  home.file.".gemini" = {
    source = ../../modules/gemini;
    recursive = true;
  };

  home.file.".config/systemd/user/nanobot-gateway.service".source =
    ../../modules/nanobot/nanobot-gateway.service;

  home.file.".config/systemd/user/sunshine.service".source = ../../modules/sunshine/sunshine.service;

  programs.home-manager.enable = true;

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
    loginShellInit = ''
      # Ensure Nix profile paths are available when fish is the login shell
      if test -e ~/.nix-profile/etc/profile.d/nix.fish
        source ~/.nix-profile/etc/profile.d/nix.fish
      end
      if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
      end
    '';
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
