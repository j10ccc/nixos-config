{ pkgs, ... }:

# zellij 一整套：配置、带 zjstatus 状态栏的默认布局、状态栏用的资源脚本，
# 以及给 agent 用的跨 pane 通信 CLI。三台主机共用，所以收在一个 module 里，
# 别再往各自的 home-manager.nix 里抄 home.file 了。
#
# zellij 本体不在这里装 —— Darwin 两台是系统级包（hosts/*/default.nix），
# ghostty 的 command 指的就是 /run/current-system/sw/bin/zellij 那个。
let
  zjstatus = pkgs.callPackage ../../pkgs/zjstatus { };
in
{
  home.file.".config/zellij/config.kdl" = {
    source = ./config.kdl;
  };

  home.file.".config/zellij/layouts/default.kdl" = {
    source = ./layouts/default.kdl;
  };

  # 布局里写的是 file:~/.config/zellij/plugins/zjstatus.wasm。
  # 实测 zellij 0.44 会把 ~ 展开成 $HOME，所以三台主机（家目录各不相同）能共用一份布局。
  home.file.".config/zellij/plugins/zjstatus.wasm" = {
    source = "${zjstatus}/bin/zjstatus.wasm";
  };

  # 状态栏右边那串 CPU/RAM/Swap，原来是 tmux status-right 调的 tmux-buddy。
  home.file.".local/bin/zellij-buddy" = {
    source = ./bin/zellij-buddy;
    executable = true;
  };

  home.file.".local/bin/zellij-bridge" = {
    source = ./bin/zellij-bridge;
    executable = true;
  };
}
