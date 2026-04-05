{ withSystem, inputs, ... }:

{
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;

        # Unfree Software: https://nixos.wiki/wiki/Unfree_Software
        config.allowUnfree = true;
      };
    };
}
