{ pkgs, ... }:

{
  # https://nixos.wiki/wiki/Syncthing
  services.syncthing = {
    enable = true;
    tray.enable = true;
  };
}
