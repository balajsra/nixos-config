{ self, ... }:

{
  flake.nixosModules.phone = {
    imports = [
      self.nixosModules.kdeconnect
    ];
  };

  flake.homeModules.phone = {
    imports = [
      self.homeModules.android-tools
    ];
  };

  flake.nixosModules.kdeconnect = { config, lib, ... }: {
    config = lib.mkIf (config.features.phone.kdeconnect.enable) {
      # https://wiki.nixos.org/wiki/KDE_Connect
      programs.kdeconnect.enable = true;

      networking.firewall = rec {
        allowedTCPPortRanges = [
          {
            from = 1714;
            to = 1764;
          }
        ];
        allowedUDPPortRanges = allowedTCPPortRanges;
      };
    };
  };

  flake.homeModules.android-tools =
    {
      pkgs,
      osConfig,
      lib,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.phone.android-tools.enable) {
        home.packages = with pkgs; [
          android-tools
        ];
      };
    };
}
