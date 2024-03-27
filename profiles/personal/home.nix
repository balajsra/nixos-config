{ config, lib, pkgs, userSettings, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = userSettings.username;
  home.homeDirectory = "/home/" + userSettings.username;

  programs.home-manager.enable = true;

  home.stateVersion = "23.11";

  home.packages = (with pkgs; [
    # Terminal
    kitty

    # Browser
    vivaldi

    # Launcher
    dmenu
    rofi

    # Development
    vscode

    # Utilities
    syncthing
    bitwarden
    ventoy
    via
    prusa-slicer

    # Office
    xournalpp
    gimp
    gnucash

    # Gaming
    wine
    bottles
    lutris
    protonup-qt

    # Media
    gimp
    mpv
    blender
    obs-studio
    ffmpeg
    trackma-gtk

    # Messaging
    beeper
    discord
    signal-desktop
    zoom-us

    # Productivity
    anytype
    logseq

    # Music / Podcasts
    pocket-casts
    spotify
    spicetify-cli
  ]);

  services.syncthing.enable = true;

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
