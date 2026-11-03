# cspell:words pipewire
{ pkgs, ... }:

let
  mkAgentContext = import ../agent-context/mk-context.nix pkgs;
  stopSound = pkgs.writeShellScript "codex-stop-sound" (
    if pkgs.stdenv.hostPlatform.isDarwin then
      "exec /usr/bin/afplay /System/Library/Sounds/Hero.aiff"
    else
      "exec ${pkgs.pipewire}/bin/pw-play /usr/share/sounds/freedesktop/stereo/complete.oga"
  );
in
{
  home.packages = [ pkgs.codex ];

  home.file.".codex/AGENTS.md".source = mkAgentContext {
    name = "codex-AGENTS.md";
    extras = [ ../agent-context/codex.md ];
  };

  home.file.".codex/hooks.json".text = builtins.toJSON {
    hooks.Stop = [
      {
        hooks = [
          {
            type = "command";
            command = "${stopSound}";
            async = true;
            timeout = 10;
          }
        ];
      }
    ];
  };
}
