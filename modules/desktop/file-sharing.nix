{ self, ... }:

{
  flake.nixosModules.file-sharing = {
    imports = [
      self.nixosModules.samba-client
      self.nixosModules.localsend
    ];
  };

  flake.nixosModules.samba-client =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf (config.features.file-sharing.samba-client.enable) {
        environment.systemPackages = [ pkgs.cifs-utils ];
      };

      imports = [
        self.nixosModules.samba-client-fileserver
        self.nixosModules.samba-client-mediaserver
      ];
    };

  flake.nixosModules.samba-client-fileserver =
    { lib, config, ... }:
    {
      config = lib.mkIf (config.features.file-sharing.samba-client.fileserver.enable) {
        sops.secrets = {
          "samba-client/fileserver" = { };
        };

        fileSystems."/mnt/fileserver" = {
          device = "//192.168.12.5/fileserver";
          fsType = "cifs";
          options =
            let
              uid = toString config.users.users.${config.primaryUser.username}.uid;
              gid = toString config.users.groups."${config.primaryUser.username}".gid;
              credentials = config.sops.secrets."samba-client/fileserver".path;
            in
            [
              "_netdev,credentials=${credentials},iocharset=utf8,uid=${uid},gid=${gid},rw,nofail"
            ];
        };
      };
    };

  flake.nixosModules.samba-client-mediaserver =
    { lib, config, ... }:
    {
      config = lib.mkIf (config.features.file-sharing.samba-client.mediaserver.enable) {
        sops.secrets = {
          "samba-client/mediaserver" = { };
        };

        fileSystems."/mnt/mediaserver" = {
          device = "//192.168.12.12/media";
          fsType = "cifs";
          options =
            let
              uid = toString config.users.users.${config.primaryUser.username}.uid;
              gid = toString config.users.groups."${config.primaryUser.username}".gid;
              credentials = config.sops.secrets."samba-client/mediaserver".path;
            in
            [
              "_netdev,credentials=${credentials},iocharset=utf8,uid=${uid},gid=${gid},rw,nofail"
            ];
        };
      };
    };

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
          "syncthing/gui_password" = { };

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
            passwordFile = config.sops.secrets."syncthing/gui_password".path;
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

  flake.nixosModules.localsend =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf (config.features.file-sharing.localsend.enable) {
        programs.localsend = {
          enable = true;
          openFirewall = true;
        };
      };
    };
}
