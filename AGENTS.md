# Repository conventions

Instructions for all agents. `CLAUDE.md` is only `@AGENTS.md`; do not duplicate this file there.

## Rebuild commands

Every edit in this repo is inert until the active host is rebuilt. Always rebuild after making changes, matching the current host:

```sh
# Darwin hosts (full system via nix-darwin)
sudo darwin-rebuild switch --flake .#Breeze
sudo darwin-rebuild switch --flake .#Midnight

# Linux hosts (standalone home-manager)
home-manager switch --flake .#Goldenage
```

Determine the host from `hostname` if unsure. `sudo` on Darwin requires an interactive password (Touch ID inside a multiplexer like zellij works after `pam_reattach` — see `security.pam.services.sudo_local.reattach` in `lib/mksystem.nix`), so if running from a non-interactive context, the user must invoke it themselves.

### Flake + new files gotcha

Nix flakes only see files tracked by git. **Newly created files must be `git add`'d before `darwin-rebuild` / `home-manager switch` will pick them up** — otherwise the rebuild silently ignores them and you'll debug a "file not found" symptom that isn't really about the file. Existing-file edits don't need staging.

## Architecture

The flake defines three hosts, dispatched through a single helper:

- `flake.nix` — declares `darwinConfigurations.{Breeze,Midnight}` and `homeConfigurations.Goldenage`, all built via `mkSystem`.
- `lib/mksystem.nix` — the dispatcher. Given `(name, {system, user})`, it branches:
  - **Darwin** → full `nix-darwin.lib.darwinSystem` with `home-manager` as a darwin module and `nix-homebrew` for Homebrew taps/casks.
  - **Linux** → standalone `home-manager.lib.homeManagerConfiguration` (no system-level NixOS config in this repo).
- `hosts/<name>/` — host-specific config.
  - Darwin hosts (`breeze`, `midnight`) have `default.nix` providing system packages, `system.defaults`, keyboard, fonts, etc. Their home-manager config lives at `users/<user>/home-manager.nix`.
  - `goldenage` (Linux) only has `home-manager.nix` because the Linux build is home-manager-only — there is no NixOS system config for it in this repo.
- `users/<user>/` — user-level config.
  - `default.nix` is a nix-darwin system module (only used on Darwin builds).
  - `home-manager.nix` is the home-manager config used on Darwin. On Linux, the equivalent file is `hosts/goldenage/home-manager.nix` instead.
- `modules/` — shared config payloads (ghostty, fish, zellij, nvim, claude-code, etc.). These are **not** nix modules in most cases; they're plain config files that home-manager symlinks into `~/.config/...` via `home.file` entries in each user's `home-manager.nix`. Editing a file under `modules/fish/functions/foo.fish` directly changes what the user gets after rebuild.

When mapping "where does X come from":
1. Start at the host's entry in `flake.nix`.
2. Follow through `lib/mksystem.nix` to see which files are loaded.
3. For user-visible dotfiles, look at `home.file.".config/..."` entries in the relevant `home-manager.nix` — the `source = ../../modules/...` tells you which file to edit.

## Conventions

- Commit messages follow Conventional Commits with a scope, e.g. `feat(tmux): ...`, `feat(pam): ...`, `chore(fish): ...`. Scope generally matches the module or host touched.
- `master` is the default branch. PRs are opened against it.
- The three hosts share most of `modules/` — changes there affect every host that symlinks the file. If a change is host-specific, put it in `hosts/<name>/` or the user's `home-manager.nix` instead.

## Reporting: plain language, with evidence

Anything the user reads must assume they did not watch the intermediate steps. Internal notes — todos, scratch, messages between subagents — may be compressed. The part where the user has to decide, review, or approve is written for someone who was not there.

- **No invented terminology.** Coinages that look like real jargon are banned from user-facing output — in Chinese the two-character compounds (归户 / 死门 / 对拍 / 全绿 / 哑火 / 终审干净), in English the dense metaphor-stacked register people call "Claudish". If a standard phrase exists, use it: "all 15 tests pass", not "全绿".
- **No metaphors for engineering objects.** Not 皮 / 腿 / 账本 / 铁律, not "the arm", not "it bites". Name the file, the module, the rule.
- **Every claim carries evidence**: the command that ran, its output, which files changed, how to reproduce. `exit 0` is not "task done", a green build is not "goal met", a successful tool call is not "the change took effect". No evidence means not done.
- **If the cause is unknown, say the cause is not established.** Do not supply a plausible-sounding story in its place.
- **Do not say "你拍板" / "your call" instead of giving options.** When a decision is genuinely the user's, list the choices, what each one costs, and your recommendation.
- **Do not let jargon survive a round.** If the user echoes a coined term back, do not adopt it. If you coined one last turn, switch to the standard phrasing this turn. Rewrite subagent output into structured results rather than inheriting its wording.

This is a rule rather than a style note because the failure mode is self-reinforcing. Long, multi-subagent runs are scored on whether the task completed, never on whether the report was understood; meanwhile each turn's shorthand goes back into the context window as the most recent sample of how to write, so a private dialect compounds until something cuts it off. Asking for "plainer language" does not work — the coinages already read as plain to whoever wrote them. The mechanism has to be banned by name.
