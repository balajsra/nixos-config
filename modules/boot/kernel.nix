{ self, inputs, ... }:

{
  flake.nixosModules.kernel =
    { pkgs, config, ... }:
    let
      kernel = config.features.boot.kernel;
      kernelMap = {
        "vanilla-stable" = pkgs.linuxPackages;
        "vanilla-latest" = pkgs.linuxPackages_latest;
        "liqorix-latest" = pkgs.linuxPackages_lqx;
        "xanmod-stable" = pkgs.linuxPackages_xanmod_stable;
        "xanmod-latest" = pkgs.linuxPackages_xanmod_latest;
        "zen-latest" = pkgs.linuxPackages_zen;
      };
    in
    {
      config = {
        # https://nixos.wiki/wiki/Linux_kernel
        boot.kernelPackages = kernelMap.${kernel};
      };
    };
}
