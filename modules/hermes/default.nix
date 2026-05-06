# Prerequisites (not installed by this flake):
#   - hermes-agent installed in the user's nix profile, e.g.
#       nix profile install git+file://$HOME/projects/hermes-agent?ref=refs/tags/v2026.4.30
#     which is what puts the `hermes` binary at ~/.nix-profile/bin/hermes.
{ config, ... }:

{
  systemd.user.services.hermes-gateway = {
    Unit = {
      Description = "hermes - Personal AI Assistant Gateway";
      After = [ "network.target" ];
    };
    Service = {
      WorkingDirectory = "${config.home.homeDirectory}";
      ExecStart = "${config.home.homeDirectory}/.nix-profile/bin/hermes gateway";
      Restart = "always";
      RestartSec = 10;
      StandardOutput = "journal";
      StandardError = "journal";
      SyslogIdentifier = "hermes-gateway";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
