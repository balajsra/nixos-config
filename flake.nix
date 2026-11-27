{
  description = "Flake of Sravan's NixOS";

  outputs =
    { self, ... }:
    let
      inputs = import ./.tack // {
        inherit self;
      };
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
