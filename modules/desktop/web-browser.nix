{ self, inputs, ... }:

{
  flake.homeModules.web-browser =
    { pkgs, ... }:
    {
      imports = [
        self.homeModules.zen-browser
      ];
    };

  flake.homeModules.zen-browser =
    {
      osConfig,
      pkgs,
      lib,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.browser.zen.enable) {
        # https://wiki.nixos.org/wiki/Zen_Browser
        home.packages = with pkgs; [
          inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
        ];

        # https://wiki.nixos.org/wiki/Default_applications
        xdg.mimeApps = lib.mkIf (osConfig.features.browser.default == "zen") {
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
    };
}
