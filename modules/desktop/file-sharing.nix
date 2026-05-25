{ self, ... }:

{
  flake.homeModules.file-sharing = {
    imports = [
      self.homeModules.nextcloud
      self.homeModules.syncthing
    ];
  };

  flake.homeModules.nextcloud =
    {
      osConfig,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.file-sharing.nextcloud.enable) {
        # https://nixos.wiki/wiki/Nextcloud
        home.packages = with pkgs; [
          nextcloud-client
        ];
      };
    };

  flake.homeModules.syncthing =
    {
      osConfig,
      config,
      lib,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.file-sharing.syncthing.enable) {
        sops.secrets = {
          "passwords/${osConfig.networking.hostName}/${osConfig.primaryUser.username}" = { };

          "syncthing/devices/fileserver" = { };
          "syncthing/devices/pixel-tablet" = { };
          "syncthing/devices/zfold4" = { };
          "syncthing/devices/steam-deck" = { };
          "syncthing/devices/oryp7" = { };
          "syncthing/devices/powerspec" = { };

          "syncthing/folders/calibre-library" = { };
          "syncthing/folders/second-brain" = { };
        };

        # https://nixos.wiki/wiki/Syncthing
        services.syncthing = {
          enable = true;
          tray.enable = true;
          extraOptions = [
            "--no-browser"
            "--logfile=default"
          ];
          guiCredentials = {
            username = osConfig.primaryUser.username;
            passwordFile =
              config.sops.secrets."passwords/${osConfig.networking.hostName}/${osConfig.primaryUser.username}".path;
          };
          overrideDevices = true;
          overrideFolders = true;
          settings = {
            devices = {
              fileserver = {
                name = "Fileserver";
                id = config.sops.secrets."syncthing/devices/fileserver".path;
              };
              pixel-tablet = {
                name = "Pixel Tablet";
                id = config.sops.secrets."syncthing/devices/pixel-tablet".path;
              };
              zfold4 = {
                name = "Samsung Galaxy Z Fold 4";
                id = config.sops.secrets."syncthing/devices/zfold4".path;
              };
              steam-deck = {
                name = "Steam Deck";
                id = config.sops.secrets."syncthing/devices/steam-deck".path;
              };
              oryp7 = {
                name = "System76 Oryx Pro 7";
                id = config.sops.secrets."syncthing/devices/oryp7".path;
              };
              powerspec = {
                name = "PowerSpec G753";
                id = config.sops.secrets."syncthing/devices/powerspec".path;
              };
            };
            folders = {
              calibre-library = {
                enable = true;
                devices = [
                  "fileserver"
                  "oryp7"
                  "powerspec"
                ];
                id = config.sops.secrets."syncthing/folders/calibre-library".path;
                label = "Calibre Library";
                path = "/home/${osConfig.primaryUser.username}/Data/Calibre Library";
                type = "sendreceive";
                versioning = null;
              };
              second-brain = {
                enable = true;
                devices = [
                  "fileserver"
                  "pixel-tablet"
                  "zfold4"
                  "steam-deck"
                  "oryp7"
                  "powerspec"
                ];
                id = config.sops.secrets."syncthing/folders/second-brain".path;
                label = "Second Brain";
                path = "/home/${osConfig.primaryUser.username}/Data/Second Brain";
                type = "sendreceive";
                versioning = null;
              };
            };
            gui = {
              theme = "black";
            };
            options = {
              localAnnounceEnabled = true;
              relaysEnabled = true;
              urAccepted = -1;
            };
          };
        };
      };
    };
}
