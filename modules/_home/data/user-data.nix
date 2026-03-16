{ vars, config, ... }:
let
  user = vars.username;
in
{
  home.file."Data".source = config.lib.file.mkOutOfStoreSymlink "/data/${user}";

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    documents = "/data/${user}/Documents";
    music = "/data/${user}/Music";
    pictures = "/data/${user}/Pictures";
    videos = "/data/${user}/Videos";
    download = "/data/${user}/Downloads";
    desktop = "/home/${user}/Desktop";
    extraConfig = {
      PROJECTS = "/data/${user}/Projects";
      GAMES = "/data/${user}/Games";
    };
  };
}
