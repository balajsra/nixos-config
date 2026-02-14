{ config, pkgs, ... }:

{
  home.username = "sravan";
  home.homeDirectory = "/home/sravan";
  programs.git.enable = true;
  home.stateVersion = "25.11";
  programs.bash = {
    enable = true;
    shellAliases = {
      git-graph = "git log --all --decorate --oneline --graph";
    };
  };
}
