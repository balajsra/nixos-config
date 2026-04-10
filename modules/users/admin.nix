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

      home-manager.users."${config.primaryUser.username}" = self.homeModules.admin;
    };

  flake.homeModules.admin =
    { config, ... }:
    {
      imports = [
        self.homeModules.admin-git
      ];

      home.username = lib.mkDefault config.primaryUser.username;
      home.homeDirectory = lib.mkDefault "/home/${config.primaryUser.username}";
      home.stateVersion = "25.11";
    };

  flake.homeModules.admin-git =
    { config, ... }:
    {
      programs.git = {
        settings = {
          user.name = "${config.primaryUser.name}";
          user.email = "${config.primaryUser.email}";
        };
      };
    };
}
