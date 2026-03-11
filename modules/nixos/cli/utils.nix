{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    mlocate
    sudo
    tmux
    tree
    wget
  ];
}
