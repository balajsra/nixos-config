{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    mlocate
    sudo
    tree
    wget
  ];
}
