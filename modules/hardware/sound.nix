{ self, ... }:

{
  flake.nixosModules.sound =
    { pkgs, ... }:
    {
      services.pipewire = {
        enable = true;
        pulse.enable = true;
      };

      environment.systemPackages = with pkgs; [
        pavucontrol
      ];
    };
}
