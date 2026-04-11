{ self, config, ... }:
{
  flake.nixosModules.data-dirs =
    { config, ... }:
    let
      user = config.primaryUser.username;
    in
    {
      systemd.tmpfiles.rules = [
        # Type  Path                                 Mode  User     Group  Age  Argument
        "d      /data/${user}                        0700  ${user}  users  -    -"
        "d      /data/${user}/Calibre-Library        0700  ${user}  users  -    -"
        "d      /data/${user}/Documents              0700  ${user}  users  -    -"
        "d      /data/${user}/Downloads              0700  ${user}  users  -    -"
        "d      /data/${user}/Games                  0700  ${user}  users  -    -"
        "d      /data/${user}/Games/EA-App           0700  ${user}  users  -    -"
        "d      /data/${user}/Games/Heroic           0700  ${user}  users  -    -"
        "d      /data/${user}/Games/Prism-Launcher   0700  ${user}  users  -    -"
        "d      /data/${user}/Games/Steam            0700  ${user}  users  -    -"
        "d      /data/${user}/Games/Ubisoft-Connect  0700  ${user}  users  -    -"
        "d      /data/${user}/Music                  0700  ${user}  users  -    -"
        "d      /data/${user}/NextCloud              0700  ${user}  users  -    -"
        "d      /data/${user}/Pictures               0700  ${user}  users  -    -"
        "d      /data/${user}/Projects               0700  ${user}  users  -    -"
        "d      /data/${user}/Second-Brain           0700  ${user}  users  -    -"
        "d      /data/${user}/Videos                 0700  ${user}  users  -    -"
      ];
    };

  flake.homeModules.data-dirs =
    { config, osConfig, ... }:
    let
      user = osConfig.primaryUser.username;
    in
    {
      home.file."Data".source = config.lib.file.mkOutOfStoreSymlink "/data/${user}";

      xdg.userDirs = {
        enable = true;
        setSessionVariables = true;
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
    };
}
