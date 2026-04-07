{ self, ... }:

{
  flake.nixosModules.display-manager = {
    services.displayManager.ly = {
      enable = true;
      settings = {
        animation = "matrix";
        asterisk = "*";
        bigclock = "en";
        clear_password = true;
        clock = "%c";
        save = true;
      };
    };
  };
}
