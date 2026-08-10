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

      # List of insecure overrides
      nixpkgs.config.permittedInsecurePackages = [
        "electron-39.8.10"
      ];

      # List of overlays
      nixpkgs.overlays = [
        inputs.dracula-signal-desktop.overlays
        inputs.mango.overlays.default
        self.overlays.default
      ];

      # Run unpatched dynamic binaries on NixOS
      programs.nix-ld.enable = true;

      sops = {
        secrets."access_tokens_string" = {
          mode = "0444";
          neededForUsers = true;
        };
      };

      nix = {
        settings.experimental-features = [
          "nix-command"
          "flakes"
        ];

        # Storage Optimization: https://wiki.nixos.org/wiki/Storage_optimization
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

        extraOptions = ''
          !include ${config.sops.secrets."access_tokens_string".path}
        '';
      };
    };
}
