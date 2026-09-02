{ self, inputs, ... }:

{
  # Export the overlay on the flake output applied with `inputs`
  flake.overlays.default = import "${inputs.self}/pkgs/default.nix" inputs;

  perSystem =
    {
      pkgs,
      system,
      lib,
      ...
    }:
    {
      # Apply the overlay to `pkgs` for all `perSystem` outputs in flake-parts
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ self.overlays.default ];
      };

      # Automatically filter and expose top-level derivations for `nix build .#<pkg>`
      packages = lib.filterAttrs (_: v: lib.isDerivation v) (self.overlays.default pkgs pkgs);
    };
}
