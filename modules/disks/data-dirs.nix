{ self, config, ... }:
{
  flake.nixosModules.data-dirs =
    { config, ... }:
    let
      user = config.primaryUser.username;
      group = config.users.users.${user}.group;
    in
    {
      systemd.tmpfiles.rules = [
        # Type  Path                                 Mode  User     Group     Age  Argument
        "d      /data/${user}                        0700  ${user}  ${group}  -    -"
        "d      /data/${user}/Documents              0700  ${user}  ${group}  -    -"
        "d      /data/${user}/Downloads              0700  ${user}  ${group}  -    -"
        "d      /data/${user}/Games                  0700  ${user}  ${group}  -    -"
        "d      /data/${user}/Games/EA-App           0700  ${user}  ${group}  -    -"
        "d      /data/${user}/Games/Heroic           0700  ${user}  ${group}  -    -"
        "d      /data/${user}/Games/Prism-Launcher   0700  ${user}  ${group}  -    -"
        "d      /data/${user}/Games/Steam            0700  ${user}  ${group}  -    -"
        "d      /data/${user}/Games/Ubisoft-Connect  0700  ${user}  ${group}  -    -"
        "d      /data/${user}/Music                  0700  ${user}  ${group}  -    -"
        "d      /data/${user}/NextCloud              0700  ${user}  ${group}  -    -"
        "d      /data/${user}/Pictures               0700  ${user}  ${group}  -    -"
        "d      /data/${user}/Projects               0700  ${user}  ${group}  -    -"
        "d      /data/${user}/Second-Brain           0700  ${user}  ${group}  -    -"
        "d      /data/${user}/Videos                 0700  ${user}  ${group}  -    -"
      ];
    };

  flake.homeModules.data-dirs =
    { config, osConfig, ... }:
    let
      user = osConfig.primaryUser.username;
    in
    {
      home.file."Data".source = config.lib.file.mkOutOfStoreSymlink "/data/${user}";
      home.file."Documents".source = config.lib.file.mkOutOfStoreSymlink "/data/${user}/Documents";
      home.file."Downloads".source = config.lib.file.mkOutOfStoreSymlink "/data/${user}/Downloads";
      home.file."Games".source = config.lib.file.mkOutOfStoreSymlink "/data/${user}/Games";
      home.file."Music".source = config.lib.file.mkOutOfStoreSymlink "/data/${user}/Music";
      home.file."NextCloud".source = config.lib.file.mkOutOfStoreSymlink "/data/${user}/NextCloud";
      home.file."Pictures".source = config.lib.file.mkOutOfStoreSymlink "/data/${user}/Pictures";
      home.file."Projects".source = config.lib.file.mkOutOfStoreSymlink "/data/${user}/Projects";
      home.file."Second-Brain".source = config.lib.file.mkOutOfStoreSymlink "/data/${user}/Second-Brain";
      home.file."Videos".source = config.lib.file.mkOutOfStoreSymlink "/data/${user}/Videos";

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
