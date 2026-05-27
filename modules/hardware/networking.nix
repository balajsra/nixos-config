{ self, ... }:

{
  flake.nixosModules.networking =
    { config, ... }:
    {
      imports = [
        self.nixosModules.networkmanager
        self.nixosModules.firewall
        self.nixosModules.ssh-server
        self.nixosModules.vpn
      ];
    };

  flake.homeModules.networking = {
    imports = [
      self.homeModules.ssh-client
    ];
  };

  flake.homeModules.ssh-client =
    { lib, osConfig, ... }:
    {
      config = lib.mkIf (osConfig.features.networking.ssh-client.enable) {
        sops.secrets = {
          "private_keys/${osConfig.networking.hostName}/${osConfig.primaryUser.username}" = {
            path = "/home/${osConfig.primaryUser.username}/.ssh/id_ed25519";
          };
        };

        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          settings = {
            "forgejo" = {
              HostName = "forgejo.sravanbalaji.com";
              User = "git";
              IdentityFile = "/home/${osConfig.primaryUser.username}/.ssh/id_ed25519";
              Port = 2222;
            };
            "*" = {
              ForwardAgent = false;
              AddKeysToAgent = "no";
              Compression = false;
              ServerAliveInterval = 0;
              ServerAliveCountMax = 3;
              HashKnownHosts = false;
              UserKnownHostsFile = "/home/${osConfig.primaryUser.username}/.ssh/known_hosts";
              ControlMaster = "no";
              ControlPath = "/home/${osConfig.primaryUser.username}/.ssh/master-%r@%n:%p";
              ControlPersist = "no";
            };
          };
        };
      };
    };

  flake.nixosModules.networkmanager =
    { config, ... }:
    {
      # https://wiki.nixos.org/wiki/NetworkManager
      networking.networkmanager = {
        enable = true;

        # Prioritize Ethernet over WiFi
        settings = {
          "device" = {
            "match-device" = "type:ethernet";
            "ipv4.route-metric" = 100;
            "ipv6.route-metric" = 100;
          };
        };
      };

      programs.nm-applet.enable = true;

      users.users."${config.primaryUser.username}".extraGroups = [ "networkmanager" ];
    };

  flake.nixosModules.firewall = {
    # https://wiki.nixos.org/wiki/Firewall
    networking.firewall.enable = true;
  };

  flake.nixosModules.ssh-server =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.features.networking.ssh-server.enable) {
        services.openssh = {
          enable = true;
          startWhenNeeded = true;
          openFirewall = true;
          settings = {
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            PermitRootLogin = "no";
          };
        };
      };
    };

  flake.nixosModules.vpn =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        self.nixosModules.home-vpn
        self.nixosModules.proton-vpn
      ];

      config = lib.mkIf (config.features.networking.vpn.enable) {
        # https://wiki.nixos.org/wiki/WireGuard
        environment.systemPackages = with pkgs; [
          wireguard-tools
        ];
      };
    };

  flake.nixosModules.home-vpn =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf (config.features.networking.vpn.home) {
        sops.secrets = {
          "home_vpn_wireguard/${config.networking.hostName}/full_tunnel" = {
            path = "/run/secrets/home-full-tunnel.conf";
          };
          "home_vpn_wireguard/${config.networking.hostName}/split_tunnel" = {
            path = "/run/secrets/home-split-tunnel.conf";
          };
        };

        # Dynamically load the files cleanly into NetworkManager at startup/switch
        systemd.services.import-nm-home-vpns = {
          description = "Import Home WireGuard Profiles to NetworkManager";
          wantedBy = [ "multi-user.target" ];
          after = [
            "sops-nix.service"
            "NetworkManager.service"
          ];
          path = [ pkgs.networkmanager ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            # Delete any stale previous copies to prevent duplicates
            nmcli connection delete "home-full-tunnel" 2>/dev/null || true
            nmcli connection delete "home-split-tunnel" 2>/dev/null || true

            # Use NetworkManager's native translation engine to import the files safely
            nmcli connection import type wireguard file /run/secrets/home-full-tunnel.conf
            nmcli connection import type wireguard file /run/secrets/home-split-tunnel.conf

            # Make sure they default to not starting automatically at boot
            nmcli connection modify "home-full-tunnel" connection.autoconnect no
            nmcli connection modify "home-split-tunnel" connection.autoconnect no
          '';
        };
      };
    };

  flake.nixosModules.proton-vpn =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf (config.features.networking.vpn.proton) {
        sops.secrets."proton_vpn_wireguard/jp-free-20" = {
          path = "/run/secrets/proton-jp-free-20.conf";
        };

        systemd.services.import-nm-proton-vpn = {
          description = "Import Proton WireGuard Profile to NetworkManager";
          wantedBy = [ "multi-user.target" ];
          after = [
            "sops-nix.service"
            "NetworkManager.service"
          ];
          path = [ pkgs.networkmanager ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            nmcli connection delete "proton-jp-free-20" 2>/dev/null || true
            nmcli connection import type wireguard file /run/secrets/proton-jp-free-20.conf
            nmcli connection modify "proton-jp-free-20" connection.autoconnect no
          '';
        };
      };
    };
}
