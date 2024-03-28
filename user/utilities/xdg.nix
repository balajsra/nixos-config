{ config, lib, pkgs, ... }:

{
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
    extraConfig = {
      XDG_GAME_DIR = "${config.home.homeDirectory}/Games";
      XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
      XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";
    };
  };
  xdg.mime.enable = true;
  xdg.mimeApps.enable = true;
}
