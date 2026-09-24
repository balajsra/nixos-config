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
          drivers =
            with pkgs;
            [
              cups-filters
              cups-browsed
            ]
            ++ lib.optionals config.features.hardware.printing.hp.enable [
              hplip
              hplipWithPlugin
            ]
            ++ lib.optionals config.features.hardware.printing.epson.enable [
              epson-escpr
              epson-escpr2
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
          extraBackends =
            lib.optionals config.features.hardware.scanning.hp.enable [ pkgs.hplipWithPlugin ]
            ++ lib.optionals config.features.hardware.scanning.epson.enable [ pkgs.sane-airscan ];
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
