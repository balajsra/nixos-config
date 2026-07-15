{ self, config, ... }:

{
  flake.nixosModules.gaming = {
    imports = [
      self.nixosModules.gamemode
      self.nixosModules.gamescope
      self.nixosModules.steam
      self.nixosModules.wine
      self.nixosModules.vkbasalt
    ];
  };

  flake.homeModules.gaming = {
    imports = [
      self.homeModules.lutris
      self.homeModules.mangohud
      self.homeModules.chiaki
    ];
  };

  flake.nixosModules.gamemode =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.features.gaming.gamemode.enable) {
        # https://wiki.nixos.org/wiki/GameMode
        users.users."${config.primaryUser.username}".extraGroups = [ "gamemode" ];
        programs.gamemode = {
          enable = true;
          enableRenice = true;
          settings = {
            general = {
              reaper_freq = 5;
              desiredgov = "performance";
              defaultgov = "powersave";
              igpu_desiredgov = "powersave";
              igpu_power_threshold = 0.3;
              softrealtime = "off";
              renice = 10;
              ioprio = 0;
              inhibit_screensaver = 1;
              disable_splitlock = 1;
            };
          };
        };
      };
    };

  flake.nixosModules.gamescope = { lib, config, ... }: {
    config = lib.mkIf (config.features.gaming.gamescope.enable) {
      programs.gamescope = {
        enable = true;
        enableWsi = true;
        capSysNice = false;
      };
    };
  };

  flake.nixosModules.steam =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf (config.features.gaming.steam.enable) {
        # https://wiki.nixos.org/wiki/Steam
        programs.steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = false;
          extraCompatPackages = with pkgs; [
            proton-ge-bin
          ];
          extraPackages = [
            pkgs.hidapi # Dependency for Steam Controller (2026)
          ];
        };

        environment.systemPackages = with pkgs; [
          steam-run # Allows running games that expect an FHS-like environment
        ];
      };
    };

  flake.nixosModules.wine =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      config = lib.mkIf (config.features.gaming.wine.enable) {
        environment.systemPackages = with pkgs; [
          # https://wiki.nixos.org/wiki/Wine
          wineWow64Packages.stable
          winetricks
          protonplus
          protontricks
          protonup-qt
        ];
      };
    };

  flake.nixosModules.vkbasalt =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      config = lib.mkIf (config.features.gaming.vkbasalt.enable) {
        environment.systemPackages = with pkgs; [
          vkbasalt
          vkbasalt-cli
        ];
      };
    };

  flake.homeModules.lutris =
    {
      pkgs,
      osConfig,
      lib,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.gaming.lutris.enable) {
        programs.lutris = {
          enable = true;
          package = pkgs.lutris;
        };

        # TODO: Add Lutris settings
      };
    };

  flake.homeModules.mangohud = { lib, osConfig, ... }: {
    config = lib.mkIf (osConfig.features.gaming.mangohud.enable) {
      programs.mangohud.enable = true;
      # TODO: Add mangohud settings
    };
  };

  flake.homeModules.chiaki =
    {
      pkgs,
      lib,
      osConfig,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.gaming.chiaki.enable) {
        home.packages = with pkgs; [
          chiaki-ng
        ];
      };
    };
}
