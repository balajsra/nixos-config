{ self, ... }:

{
  flake.nixosModules.phone = {
    # https://wiki.nixos.org/wiki/KDE_Connect
    programs.kdeconnect.enable = true;

    networking.firewall = rec {
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = allowedTCPPortRanges;
    };
  };

  flake.homeModules.phone =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        android-tools
      ];
    };
}
