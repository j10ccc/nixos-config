{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.activation.piSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    lib.hm.generators.mkImpureConfigMerger {
      inherit pkgs;
      format = "json";
      empty = "{}";
      jqOperation = "$dynamic + $static";
      path = "${config.home.homeDirectory}/.pi/agent/settings.json";
      staticSettings = ./settings.json;
      mode = "600";
    }
  );
}
