{ self, ... }:
{
  flake.nixosModules.git =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        git
      ];
    };

  flake.homeModules.git =
    { pkgs, ... }:
    {
      programs.git = {
        enable = true;
        settings = {
          init.defaultBranch = "main";
        };
      };

      programs.bash.shellAliases = {
        git-graph = "git log --all --decorate --oneline --graph";
      };

      programs.vscode.profiles.default.extensions = with pkgs.vscode-extensions; [
        mhutchie.git-graph
      ];

      programs.zed-editor.extensions = [
        "git-firefly"
      ];
    };

}
