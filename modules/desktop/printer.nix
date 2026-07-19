{ self, ... }:

{
  flake.nixosModules.printer = {
    imports = [
      self.nixosModules.printing
      self.nixosModules.scanning
    ];
  };

  flake.nixosModules.printing =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf (config.features.hardware.printing.enable) {
        # https://wiki.nixos.org/wiki/Printing
        services.avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
        };

        services.printing = {
          enable = true;
          drivers = with pkgs; [
            cups-filters
            cups-browsed
            hplip
            hplipWithPlugin
          ];
        };
      };
    };

  flake.nixosModules.scanning =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf (config.features.hardware.scanning.enable) {
        # https://wiki.nixos.org/wiki/Scanners
        hardware.sane = {
          enable = true;
          extraBackends = with pkgs; [
            hplipWithPlugin
          ];
        };

        users.users."${config.primaryUser.username}".extraGroups = [
          "scanner"
          "lp"
        ];

        environment.systemPackages = with pkgs; [
          kdePackages.skanlite
        ];
      };
    };
}
