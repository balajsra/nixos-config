{ self, ... }:

{
  flake.nixosModules.system76 =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.features.hardware.system76.enable) {
        # https://support.system76.com/articles/system76-software/#nixos
        hardware.system76.enableAll = true;

        # FIX: Allow the system76 power daemon to run so it can communicate
        # directly with your laptop's firmware/Embedded Controller (EC)
        hardware.system76.power-daemon.enable = true;

        # Keep this disabled. system76-power completely replaces power-profiles-daemon,
        # and running both simultaneously causes systemd service conflicts.
        services.power-profiles-daemon.enable = false;
      };
    };
}
