# Builds one agent's global context file.
#
# Every agent reads a different path — Claude Code takes ~/.claude/CLAUDE.md, pi
# takes ~/.pi/agent/AGENTS.md — but nearly every rule holds for both. So the body
# lives once in shared.md, and each caller appends only what is specific to its
# agent: tool names, hooks, directory taboos. Those per-agent fragments sit next
# to shared.md in this directory, one per agent (claude-code.md, pi.md).
#
#   let
#     mkAgentContext = import ../../modules/agent-context/mk-context.nix pkgs;
#   in
#   {
#     home.file.".claude/CLAUDE.md".source = mkAgentContext {
#       name = "CLAUDE.md";
#       extras = [ ../../modules/agent-context/claude-code.md ];
#     };
#   }
pkgs:
{
  name,
  extras ? [ ],
}:
pkgs.writeText name (
  builtins.concatStringsSep "\n" (map builtins.readFile ([ ./shared.md ] ++ extras))
)
