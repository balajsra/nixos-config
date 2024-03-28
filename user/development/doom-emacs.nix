{ config, lib, pkgs, userSettings, ... }:

{
  programs.doom-emacs = {
    enable = true;
    doomPrivateDir = (/home + "/${userSettings.username}" + /.config/doom-emacs-config);
  };
}
