{ nixpkgs, inputs }:

name:
{ system, user }:

let
  isDarwin = system == "darwin";

  hostConfig = ../hosts/${name};
  userOSConfig = ../users/${user};
  userHMConfig =
    if isDarwin then ../users/${user}/home-manager.nix
    else ../hosts/${name}/home-manager.nix;

  commonOverlays = [
    (final: prev: {
      # Work around nixpkgs direnv build setting `CGO_ENABLED=0` while
      # passing `-linkmode=external` (requires CGO).
      direnv = prev.direnv.overrideAttrs (old: {
        env = (old.env or { }) // { CGO_ENABLED = "1"; };
      });
    })
  ];

  # Darwin: full system configuration via nix-darwin
  darwinResult = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      ({ config, ... }: {
        nixpkgs.config.allowUnfree = true;
        nixpkgs.overlays = commonOverlays;
        nix.settings.experimental-features = "nix-command flakes";
        security.pam.services.sudo_local.touchIdAuth = true;
        security.pam.services.sudo_local.reattach = true;
        # @see https://github.com/zhaofengli/nix-homebrew/issues/5#issuecomment-2412587886
        homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
      })
      hostConfig
      userOSConfig
      inputs.home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${user} = import userHMConfig;
      }
      inputs.nix-homebrew.darwinModules.nix-homebrew
      {
        nix-homebrew = {
          # Install Homebrew under the default prefix
          enable = true;
          enableRosetta = false;
          user = user;
          taps = {
            "homebrew/homebrew-core" = inputs.homebrew-core;
            "homebrew/homebrew-cask" = inputs.homebrew-cask;
          };
          # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
          mutableTaps = false;
        };
      }
    ];
  };

  # Linux: standalone home-manager configuration
  linuxResult = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
      overlays = commonOverlays;
    };
    modules = [ userHMConfig ];
  };

in if isDarwin then darwinResult else linuxResult
