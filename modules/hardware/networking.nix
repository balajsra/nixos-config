{ self, ... }:

{
  flake.nixosModules.networking =
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

    users.users.${config.primaryUser.username}.extraGroups = [ "networkmanager" ];
  };
}
