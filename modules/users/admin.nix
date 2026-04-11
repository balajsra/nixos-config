{
  self,
  lib,
  config,
  ...
}:

{
  flake.nixosModules.admin =
    { config, ... }:
    {
      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users."${config.primaryUser.username}" = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
      };
    };

  flake.homeModules.admin =
    { config, osConfig, ... }:
    {
      imports = [
        self.homeModules.admin-git
      ];

      home.username = lib.mkDefault osConfig.primaryUser.username;
      home.homeDirectory = lib.mkDefault "/home/${osConfig.primaryUser.username}";
      home.stateVersion = "25.11";
    };

  flake.homeModules.admin-git =
    { config, osConfig, ... }:
    {
      programs.git = {
        settings = {
          user.name = "${osConfig.primaryUser.name}";
          user.email = "${osConfig.primaryUser.email}";
        };
      };
    };
}
