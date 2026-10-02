{ pkgs, ... }:

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

  # zellij 0.44+ 会把布局里的 ~ 展开成 $HOME，三台主机家目录不同也能共用一份布局。
  home.file.".config/zellij/plugins/zjstatus.wasm" = {
    source = "${zjstatus}/bin/zjstatus.wasm";
  };

  home.file.".local/bin/zellij-buddy" = {
    source = ./bin/zellij-buddy;
    executable = true;
  };
}
