# Prerequisites (not installed by this flake):
#   - sunshine system package (provides /usr/bin/sunshine). On Ubuntu:
#       sudo apt install sunshine
#   - an active X session on DISPLAY=:0 (sunshine needs a graphical
#     session to capture).
{ ... }:

{
  systemd.user.services.sunshine = {
    Unit = {
      Description = "Sunshine - Self-hosted game stream host for Moonlight";
      After = [ "network.target" "graphical-session.target" ];
    };
    Service = {
      ExecStart = "/usr/bin/sunshine";
      Restart = "always";
      RestartSec = 5;
      Environment = [
        "DISPLAY=:0"
        "XDG_RUNTIME_DIR=%t"
      ];
      StandardOutput = "syslog";
      StandardError = "syslog";
      SyslogIdentifier = "sunshine";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
