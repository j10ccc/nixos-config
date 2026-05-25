{ pkgs, ... }:

{
  imports = [
    ../../modules/bat
    ../../modules/fzf
    ../../modules/lazygit
  ];
  home.stateVersion = "25.05";
  home.homeDirectory = /Users/bytedance;
  home.sessionVariables.EDITOR = "nvim";

  home.packages = with pkgs; [
    devbox
    obsidian
    localsend
    whistle
    pnpm
    ni
    gemini-cli
    nodejs_24
    bun
    bat-extras.prettybat
    uv
    gh
    noti
    claude-code
    lazygit
    worktrunk
    # Python with langfuse SDK for the Claude Code Stop hook in modules/claude-code/hooks/.
    # Shipped on every Darwin host; the wrapper short-circuits when TRACE_TO_LANGFUSE is unset.
    (python3.withPackages (ps: [ ps.langfuse ]))
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

  home.file."Library/Application Support/Trae CN/User" = {
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

  home.file.".claude/hooks/langfuse_hook.py" = {
    source = ../../modules/claude-code/hooks/langfuse_hook.py;
  };

  home.file.".claude/hooks/langfuse_hook.sh" = {
    source = ../../modules/claude-code/hooks/langfuse_hook.sh;
    executable = true;
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
          core.editor = "nvim";
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

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
  };
}
