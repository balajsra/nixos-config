{ config, lib, pkgs, ... }:

{
  imports = [
    ./3d-printing.nix
    ./bootable-media.nix
    ./file-syncing.nix
    ./keyboard-configuration.nix
    ./passwords.nix
    ./xdg.nix
  ];
}
