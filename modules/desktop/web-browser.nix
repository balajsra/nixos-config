{ self, ... }:

{
  flake.homeModules.web-browser =
    { pkgs, ... }:
    {
      # https://wiki.nixos.org/wiki/Zen_Browser
      home.packages = with pkgs; [
        inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
      ];

      # https://wiki.nixos.org/wiki/Default_applications
      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = "zen.desktop";
          "x-scheme-handler/http" = "zen.desktop";
          "x-scheme-handler/https" = "zen.desktop";
          "x-scheme-handler/about" = "zen.desktop";
          "x-scheme-handler/unknown" = "zen.desktop";
        };
      };
    };
}
