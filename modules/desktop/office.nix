{ self, ... }:

{
  flake.nixosModules.office = {
    imports = [
      self.nixosModules.gnucash
    ];
  };

  flake.homeModules.office = {
    imports = [
      self.homeModules.obsidian
      self.homeModules.gnucash
      self.homeModules.qalculate
      self.homeModules.thunderbird
      self.homeModules.zathura
      self.homeModules.libreoffice
    ];
  };

  flake.homeModules.obsidian =
    { osConfig, lib, ... }:
    {
      config = lib.mkIf osConfig.features.office.obsidian.enable {
        # https://wiki.nixos.org/wiki/Obsidian
        programs.obsidian = {
          enable = true;
          cli.enable = true;
        };

        # TODO: Configure obsidian with Nix
      };
    };

  flake.nixosModules.gnucash =
    { config, lib, ... }:
    {
      config = lib.mkIf config.features.office.gnucash.enable {
        # Enable editing of settings from GUI
        programs.dconf.enable = true;
      };
    };

  flake.homeModules.gnucash =
    {
      pkgs,
      osConfig,
      lib,
      ...
    }:
    {
      config = lib.mkIf osConfig.features.office.gnucash.enable {
        home.packages = with pkgs; [
          gnucash
        ];
      };
    };

  flake.homeModules.qalculate =
    {
      pkgs,
      lib,
      osConfig,
      ...
    }:
    {
      config = lib.mkIf osConfig.features.office.qalculate.enable {
        home.packages = with pkgs; [
          libqalculate
          qalculate-gtk
        ];
      };
    };

  flake.homeModules.thunderbird =
    {
      osConfig,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf osConfig.features.office.thunderbird.enable {
        # https://wiki.nixos.org/wiki/Thunderbird
        home.packages = with pkgs; [
          thunderbird
        ];

        # https://wiki.nixos.org/wiki/Default_applications
        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            "x-scheme-handler/mailto" = "thunderbird.desktop";
          };
        };

        # TODO: Use home manager to configure Thunderbird
      };
    };

  flake.homeModules.zathura =
    { osConfig, lib, ... }:
    {
      config = lib.mkIf osConfig.features.office.zathura.enable {
        programs.zathura = {
          enable = true;
          options = {
            window-title-basename = true;
            selection-clipboard = "clipboard";

            # Dracula color theme
            notification-error-bg = "rgba(255,85,85,1)"; # Red
            notification-error-fg = "rgba(248,248,242,1)"; # Foreground
            notification-warning-bg = "rgba(255,184,108,1)"; # Orange
            notification-warning-fg = "rgba(68,71,90,1)"; # Selection
            notification-bg = "rgba(40,42,54,1)"; # Background
            notification-fg = "rgba(248,248,242,1)"; # Foreground

            completion-bg = "rgba(40,42,54,1)"; # Background
            completion-fg = "rgba(98,114,164,1)"; # Comment
            completion-group-bg = "rgba(40,42,54,1)"; # Background
            completion-group-fg = "rgba(98,114,164,1)"; # Comment
            completion-highlight-bg = "rgba(68,71,90,1)"; # Selection
            completion-highlight-fg = "rgba(248,248,242,1)"; # Foreground

            index-bg = "rgba(40,42,54,1)"; # Background
            index-fg = "rgba(248,248,242,1)"; # Foreground
            index-active-bg = "rgba(68,71,90,1)"; # Current Line
            index-active-fg = "rgba(248,248,242,1) "; # Foreground

            inputbar-bg = "rgba(40,42,54,1)"; # Background
            inputbar-fg = "rgba(248,248,242,1)"; # Foreground
            statusbar-bg = "rgba(40,42,54,1)"; # Background
            statusbar-fg = "rgba(248,248,242,1)"; # Foreground

            highlight-color = "rgba(255,184,108,0.5)"; # Orange
            highlight-active-color = "rgba(255,121,198,0.5)"; # Pink

            default-bg = "rgba(40,42,54,1)"; # Background
            default-fg = "rgba(248,248,242,1)"; # Foreground

            render-loading = true;
            render-loading-fg = "rgba(40,42,54,1)"; # Background
            render-loading-bg = "rgba(248,248,242,1)"; # Foreground

            # Recolor mode settings
            recolor-lightcolor = "rgba(40,42,54,1)"; # Background
            recolor-darkcolor = "rgba(248,248,242,1)"; # Foreground

            # Startup options
            adjust-open = "width";
            recolor = true;
          };
        };

        # https://wiki.nixos.org/wiki/Default_applications
        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            "application/pdf" = "org.pwmt.zathura.desktop";
          };
        };
      };
    };

  flake.homeModules.libreoffice =
    {
      osConfig,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf osConfig.features.office.libreoffice.enable {
        # https://wiki.nixos.org/wiki/LibreOffice
        home.packages = with pkgs; [
          libreoffice
          hunspell
          hunspellDicts.en_US
          hyphenDicts.en_US
        ];
      };
    };
}
