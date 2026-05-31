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
      sops.secrets."passwords/${config.networking.hostName}/${config.primaryUser.username}".neededForUsers =
        true;
      # Required for password to be set via sops during system activation
      users.mutableUsers = false;

      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users."${config.primaryUser.username}" = {
        isNormalUser = true;
        hashedPasswordFile =
          config.sops.secrets."passwords/${config.networking.hostName}/${config.primaryUser.username}".path;
        extraGroups = [
          "wheel"
          "users"
        ];
        uid = 1000;
        group = "${config.primaryUser.username}";
      };

      users.groups."${config.primaryUser.username}" = {
        gid = 1000;
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
