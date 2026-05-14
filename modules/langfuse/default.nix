# Prerequisites (not installed by this flake):
#   - docker engine + docker compose plugin on PATH
#   - the `docker` system group, with this user as a member
#     (`sg docker -c ...` below depends on group membership)
#   - the langfuse deployment repo cloned to ~/projects/langfuse,
#     containing a docker-compose.yml. Upstream:
#       https://github.com/langfuse/langfuse
{ config, ... }:

{
  systemd.user.services.langfuse = {
    Unit = {
      Description = "Langfuse self-hosted (docker compose)";
      Documentation = [ "https://langfuse.com/self-hosting" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "${config.home.homeDirectory}/projects/langfuse";
      TimeoutStartSec = 600;
      # `sg docker` keeps this working even if the user manager started
      # before j10c was added to the docker group.
      ExecStart = ''/usr/bin/sg docker -c "/usr/bin/docker compose up -d --wait"'';
      # `stop` (not `down`) preserves containers so docker's
      # restart: unless-stopped resurrects them on next boot.
      ExecStop = ''/usr/bin/sg docker -c "/usr/bin/docker compose stop"'';
      ExecReload = ''/usr/bin/sg docker -c "/usr/bin/docker compose up -d --wait"'';
    };
    # Intentionally no Install: boot autostart is delegated to docker's
    # restart: unless-stopped policy. Without `loginctl enable-linger`
    # a user-mode unit wouldn't autostart anyway. Start manually with:
    #   systemctl --user start langfuse
  };
}
