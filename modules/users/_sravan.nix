let
  name = "Sravan Balaji";
  email = "sr98vn@gmail.com";
  username = "sravan";
in
{
  flake.modules.nixos.${username} = {
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${username} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };

  flake.modules.homeManager.${username} =
    { pkgs, lib, ... }:
    {
      home.username = lib.mkDefault username;
      home.homeDirectory = lib.mkDefault "/home/${username}";
      home.stateVersion = "25.11";
    };
}
