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

  flake.homeModules.syncthing =
    {
      config,
      osConfig,
      lib,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.file-sharing.syncthing.enable) {
        sops.secrets = {
          "syncthing/gui_password" = { };

          "syncthing/devices/${osConfig.networking.hostName}/cert" = {
            path = "/home/${osConfig.primaryUser.username}/.local/state/syncthing/cert.pem";
            mode = "0600";
          };
          "syncthing/devices/${osConfig.networking.hostName}/key" = {
            path = "/home/${osConfig.primaryUser.username}/.local/state/syncthing/key.pem";
            mode = "0600";
          };
        };

        # https://wiki.nixos.org/wiki/Syncthing
        services.syncthing = {
          enable = true;
          tray.enable = true;

          guiCredentials = {
            username = osConfig.primaryUser.username;
            passwordFile = config.sops.secrets."syncthing/gui_password".path;
          };

          overrideDevices = true;
          overrideFolders = true;

          settings = {
            # Dynamically filter out the device if its key matches the current hostname
            devices = lib.filterAttrs (n: _: n != osConfig.networking.hostName) {
              fileserver = {
                name = "Fileserver";
                id = "XGZYGZL-XUFUKMO-NBHYWUZ-ZCX4CZE-MOVDTBK-ISHMOBF-6EUQYEF-DCRL4AR";
              };
              pixel-tablet = {
                name = "Pixel Tablet";
                id = "ERDLLKD-NQZGSGQ-6IUWZKJ-DLBWKIW-7FNRDEK-QJVXDKW-3AREAWA-CJQ37AX";
              };
              s26ultra = {
                name = "Samsung Galaxy S26 Ultra";
                id = "EL35KI3-JW4WLR5-RNMTRHR-TS6XNGF-NZ6ODFN-4G5N6CG-WAQXEUK-MEUFNQA";
              };
              steam-deck = {
                name = "Steam Deck";
                id = "AZGUOMW-U73CS2C-3OA37LN-KXBVB7N-66XMBJS-STAW4HD-WSKJDFS-VOHNWQZ";
              };
              oryp7 = {
                name = "System76 Oryx Pro 7";
                id = "IUAZEJ5-JUJ74ZA-MEE2E5S-PPTOZ5Q-XWCZFI6-J4KPKFK-N4QBYBR-EVT7GAO";
              };
              powerspec = {
                name = "PowerSpec G753";
                id = "GLXKG3Y-X3QYRPP-LCZGNYI-WHCDGRO-HVHOTQ5-ALVYUYL-FMW2UQ2-PIL65AU";
              };
            };
            folders = {
              "Second Brain" = {
                enable = true;
                devices = lib.filter (d: d != osConfig.networking.hostName) [
                  "fileserver"
                  "pixel-tablet"
                  "s26ultra"
                  "steam-deck"
                  "oryp7"
                  "powerspec"
                ];
                id = "rrwzp-lps3f";
                label = "Second Brain";
                path = "/home/${osConfig.primaryUser.username}/Data/Second Brain";
                type = "receiveonly";
                versioning = null;
              };
            };
          };
        };

        # Explicitly delay Syncthing until sops-nix has populated the symlink targets
        systemd.user.services.syncthing = {
          Unit = {
            After = [ "sops-nix.service" ];
            Wants = [ "sops-nix.service" ];
          };
        };
        systemd.user.services.syncthing-init = {
          Unit = {
            After = [
              "syncthing.service"
              "sops-nix.service"
            ];
            Wants = [ "sops-nix.service" ];
          };
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
