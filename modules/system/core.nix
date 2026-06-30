{ self, ... }:

{
  flake.nixosModules.core =
    {
      config,
      lib,
      pkgs,
      inputs,
      ...
    }:
    {
      # Unfree Software: https://wiki.nixos.org/wiki/Unfree_Software
      nixpkgs.config.allowUnfree = true;

      # Modify pkgs to include a `stable` keyword to reference stable package repo
      # Unstable packages installed as `pkgs.<package-name>`
      # Stable packages installed as `pkgs.stable.<package-name>`
      nixpkgs.overlays = [
        (final: prev: {
          stable = import inputs.nixpkgs-stable {
            system = final.stdenv.hostPlatform.system;
            config = config.nixpkgs.config;
          };
        })
        inputs.dracula-signal-desktop.overlays
      ];

      # Run unpatched dynamic binaries on NixOS
      programs.nix-ld.enable = true;

      nix = {
        settings.experimental-features = [
          "nix-command"
          "flakes"
        ];

        # Storage Optimization: https://wiki.nixos.org/wiki/Storage_optimization
        # Optimising the store
        optimise = {
          automatic = true;
          dates = [ "01:00" ]; # Daily at 1:00 AM (or next boot)
        };

        # Garbage Collection
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 30d";
        };
      };

    };
}
