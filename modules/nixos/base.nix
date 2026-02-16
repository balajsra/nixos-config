{ pkgs, vars, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${vars.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    tree
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Unfre Software: https://nixos.wiki/wiki/Unfree_Software
  nixpkgs.config.allowUnfree = true;

  # Run unpatched dynamic binaries on NixOS
  programs.nix-ld.enable = true;

  # Do not change, this is a safety anchor to prevent
  # system from breaking or losing data during an upgrade
  system.stateVersion = "25.11";
}
