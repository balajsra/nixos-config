{ pkgs, ... }:

{
  # https://nixos.wiki/wiki/Gammastep

  services.gammastep = {
    enable = true;
    provider = "geoclue2";
  };
}
