# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Rebuild commands

Every edit in this repo is inert until the active host is rebuilt. Always rebuild after making changes, matching the current host:

```sh
# Darwin hosts (full system via nix-darwin)
sudo darwin-rebuild switch --flake .#Breeze
sudo darwin-rebuild switch --flake .#Midnight

# Linux hosts (standalone home-manager)
home-manager switch --flake .#Goldenage
```

Determine the host from `hostname` if unsure. `sudo` on Darwin requires an interactive password (Touch ID inside tmux works after `pam_reattach` — see `lib/mksystem.nix`), so if running from a non-interactive context, the user must invoke it themselves.

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
- `modules/` — shared config payloads (ghostty, fish, tmux/smux, nvim, claude-code, etc.). These are **not** nix modules in most cases; they're plain config files that home-manager symlinks into `~/.config/...` via `home.file` entries in each user's `home-manager.nix`. Editing a file under `modules/fish/functions/foo.fish` directly changes what the user gets after rebuild.

When mapping "where does X come from":
1. Start at the host's entry in `flake.nix`.
2. Follow through `lib/mksystem.nix` to see which files are loaded.
3. For user-visible dotfiles, look at `home.file.".config/..."` entries in the relevant `home-manager.nix` — the `source = ../../modules/...` tells you which file to edit.

## Conventions

- Commit messages follow Conventional Commits with a scope, e.g. `feat(tmux): ...`, `feat(pam): ...`, `chore(fish): ...`. Scope generally matches the module or host touched.
- `master` is the default branch. PRs are opened against it.
- The three hosts share most of `modules/` — changes there affect every host that symlinks the file. If a change is host-specific, put it in `hosts/<name>/` or the user's `home-manager.nix` instead.
