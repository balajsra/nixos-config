{ config, lib, pkgs, userSettings, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = userSettings.username;
  home.homeDirectory = "/home/" + userSettings.username;

  programs.home-manager.enable = true;

  home.stateVersion = "23.11";

  imports = [
    (../../user/browser + "/${userSettings.browser}.nix")
    ../../user/development/default.nix
    (if userSettings.editor == "emacsclient" then ../../user/development/doom-emacs.nix else (../../user/development + "/${userSettings.editor}.nix"))
    ../../user/gaming/default.nix
    ../../user/launcher/default.nix
    ../../user/media/default.nix
    ../../user/productivity/default.nix
    (../../user/terminal + "/${userSettings.term}.nix")
    ../../user/terminal/prompt.nix
    ../../user/utilities/default.nix
  ];

  home.sessionVariables = {
    EDITOR = userSettings.editor;
    SPAWNEDITOR = userSettings.spawnEditor;
    TERM = userSettings.term;
    BROWSER = userSettings.browser;
  };
}
