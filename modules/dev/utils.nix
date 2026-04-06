{ self, ... }:
{
  flake.nixosModules.utils =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        mlocate
        sudo
        tree
        wget
      ];
    };
}
