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

          "syncthing/devices/fileserver/id" = { };
          "syncthing/devices/pixel-tablet/id" = { };
          "syncthing/devices/s26ultra/id" = { };
          "syncthing/devices/steam-deck/id" = { };

          "syncthing/devices/oryp7/id" = { };
          "syncthing/devices/oryp7/cert" = { };
          "syncthing/devices/oryp7/key" = { };

          "syncthing/devices/powerspec/id" = { };
          "syncthing/devices/powerspec/cert" = {
            path = "/run/secrets/syncthing/cert.pem";
          };
          "syncthing/devices/powerspec/key" = {
            path = "/run/secrets/syncthing/key.pem";
          };

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
          cert = config.sops.secrets."syncthing/devices/${config.networking.hostName}/cert".path;
          key = config.sops.secrets."syncthing/devices/${config.networking.hostName}/key".path;
          guiPasswordFile = config.sops.secrets."syncthing/gui_password".path;
          overrideDevices = true;
          overrideFolders = true;
          settings = {
            gui.user = config.primaryUser.username;

            # Dynamically filter out the device if its key matches the current hostname
            devices = lib.filterAttrs (n: _: n != config.networking.hostName) {
              fileserver = {
                name = "Fileserver";
                id = config.sops.secrets."syncthing/devices/fileserver/id".path;
              };
              pixel-tablet = {
                name = "Pixel Tablet";
                id = config.sops.secrets."syncthing/devices/pixel-tablet/id".path;
              };
              s26ultra = {
                name = "Samsung Galaxy S26 Ultra";
                id = config.sops.secrets."syncthing/devices/s26ultra/id".path;
              };
              steam-deck = {
                name = "Steam Deck";
                id = config.sops.secrets."syncthing/devices/steam-deck/id".path;
              };
              oryp7 = {
                name = "System76 Oryx Pro 7";
                id = config.sops.secrets."syncthing/devices/oryp7/id".path;
              };
              powerspec = {
                name = "PowerSpec G753";
                id = config.sops.secrets."syncthing/devices/powerspec/id".path;
              };
            };
            folders = {
              "Calibre Library" = {
                enable = true;
                devices = lib.filter (d: d != config.networking.hostName) [
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
                devices = lib.filter (d: d != config.networking.hostName) [
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
