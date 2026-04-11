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
    ];
  };

  flake.nixosModules.gamemode =
    { config, ... }:
    {
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

  flake.nixosModules.gamescope = {
    programs.gamescope.enable = true;
  };

  flake.nixosModules.steam = {
    # https://wiki.nixos.org/wiki/Steam
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = false;
    };
  };

  flake.nixosModules.wine =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # https://wiki.nixos.org/wiki/Wine
        wineWow64Packages.stable
        winetricks
        protonplus
        protontricks
      ];
    };

  flake.nixosModules.vkbasalt =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        vkbasalt
        vkbasalt-cli
      ];
    };

  flake.homeModules.lutris = {
    # TODO: Add Lutris settings
    programs.lutris = {
      enable = true;
    };
  };

  flake.homeModules.mangohud = {
    programs.mangohud.enable = true;
    # TODO: Add mangohud settings
  };
}
