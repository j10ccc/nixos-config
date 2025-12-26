{ pkgs, ... }:

{
  users.users.j10c = {
    name = "j10c";
    home = /Users/j10c;
    shell = pkgs.fish;
  };

  homebrew = {
    enable = true;
    brews = [ "mas" ];
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
      "docker-desktop"
      "obsidian"
      "vscodium"
      "clash-verge-rev"
      "apifox"
      "wechatwebdevtools"
      "adobe-creative-cloud"
      "moonlight"
      "antigravity"
      "ghostty"
    ];
    masApps = {
      "TickTick" = 966085870;
      "WeChat" = 836500024;
      "QQ" = 451108668;
      "Feishu" = 1551632588;
    };
    onActivation = {
      upgrade = true;
      cleanup = "zap";
    };
  };

  programs.fish.enable = true;

  system.primaryUser = "j10c";
}
