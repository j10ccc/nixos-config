{ pkgs, ... }:

let
  mkAgentContext = import ../../modules/agent-context/mk-context.nix pkgs;
in
{
  imports = [
    ../../modules/bat
    ../../modules/fzf
    ../../modules/hermes
    ../../modules/multica
    ../../modules/sunshine
    ../../modules/lazygit
    ../../modules/zellij
  ];

  home.username = "j10c";
  home.stateVersion = "25.05";
  home.homeDirectory = /home/j10c;
  home.sessionVariables.EDITOR = "nvim";

  home.packages = with pkgs; [
    toybox
    neovim
    ripgrep
    fd
    nixfmt
    devbox
    nodejs_24
    pnpm
    bun
    ni
    gh
    noti
    bottom
    uv
    go
    soco-cli
    viu
    zellij
    xclip
    jq
    claude-code
    pi-coding-agent
    tea
    caddy
  ];

  home.file.".config/fish" = {
    source = ../../modules/fish;
    recursive = true;
  };

  home.file.".pi/agent/models.json" = {
    source = ../../modules/pi/models.json;
  };

  home.file.".pi/agent/AGENTS.md" = {
    source = mkAgentContext { name = "AGENTS.md"; };
  };

  home.file.".claude/settings.json" = {
    source = ../../modules/claude-code/settings.json;
  };

  home.file.".claude/statusline.sh" = {
    source = ../../modules/claude-code/statusline.sh;
    executable = true;
  };

  home.file.".claude/CLAUDE.md" = {
    source = mkAgentContext { name = "CLAUDE.md"; };
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    ignores = [
      ".envrc" # direnv
      ".devbox" # devbox
      "devbox.json"
      "devbox.lock"
    ];
    includes = [
      {
        contents = {
          user = {
            name = "j10c";
            email = "blyb1739@gmail.com";
          };
          core.editor = "nvim";
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
    activeTheme = "solarized-dark";
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
  };
}
