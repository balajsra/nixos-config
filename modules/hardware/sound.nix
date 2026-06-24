{ self, ... }:

{
  flake.nixosModules.sound =
    { pkgs, ... }:
    {
      services.pipewire = {
        enable = true;
        pulse.enable = true;
      };
    };
}
