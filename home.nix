{ config, pkgs, vars, ... }:

{
  home.username = "${vars.username}";
  home.homeDirectory = "/home/${config.home.username}";

  programs.git = {
      enable = true;
      settings = {
          user = {
              name = "${vars.name}";
              email = "${vars.email}";
          };
          init.defaultBranch = "main";
      };
  };

  # Do not change, this is a safety anchor to prevent
  # system from breaking or losing data during an upgrade
  home.stateVersion = "25.11";

  programs.bash = {
    enable = true;
    shellAliases = {
        git-graph = "git log --all --decorate --oneline --graph";
        nix-switch = "sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/.config/nixos#$(hostname) --show-trace";
    };
  };
}
