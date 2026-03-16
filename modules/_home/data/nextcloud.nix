{ pkgs, ... }:

{
  # https://nixos.wiki/wiki/Nextcloud
  home.packages = with pkgs; [
    nextcloud-client
  ];
}
