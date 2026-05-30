{ pkgs, ... }:

{
  imports = [
    ../../modules/bat
    ../../modules/fzf
    ../../modules/hermes
    ../../modules/langfuse
    ../../modules/litellm
    ../../modules/nanobot
    ../../modules/sunshine
    ../../modules/lazygit
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
    gemini-cli-bin
    gh
    noti
    bottom
    uv
    go
    soco-cli
    viu
    tmux
    xclip
    claude-code
    # Python with langfuse SDK for the Claude Code Stop hook in modules/claude-code/hooks/.
    # The wrapper short-circuits when TRACE_TO_LANGFUSE is unset.
    (python3.withPackages (ps: [ ps.langfuse ]))
    tea
  ];

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

  home.file.".gemini" = {
    source = ../../modules/gemini;
    recursive = true;
  };

  home.file.".claude/settings.json" = {
    source = ../../modules/claude-code/settings.json;
  };

  home.file.".claude/hooks/langfuse_hook.py" = {
    source = ../../modules/claude-code/hooks/langfuse_hook.py;
  };

  home.file.".claude/hooks/langfuse_hook.sh" = {
    source = ../../modules/claude-code/hooks/langfuse_hook.sh;
    executable = true;
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
    activeTheme = "nord";
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
