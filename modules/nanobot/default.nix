# Prerequisites (not installed by this flake):
#   - nanobot binary at ~/.local/bin/nanobot. Install with:
#       uv tool install nanobot-ai
{ config, ... }:

{
  systemd.user.services.nanobot-gateway = {
    Unit = {
      Description = "nanobot - Ultra-Lightweight AI Assistant Gateway";
      After = [ "network.target" ];
    };
    Service = {
      WorkingDirectory = "${config.home.homeDirectory}";
      ExecStart = "${config.home.homeDirectory}/.local/bin/nanobot gateway";
      Restart = "always";
      RestartSec = 10;
      StandardOutput = "syslog";
      StandardError = "syslog";
      SyslogIdentifier = "nanobot";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
