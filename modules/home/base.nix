{ vars, ... }:
{
    home.username = vars.username;
    home.homeDirectory = "/home/${vars.username}";
    home.stateVersion = "25.11";

    programs.git = {
        enable = true;
        settings = {
            user.name = vars.name;
            user.email = vars.email;
            init.defaultBranch = "main";
        };
    };
}
