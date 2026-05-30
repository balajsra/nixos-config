{ self, ... }:

{
  flake.nixosModules.system76 =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.features.hardware.system76.enable) {
        # This brings in the kernel modules that make your Oryx Pro's hardware tick
        hardware.system76.enableAll = true;

        # KILL THE DAEMON: It causes the crash by looking for non-existent Ubuntu paths
        hardware.system76.power-daemon.enable = false;
        services.power-profiles-daemon.enable = false;
      };
    };
}
