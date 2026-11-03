{ lib, pkgs, ... }:

{
  home.activation.piSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.python3}/bin/python3 ${./merge-settings.py} ${./settings.json} "$HOME/.pi/agent/settings.json"
  '';
}
