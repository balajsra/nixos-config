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
    ../../user/gaming/default.nix
    ../../user/launcher/default.nix
    ../../user/media/default.nix
    ../../user/productivity/default.nix
    (../../user/terminal + "/${userSettings.term}.nix")
    ../../user/utilities/default.nix
  ];

  # home.packages = (with pkgs; [
  # ]);

  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    music = "${config.home.homeDirectory}/Media/Music";
    videos = "${config.home.homeDirectory}/Media/Videos";
    pictures = "${config.home.homeDirectory}/Media/Pictures";
    templates = "${config.home.homeDirectory}/Templates";
    download = "${config.home.homeDirectory}/Downloads";
    documents = "${config.home.homeDirectory}/Documents";
    desktop = null;
    publicShare = null;
  };
  xdg.mime.enable = true;
  xdg.mimeApps.enable = true;

  home.sessionVariables = {
    EDITOR = userSettings.editor;
    SPAWNEDITOR = userSettings.spawnEditor;
    TERM = userSettings.term;
    BROWSER = userSettings.browser;
  };
}
