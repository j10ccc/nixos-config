{ pkgs, ... }:

{
  imports = [
    ../../modules/bat
    ../../modules/fzf
    ../../modules/lazygit
    ../../modules/zellij
  ];
  home.stateVersion = "25.05";
  home.homeDirectory = /Users/j10c;
  home.sessionVariables.EDITOR = "nvim";

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
    zellij
    claude-code
    pi-coding-agent
    lazygit
    worktrunk
    uv
  ];

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

  home.file.".gemini" = {
    source = ../../modules/gemini;
    recursive = true;
  };

  home.file.".claude/settings.json" = {
    source = ../../modules/claude-code/settings.json;
  };

  home.file.".pi/agent/models.json" = {
    source = ../../modules/pi/models.json;
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
          user = {
            name = "j10c";
            email = "blyb1739@gmail.com";
          };
          core.editor = "nvim";
          # fish_prompt 每次出提示符跑一次 git status，其中「遍历工作区找未跟踪文件」
          # 这一步随仓库规模线性增长：17k 已跟踪文件 + 满地 node_modules 的仓要 ~470ms，
          # 于是 clear 之后要等半秒才出新 prompt。untracked cache 靠目录 mtime 跳过没动过
          # 的子树，把 git status 从 440ms 压到 50ms。
          # 代价：正确性依赖文件系统在增删文件时更新父目录 mtime。本地 APFS 没问题，
          # 网络盘（SMB/NFS）、容器挂载卷不保证 —— 在那种地方要 core.untrackedCache=false。
          # 用 `git update-index --test-untracked-cache` 复验，临时绕过用
          # `git -c core.untrackedCache=false status`。
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
