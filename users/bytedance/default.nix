{ pkgs, ... }:

{
  users.users.bytedance = {
    name = "bytedance";
    home = /Users/bytedance;
    shell = pkgs.fish;
  };

  homebrew = {
    enable = true;
    brews = [ "mas" "ast-grep" ];
    casks = [
      "snipaste"
      "maccy"
      "iina"
      "ungoogled-chromium"
      "stats"
      "the-unarchiver"
      "telegram"
      "tencent-lemon"
      "aldente"
      "apifox"
      "google-chrome"
      "ghostty"
    ];
    masApps = {
      "TickTick" = 966085870;
      "Feishu" = 1551632588;
    };
    onActivation = {
      upgrade = true;
      cleanup = "zap";
    };
  };

  programs.fish.enable = true;

  system.primaryUser = "bytedance";
}
