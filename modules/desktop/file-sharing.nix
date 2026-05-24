{ self, ... }:

{
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
        # https://nixos.wiki/wiki/Nextcloud
        home.packages = with pkgs; [
          nextcloud-client
        ];
      };
    };

  flake.homeModules.syncthing =
    { osConfig, lib, ... }:
    {
      config = lib.mkIf (osConfig.features.file-sharing.syncthing.enable) {
        # https://nixos.wiki/wiki/Syncthing
        services.syncthing = {
          enable = true;
          tray.enable = true;
        };
      };
    };
}
