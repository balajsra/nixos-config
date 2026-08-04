{ self, inputs, ... }:

{
  # Export the overlay on the flake output so NixOS/HomeManager can reference it
  flake.overlays.default = final: prev: (import ../../pkgs final);

  perSystem = { system, ... }: {
    # Expose packages so `nix build .#<package-name>` works directly
    packages = import ../../pkgs (import inputs.nixpkgs { inherit system; });

    # Apply the overlay to `pkgs` for all `perSystem` outputs in flake-parts
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [ self.overlays.default ];
    };
  };
}
