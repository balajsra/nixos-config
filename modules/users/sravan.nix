{ self, lib, ... }:
let
  name = "Sravan Balaji";
  email = "sr98vn@gmail.com";
  username = "sravan";
in
{
  flake.nixosModules."${username}" = {
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users."${username}" = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };

  flake.homeModules."${username}" = {
    imports = [
      self.homeModules."${username}-git"
    ];

    home.username = lib.mkDefault username;
    home.homeDirectory = lib.mkDefault "/home/${username}";
    home.stateVersion = "25.11";
  };

  flake.homeModules."${username}-git" = {
    programs.git = {
      settings = {
        user.name = "${name}";
        user.email = "${email}";
      };
    };
  };
}
