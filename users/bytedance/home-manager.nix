{ pkgs, ... }:

{
  imports = [
    ../../modules/bat
    ../../modules/fzf
    ../../modules/lazygit
    ../../modules/zellij
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
    zellij
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
      ".devbox" # devbox
      "devbox.json"
      "devbox.lock"
    ];
    includes = [
      {
        contents = {
          core.editor = "nvim";
          # 大仓里把 fish_prompt 的 git status 从 440ms 压到 50ms。
          # 前提和代价见 users/j10c/home-manager.nix 里同一项的注释。
          core.untrackedCache = true;
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
