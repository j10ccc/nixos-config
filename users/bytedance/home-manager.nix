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
    nodejs_24
    bun
    bat-extras.prettybat
    uv
    go
    gh
    noti
    zellij
    claude-code
    pi-coding-agent
    lazygit
    worktrunk
    # Trae 内网 gopls，预编译二进制（替代内网 brew tap flow/trae-gopls）。
    (callPackage ../../pkgs/trae-gopls { })
  ];

  home.file.".config/ghostty" = {
    source = ../../modules/ghostty;
    recursive = true;
  };

  home.file.".config/fish" = {
    source = ../../modules/fish;
    recursive = true;
  };

  # 内网 bytedcli 的 npx shim，让复制来的 `bytedcli ...` 能原样跑。
  # 用真文件而不是 fish alias：agent 起的是 zsh 子进程，alias 在那边不生效。
  home.file.".local/bin/bytedcli" = {
    source = ../../modules/bytedcli/bin/bytedcli;
    executable = true;
  };

  # 内网 emo（@ies/eden-monorepo）的 npx shim，同上。
  # 同包还导出 emox（独立入口 bin/emox.js，不是 emo 的别名），一并补上。
  home.file.".local/bin/emo" = {
    source = ../../modules/emo/bin/emo;
    executable = true;
  };

  home.file.".local/bin/emox" = {
    source = ../../modules/emo/bin/emox;
    executable = true;
  };

  # 内网 tcw（多仓协作工作区）的 shim。首次执行自动 bootstrap 官方 launcher，
  # 绕开它往 ~/.zshrc 塞 PATH 的那一步；~/.tcw 留给 tcw 自己写。详见脚本注释。
  home.file.".local/bin/tcw" = {
    source = ../../modules/tcw/bin/tcw;
    executable = true;
  };

  home.file."Library/Application Support/Trae CN/User" = {
    source = ../../modules/code-oss;
    recursive = true;
  };

  home.file."Library/Application Support/VSCodium/User" = {
    source = ../../modules/code-oss;
    recursive = true;
  };

  home.file.".claude/settings.json" = {
    source = ../../modules/claude-code/settings.json;
  };

  home.file.".claude/statusline.sh" = {
    source = ../../modules/claude-code/statusline.sh;
    executable = true;
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
