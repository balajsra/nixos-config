{ self, ... }:

{
  flake.nixosModules.file-sharing = {
    imports = [
      self.nixosModules.samba-client
      self.nixosModules.localsend
      self.nixosModules.syncthing
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

  flake.nixosModules.syncthing =
    {
      config,
      lib,
      ...
    }:
    {
      config = lib.mkIf (config.features.file-sharing.syncthing.enable) {
        sops.secrets = {
          "syncthing/gui_password" = { };

          "syncthing/devices/fileserver" = { };
          "syncthing/devices/pixel-tablet" = { };
          "syncthing/devices/s26ultra" = { };
          "syncthing/devices/steam-deck" = { };
          "syncthing/devices/oryp7" = { };
          "syncthing/devices/powerspec" = { };

          "syncthing/folders/calibre-library" = { };
          "syncthing/folders/second-brain" = { };
        };

        # https://wiki.nixos.org/wiki/Syncthing
        services.syncthing = {
          enable = true;
          openDefaultPorts = true;
          extraFlags = [
            "--no-default-folder" # Don't create default ~/Sync folder
          ];
          guiPasswordFile = config.sops.secrets."syncthing/gui_password".path;
          overrideDevices = true;
          overrideFolders = true;
          settings = {
            gui.user = config.primaryUser.username;
            devices = {
              fileserver = {
                name = "Fileserver";
                id = config.sops.secrets."syncthing/devices/fileserver".path;
              };
              pixel-tablet = {
                name = "Pixel Tablet";
                id = config.sops.secrets."syncthing/devices/pixel-tablet".path;
              };
              s26ultra = {
                name = "Samsung Galaxy S26 Ultra";
                id = config.sops.secrets."syncthing/devices/s26ultra".path;
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
              "Calibre Library" = {
                enable = true;
                devices = [
                  "fileserver"
                  "oryp7"
                  "powerspec"
                ];
                id = config.sops.secrets."syncthing/folders/calibre-library".path;
                label = "Calibre Library";
                path = "/home/${config.primaryUser.username}/Data/Calibre Library";
                type = "receiveonly";
                versioning = null;
              };
              "Second Brain" = {
                enable = true;
                devices = [
                  "fileserver"
                  "pixel-tablet"
                  "s26ultra"
                  "steam-deck"
                  "oryp7"
                  "powerspec"
                ];
                id = config.sops.secrets."syncthing/folders/second-brain".path;
                label = "Second Brain";
                path = "/home/${config.primaryUser.username}/Data/Second Brain";
                type = "receiveonly";
                versioning = null;
              };
            };
          };
        };
      };
    };

  flake.homeModules.file-sharing = {
    imports = [
      self.homeModules.nextcloud
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
        # https://wiki.nixos.org/wiki/Nextcloud
        home.packages = with pkgs; [
          nextcloud-client
        ];
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
