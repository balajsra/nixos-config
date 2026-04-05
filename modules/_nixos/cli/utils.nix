{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mlocate
    sudo
    tree
    wget
  ];
}
