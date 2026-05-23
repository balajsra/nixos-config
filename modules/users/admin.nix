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
      # Decrypt <username>-password to /run/secrets-for-users/ so it can be used to create the user
      sops.secrets."${config.primaryUser.username}-password".neededForUsers = true;
      # Required for password to be set via sops during system activation
      users.mutableUsers = false;

      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users."${config.primaryUser.username}" = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets."${config.primaryUser.username}-password".path;
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
