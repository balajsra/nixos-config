{
  self,
  config,
  inputs,
  ...
}:
let
  dotfilesPath = "${config.home.homeDirectory}/.config/nixos/dotfiles";
in
{
  flake.nixosModules.desktop-environment = {
    imports = [
      self.nixosModules.mangowm
    ];
  };

  flake.homeModules.desktop-environment = {
    imports = [
      self.homeModules.mangowm
    ];
  };

  flake.nixosModules.mangowm =
    { pkgs, ... }:
    {
      # programs.mango.enable = true;

      # "https://wiki.nixos.org/wiki/UWSM"
      programs.uwsm = {
        enable = true;
        waylandCompositors = {
          mangowm = {
            prettyName = "Mango";
            comment = "Mango Wayland Compositor managed by UWSM";
            binPath = "/run/current-system/sw/bin/mango";
          };
        };
      };

      xdg.portal = {
        enable = true;
        wlr.enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
        ];
        config.common = {
          default = [ "gtk" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
          "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
        };
      };

      # https://wiki.nixos.org/wiki/Polkit
      security.polkit.enable = true;
      security.soteria.enable = true;

      environment.systemPackages = with pkgs; [
        wlr-randr
        wdisplays
        shikane
        nwg-look
        kdePackages.qt6ct
        kdePackages.qtstyleplugin-kvantum
        breeze-hacked-cursor-theme
        papirus-icon-theme
        waypaper
        awww
      ];
    };

  flake.homeModules.mangowm =
    { pkgs, ... }:
    {
      imports = [
        inputs.mangowm.hmModules.mango
        self.homeModules.notifications
        self.homeModules.launcher
        self.homeModules.screenshot
      ];

      wayland.windowManager.mango = {
        enable = true;
        # Disable systemd integration since it conflicts with UWSM
        systemd.enable = false;
      };
      xdg.configFile."mango".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/mangowc/.config/mango";

      # https://wiki.nixos.org/wiki/Waybar
      programs.waybar.enable = true;
      xdg.configFile."waybar".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/mango/.config/mango/waybar";

      home.packages = with pkgs; [
        brightnessctl
        playerctl
        ristretto
      ];
    };

  flake.homeModules.notifications = {
    services.dunst.enable = true;

    xdg.configFile."dunst/dunstrc".enable = false;
    xdg.configFile."dunst".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/dunst/.config/dunst";
    home.file.".scripts/dunst.sh".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/dunst/.scripts/dunst.sh";
  };

  flake.homeModules.launcher =
    { pkgs, ... }:
    {
      # https://wiki.nixos.org/wiki/Rofi
      programs.rofi = {
        enable = true;
      };
      xdg.configFile."rofi/config.rasi".enable = false;
      xdg.configFile."rofi".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/rofi/.config/rofi";

      home.packages = with pkgs; [
        cliphist
      ];
    };

  flake.homeModules.screenshot =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        grim
        slurp
      ];

      programs.swappy = {
        enable = true;
        settings = {
          Default = {
            save_dir = config.xdg.userDirs.pictures;
            save_filename_format = "swappy-%Y%m%d-%H%M%S.png";
            show_panel = false;
            line_size = 5;
            text_size = 20;
            text_font = "sans-serif";
            paint_mode = "brush";
            early_exit = false;
            fill_shape = false;
          };
        };
      };
    };

  flake.homeModules.screen-lock =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        swaylock-effects
        swayidle
      ];

      xdg.configFile."swaylock".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/swaylock/.config/swaylock";
      xdg.configFile."swayidle".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/swayidle/.config/swayidle";
    };

  flake.homeModules.file-explorer =
    { pkgs, ... }:
    {
      # https://nixos.wiki/wiki/Thunar
      home.packages = with pkgs; [
        thunar
        thunar-archive-plugin
        thunar-media-tags-plugin
        thunar-vcs-plugin
        thunar-volman
        p7zip
        tumbler
        xarchiver
      ];
    };
}
