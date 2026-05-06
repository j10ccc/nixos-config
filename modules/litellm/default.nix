# Prerequisites (not installed by this flake):
#   - same docker + docker-group prerequisites as langfuse
#   - a litellm deployment dir at ~/projects/litellm with a
#     docker-compose.yml (config + proxy stack)
{ config, ... }:

{
  systemd.user.services.litellm = {
    Unit = {
      Description = "LiteLLM proxy (docker compose)";
      Documentation = [ "https://docs.litellm.ai/docs/proxy/configs" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "${config.home.homeDirectory}/projects/litellm";
      TimeoutStartSec = 300;
      ExecStart = ''/usr/bin/sg docker -c "/usr/bin/docker compose up -d --wait"'';
      ExecStop = ''/usr/bin/sg docker -c "/usr/bin/docker compose stop"'';
      ExecReload = ''/usr/bin/sg docker -c "/usr/bin/docker compose up -d --wait"'';
    };
    # Intentionally no Install: same shape as langfuse — docker's
    # restart: unless-stopped handles reboot resurrection. Start with:
    #   systemctl --user start litellm
  };
}
