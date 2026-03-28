{
  description = "Nix configuration for j10c's machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, home-manager, nixpkgs, nix-homebrew
    , homebrew-core, homebrew-cask, }:
    let mkSystem = import ./lib/mksystem.nix { inherit nixpkgs inputs; };
    in {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations.Breeze =
        mkSystem "breeze" { system = "darwin"; user = "j10c"; };
      darwinConfigurations.Midnight =
        mkSystem "midnight" { system = "darwin"; user = "bytedance"; };

      # Build NixOS home-manager flake using:
      # $ home-manager switch --flake .#j10c@goldenage
      homeConfigurations."j10c@goldenage" =
        mkSystem "goldenage" { system = "linux"; user = "j10c"; };
    };
}
