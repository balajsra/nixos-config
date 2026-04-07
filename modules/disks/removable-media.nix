{ self, ... }:

{
  flake.nixosModules.removable-media =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        udiskie
        udisks
      ];
    };
}
