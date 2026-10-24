{ self, inputs, ... }:

{
  flake.homeModules.web-browser = {
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
        home.packages = [
          inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
        ];

        # TODO: Configure Zen Browser

        # Installed Extensions
        # - Dark Reader
        # - Enhancer for YouTube
        # - KeePassXC-Browser
        # - linkding extension
        # - Obsidian Web Clipper
        # - Return YouTube Dislike
        # - Save Image As Type
        # - SponsorBlock for YouTube - Skip Sponsorships
        # - SteamDB
        # - uBlock Origin
        # - Vimium

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
