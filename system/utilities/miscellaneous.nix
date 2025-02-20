{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    zsh
    git
    rsync
    cryptsetup
    home-manager
    tree
    btop
    openssh
    gh
  ];
}
