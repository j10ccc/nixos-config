{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    neovim
    fish
    eza
    zoxide
    ripgrep
    fd
    direnv
    vivid
    nixfmt-classic
  ];

  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-emoji
    nerd-fonts.blex-mono
    nerd-fonts.monaspace
  ];

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  system = {
    # Set Git commit hash for darwin-version.
    configurationRevision = config.rev or config.dirtyRev or null;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 5;

    defaults = {
      NSGlobalDomain = {
        ApplePressAndHoldEnabled = false;
        AppleShowAllExtensions = true;
        "com.apple.keyboard.fnState" = true;
      };
      WindowManager.GloballyEnabled = true;
      finder = {
        ShowPathbar = true;
        AppleShowAllExtensions = true;
      };
      hitoolbox.AppleFnUsageType = "Show Emoji & Symbols";
      menuExtraClock = {
        Show24Hour = false;
        ShowAMPM = true;
        ShowDate = 2;
        ShowDayOfWeek = false;
        ShowSeconds = false;
        ShowDayOfMonth = false;
      };
      dock = {
        wvous-tl-corner = 4; # Show desktop
        autohide = false;
      };
      trackpad = {
        TrackpadThreeFingerDrag = true;
        TrackpadThreeFingerTapGesture = 2;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  nix.enable = false;
}
