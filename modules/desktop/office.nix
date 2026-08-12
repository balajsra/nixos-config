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
      self.homeModules.sweethome3d
      self.homeModules.drawy
    ];
  };

  flake.homeModules.obsidian =
    { osConfig, lib, ... }:
    {
      config = lib.mkIf (osConfig.features.office.obsidian.enable) {
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
      config = lib.mkIf (config.features.office.gnucash.enable) {
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
      config = lib.mkIf (osConfig.features.office.gnucash.enable) {
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
      config = lib.mkIf (osConfig.features.office.qalculate.enable) {
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
      config = lib.mkIf (osConfig.features.office.thunderbird.enable) {
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
    {
      osConfig,
      config,
      lib,
      inputs,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.office.zathura.enable) {
        programs.zathura = {
          enable = true;
        };

        xdg.configFile."zathura/zathurarc".source =
          config.lib.file.mkOutOfStoreSymlink "${inputs.dracula-zathura}/zathurarc";

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
      config = lib.mkIf (osConfig.features.office.libreoffice.enable) {
        # https://wiki.nixos.org/wiki/LibreOffice
        home.packages = with pkgs; [
          libreoffice
          hunspell
          hunspellDicts.en_US
          hyphenDicts.en_US
        ];
      };
    };

  flake.homeModules.sweethome3d =
    {
      osConfig,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.office.sweethome3d.enable) {
        home.packages = with pkgs; [
          sweethome3d.application
          sweethome3d.textures-editor
          sweethome3d.furniture-editor
        ];
      };
    };

  flake.homeModules.drawy =
    {
      osConfig,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.office.drawy.enable) {
        home.packages = with pkgs; [
          drawy
        ];
      };
    };
}
