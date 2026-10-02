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

    # Don't follow our nixpkgs: herdr's flake builds with rust-overlay on
    # its own nixpkgs pin. Consume packages.<system>.herdr, not overlays.default
    # (that overlay also injects rust-overlay into the whole package set).
    herdr.url = "github:herdrdev/herdr/v0.9.1";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      home-manager,
      nixpkgs,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      herdr,
    }:
    let
      mkSystem = import ./lib/mksystem.nix { inherit nixpkgs inputs; };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations.Breeze = mkSystem "breeze" {
        system = "darwin";
        user = "j10c";
      };
      darwinConfigurations.Midnight = mkSystem "midnight" {
        system = "darwin";
        user = "bytedance";
      };

      # Build NixOS home-manager flake using:
      # $ home-manager switch --flake .#j10c@goldenage
      homeConfigurations.Goldenage = mkSystem "goldenage" {
        system = "linux";
        user = "j10c";
      };
    };
}
