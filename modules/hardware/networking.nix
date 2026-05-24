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
    { config, lib, ... }:
    {
      config = lib.mkIf (config.features.networking.vpn.home) {
        sops.secrets = {
          "home_vpn_wireguard/${config.networking.hostName}/full_tunnel" = { };
          "home_vpn_wireguard/${config.networking.hostName}/split_tunnel" = { };
        };

        networking.wg-quick.interfaces = {
          home-full-tunnel = {
            configFile =
              config.sops.secrets."home_vpn_wireguard/${config.networking.hostName}/full_tunnel".path;
          };
          home-split-tunnel = {
            configFile =
              config.sops.secrets."home_vpn_wireguard/${config.networking.hostName}/split_tunnel".path;
          };
        };
      };
    };

  flake.nixosModules.proton-vpn =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.features.networking.vpn.proton) {
        sops.secrets = {
          "proton_vpn_wireguard/jp-free-20" = { };
        };

        networking.wg-quick.interfaces = {
          proton-jp-free-20 = {
            configFile = config.sops.secrets."proton_vpn_wireguard/jp-free-20".path;
          };
        };
      };
    };
}
