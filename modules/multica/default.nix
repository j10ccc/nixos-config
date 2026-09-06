# Prerequisites (not installed by this flake):
#   - the multica CLI at ~/.local/bin/multica. Installed imperatively on
#     purpose: `multica update` self-replaces the binary, which a read-only
#     nix store path would break. Upstream releases:
#       https://github.com/multica-ai/multica/releases
#   - `multica setup self-host` already run once. The PAT and watched
#     workspaces live in ~/.multica/config.json — mutable state, stays
#     outside nix.
#   - the self-hosted server stack up (docker compose in ~/projects/multica).
#
# Note: tasks execute with this user's full privileges — whatever j10c can
# read or write, an assigned agent can too.
{ config, ... }:

{
  systemd.user.services.multica-daemon = {
    Unit = {
      Description = "Multica local agent runtime daemon";
      Documentation = [
        "https://github.com/multica-ai/multica/blob/main/CLI_AND_DAEMON.md"
      ];
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "simple";
      # --foreground keeps the process in systemd's hands. Status still works:
      # `multica daemon status` probes a health port, not the pid file.
      ExecStart = "${config.home.homeDirectory}/.local/bin/multica daemon start --foreground";
      Restart = "always";
      RestartSec = 10;
      # The daemon shells out to the agent CLIs (claude, hermes, gemini …),
      # which live in the nix profile. A user unit does not inherit the login
      # shell's PATH, so it has to be spelled out here or nothing is detected.
      Environment = [
        "PATH=${config.home.homeDirectory}/.nix-profile/bin:${config.home.homeDirectory}/.local/bin:/usr/local/bin:/usr/bin:/bin"
        "XDG_RUNTIME_DIR=%t"
      ];
      StandardOutput = "journal";
      StandardError = "journal";
      SyslogIdentifier = "multica-daemon";
    };
    # Linger is enabled for j10c, so default.target starts this at boot
    # without needing a graphical login.
    Install.WantedBy = [ "default.target" ];
  };
}
