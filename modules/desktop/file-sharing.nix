{ self, ... }:

{
  flake.homeModules.file-sharing =
    { pkgs, ... }:
    {
      # https://nixos.wiki/wiki/Nextcloud
      home.packages = with pkgs; [
        nextcloud-client
      ];

      # https://nixos.wiki/wiki/Syncthing
      services.syncthing = {
        enable = true;
        tray.enable = true;
      };
    };
}
