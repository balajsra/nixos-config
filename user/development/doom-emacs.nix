{ config, lib, pkgs, ... }:

{
  programs.doom-emacs = {
    enable = true;
    doomPrivateDir = ~/.config/doom-emacs-config;
  };
}
