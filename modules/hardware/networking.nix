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
