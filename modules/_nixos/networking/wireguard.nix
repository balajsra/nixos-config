{ pkgs, ... }:

{
  # https://wiki.nixos.org/wiki/WireGuard
  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];
}
