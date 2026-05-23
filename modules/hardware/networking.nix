{ self, ... }:

{
  flake.nixosModules.networking =
    { config, ... }:
    {
      imports = [
        self.nixosModules.networkmanager
        self.nixosModules.firewall
        self.nixosModules.ssh-server
        self.nixosModules.wireguard
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
          "private_keys/${osConfig.primaryUser.username}" = {
            path = "/home/${osConfig.primaryUser.username}/.ssh/id_ed25519";
          };
        };

        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          matchBlocks = {
            "forgejo" = {
              hostname = "forgejo.sravanbalaji.com";
              user = "git";
              identityFile = "/home/${osConfig.primaryUser.username}/.ssh/id_ed25519";
              port = 2222;
            };
            "*" = {
              forwardAgent = false;
              addKeysToAgent = "no";
              compression = false;
              serverAliveInterval = 0;
              serverAliveCountMax = 3;
              hashKnownHosts = false;
              userKnownHostsFile = "/home/${osConfig.primaryUser.username}/.ssh/known_hosts";
              controlMaster = "no";
              controlPath = "/home/${osConfig.primaryUser.username}/.ssh/master-%r@%n:%p";
              controlPersist = "no";
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

  flake.nixosModules.wireguard =
    { pkgs, ... }:
    {
      # https://wiki.nixos.org/wiki/WireGuard
      environment.systemPackages = with pkgs; [
        wireguard-tools
      ];
    };
}
