{
  self,
  config,
  inputs,
  ...
}:

{
  flake.nixosModules.desktop-environment = {
    imports = [
      self.nixosModules.mangowm
      self.nixosModules.gnome
    ];
  };

  flake.homeModules.desktop-environment = {
    imports = [
      self.homeModules.mangowm
      inputs.mangowm.hmModules.mango
      self.homeModules.notifications
      self.homeModules.launcher
      self.homeModules.screenshot
      self.homeModules.file-explorer
      self.homeModules.display-configuration
    ];
  };

  flake.nixosModules.mangowm =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      config = lib.mkIf (config.features.desktop-environment == "mango") {
        programs.mangowc.enable = true;

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
          nwg-look
          kdePackages.qt6ct
          kdePackages.qtstyleplugin-kvantum
          breeze-hacked-cursor-theme
          papirus-icon-theme
        ];

        # https://danklinux.com/docs/dankmaterialshell/nixos
        programs.dms-shell = {
          enable = true;

          systemd = {
            enable = true; # Systemd service for auto-start
            restartIfChanged = true; # Auto-restart dms.service when dms-shell changes
          };

          # Core features
          enableSystemMonitoring = true; # System monitoring widgets (dgop)
          enableVPN = true; # VPN management widget
          enableDynamicTheming = true; # Wallpaper-based theming (matugen)
          enableAudioWavelength = true; # Audio visualizer (cava)
          enableCalendarEvents = true; # Calendar integration (khal)
          enableClipboardPaste = true; # Pasting from the clipboard history (wtype)
        };
      };
    };

  flake.homeModules.mangowm =
    {
      pkgs,
      config,
      osConfig,
      lib,
      ...
    }:
    let
      dotfilesPath = toString osConfig.primaryUser.dotfilesPath;
    in
    {
      config = lib.mkIf (osConfig.features.desktop-environment == "mango") {
        # https://mangowm.github.io/docs/nix-options/
        wayland.windowManager.mango = {
          enable = true;
          # Point Home Manager to system installed package
          package = pkgs.mangowc;
          # UWSM handles the service, so home manager shouldn't
          systemd.enable = false;

          settings = {
            blur = 1;
            blur_layer = 0;
            blur_optimized = 1;
            blur_params = {
              num_passes = 3;
              radius = 5;
              noise = 0.0117;
              brightness = 1.0;
              contrast = 0.8916;
              saturation = 1.2;
            };

            shadows = 1;
            shadow_only_floating = 1;
            layer_shadows = 1;
            shadows_size = 10;
            shadows_blur = 15;
            shadows_position_x = 0;
            shadows_position_y = 0;
            shadowscolor = "0x1a1a1aee";

            border_radius = 10;
            no_radius_when_single = 0;

            focused_opacity = 1.0;
            unfocused_opacity = 1.0;

            animations = 1;
            layer_animations = 1;
            animation_type_open = "slide";
            animation_type_close = "slide";
            layer_animation_type_open = "slide";
            layer_animation_type_close = "slide";
            animation_fade_in = 1;
            animation_fade_out = 1;
            tag_animation_direction = 1;
            zoom_initial_ratio = 0.3;
            zoom_end_ratio = 0.8;
            fadein_begin_opacity = 0.5;
            fadeout_begin_opacity = 0.8;
            animation_duration = {
              move = 500;
              open = 400;
              tag = 350;
              close = 800;
              focus = 0;
            };
            animation_curve = {
              open = "0.46,1.0,0.29,1";
              move = "0.46,1.0,0.29,1";
              tag = "0.46,1.0,0.29,1";
              close = "0.08,0.92,0,1";
              focus = "0.46,1.0,0.29,1";
            };

            scroller_structs = 20;
            scroller_default_proportion = 0.8;
            scroller_focus_center = 0;
            scroller_prefer_center = 0;
            edge_scroller_pointer_focus = 1;
            scroller_ignore_proportion_single = 0;
            scroller_default_proportion_single = 1.0;
            scroller_proportion_preset = "0.5,0.8,1.0";

            new_is_master = 1;
            default_mfact = 0.50;
            default_nmaster = 1;
            smartgaps = 0;
            center_master_overspread = 0;
            center_when_single_stack = 1;

            hotarea_size = 10;
            enable_hotarea = 1;
            ov_tab_mode = 1;
            overviewgappi = 5;
            overviewgappo = 30;

            xwayland_persistence = 1;
            syncobj_enable = 0;
            allow_shortcuts_inhibit = 1;
            allow_tearing = 0;
            allow_lock_transparent = 0;
            axis_bind_apply_timeout = 100;
            focus_on_activate = 1;
            idleinhibit_ignore_visible = 0;
            sloppyfocus = 1;
            warpcursor = 1;
            focus_cross_monitor = 0;
            exchange_cross_monitor = 1;
            scratchpad_cross_monitor = 1;
            focus_cross_tag = 0;
            view_current_to_back = 0;
            enable_floating_snap = 1;
            snap_distance = 30;
            cursor_size = 24;
            cursor_theme = "breeze-hacked-cursor-theme";
            no_border_when_single = 0;
            cursor_hide_timeout = 5;
            drag_tile_to_tile = 1;
            single_scratchpad = 1;

            repeat_rate = 25;
            repeat_delay = 600;
            numlockon = 1;

            xkb_rules_layout = "us";

            disable_trackpad = 0;
            tap_to_click = 1;
            tap_and_drag = 1;
            drag_lock = 1;
            trackpad_natural_scrolling = 1;
            disable_while_typing = 1;
            left_handed = 0;
            middle_button_emulation = 0;
            swipe_min_threshold = 1;
            scroll_method = 1;
            click_method = 0;
            send_events_mode = 0;
            button_map = 0;

            mouse_natural_scrolling = 0;
            accel_profile = 1;
            accel_speed = -0.25;

            gappih = 20;
            gappiv = 20;
            gappoh = 30;
            gappov = 30;
            scratchpad_width_ratio = 0.8;
            scratchpad_height_ratio = 0.8;
            borderpx = 2;
            rootcolor = "0x282a36ff";
            bordercolor = "0x282a36ff";
            focuscolor = "bd93f9ff";
            maximizescreencolor = "0x282a36ff";
            urgentcolor = "0xff5555ff";
            scratchpadcolor = "0xf1fa8cff";
            globalcolor = "0x8be9fdff";
            overlaycolor = "0x50fa7bff";

            tagrule = [
              "id:1,layout_name:tile"
              "id:2,layout_name:tile"
              "id:3,layout_name:tile"
              "id:4,layout_name:tile"
              "id:5,layout_name:tile"
              "id:6,layout_name:tile"
              "id:7,layout_name:tile"
              "id:8,layout_name:tile"
              "id:9,layout_name:tile"
            ];

            layerrule = [
              "animation_type_open:zoom,layer_name:rofi,noblur:0,noanim:0,noshadow:0"
              "animation_type_close:zoom,layer_name:rofi,noblur:0,noanim:0,noshadow:0"
            ];

            exec-once = [
              "uwsm finalize &"

              "uwsm app -- fumon &"
              "uwsm app -- kdeconnectd --replace &"
              "uwsm app -- wl-paste --type text --watch cliphist store &"
              "uwsm app -- wl-paste --type image --watch cliphist store &"

              "uwsm app -- shikane &"
              "uwsm app -- wpctl set-volume @DEFAULT_AUDIO_SINK@ 25% &"

              "uwsm app -- nm-applet &"
              "uwsm app -- kdeconnect-indicator &"
              "uwsm app -- udiskie -a -n -s &"
              "uwsm app -- nextcloud &"
              "uwsm app -- openrgb &"
            ];
            exec = [
              "uwsm app -- shikanectl reload &"
            ];

            bind = [
              "SUPER,r,reload_config"

              "SUPER+SHIFT,Return,spawn_shell,uwsm app -- ${osConfig.features.terminal.emulator}"
              "SUPER,e,spawn_shell,uwsm app -- emacs"
              "SUPER,p,spawn_shell,uwsm app -- rofi -show combi -run-command \"uwsm app -- {cmd}\""
              "SUPER,b,spawn_shell,$HOME/.config/mango/waybar/scripts/toggleBarService.sh"

              "SUPER+CTRL,p,spawn_shell,uwsm app -- $HOME/.scripts/control-center.sh --rofi"
              "SUPER+CTRL,c,spawn_shell,uwsm app -- cliphist list | rofi -dmenu | cliphist decode | wl-copy"
              "SUPER+CTRL,v,spawn_shell,uwsm app -- $HOME/.scripts/pactl.sh --rofi"
              "SUPER+CTRL,m,spawn_shell,uwsm app -- $HOME/.scripts/playerctl.sh --rofi"
              "SUPER+CTRL,q,spawn_shell,uwsm app -- $HOME/.scripts/session.sh --rofi"

              "SUPER+SHIFT,q,spawn_shell,$HOME/.scripts/session.sh --logout"
              "SUPER+SHIFT,c,killclient"

              "SUPER,j,focusstack,next"
              "SUPER,k,focusstack,prev"

              "SUPER,Return,zoom"
              "SUPER+SHIFT,j,exchange_stack_client,next"
              "SUPER+SHIFT,k,exchange_stack_client,prev"

              "SUPER+SHIFT,0,toggleglobal"
              "SUPER+SHIFT,o,toggleoverlay"

              "SUPER,f,togglefloating"
              "SUPER+SHIFT,f,togglefullscreen"
              "SUPER+CTRL,f,togglefakefullscreen"
              "SUPER+SHIFT+CTRL,f,togglemaximizescreen"

              "SUPER,o,toggleoverview"

              "SUPER,s,switch_proportion_preset"

              "SUPER,t,switch_layout"

              "SUPER,0,view,0,0"
              "SUPER,1,view,1,0"
              "SUPER,2,view,2,0"
              "SUPER,3,view,3,0"
              "SUPER,4,view,4,0"
              "SUPER,5,view,5,0"
              "SUPER,6,view,6,0"
              "SUPER,7,view,7,0"
              "SUPER,8,view,8,0"
              "SUPER,9,view,9,0"

              "SUPER,Tab,focuslast"

              "SUPER+CTRL,1,toggleview,1"
              "SUPER+CTRL,2,toggleview,2"
              "SUPER+CTRL,3,toggleview,3"
              "SUPER+CTRL,4,toggleview,4"
              "SUPER+CTRL,5,toggleview,5"
              "SUPER+CTRL,6,toggleview,6"
              "SUPER+CTRL,7,toggleview,7"
              "SUPER+CTRL,8,toggleview,8"
              "SUPER+CTRL,9,toggleview,9"

              "SUPER+SHIFT,1,tagsilent,1,0"
              "SUPER+SHIFT,2,tagsilent,2,0"
              "SUPER+SHIFT,3,tagsilent,3,0"
              "SUPER+SHIFT,4,tagsilent,4,0"
              "SUPER+SHIFT,5,tagsilent,5,0"
              "SUPER+SHIFT,6,tagsilent,6,0"
              "SUPER+SHIFT,7,tagsilent,7,0"
              "SUPER+SHIFT,8,tagsilent,8,0"
              "SUPER+SHIFT,9,tagsilent,9,0"

              "SUPER+SHIFT+CTRL,1,tag,1,0"
              "SUPER+SHIFT+CTRL,2,tag,2,0"
              "SUPER+SHIFT+CTRL,3,tag,3,0"
              "SUPER+SHIFT+CTRL,4,tag,4,0"
              "SUPER+SHIFT+CTRL,5,tag,5,0"
              "SUPER+SHIFT+CTRL,6,tag,6,0"
              "SUPER+SHIFT+CTRL,7,tag,7,0"
              "SUPER+SHIFT+CTRL,8,tag,8,0"
              "SUPER+SHIFT+CTRL,9,tag,9,0"

              "SUPER,period,focusmon,right"
              "SUPER,comma,focusmon,left"

              "SUPER+SHIFT,period,tagmon,right,0"
              "SUPER+SHIFT+CTRL,period,tagmon,right,1"
              "SUPER+SHIFT,comma,tagmon,left,0"
              "SUPER+SHIFT+CTRL,comma,tagmon,left,1"

              "SUPER+SHIFT+CTRL,equal,incgaps,1"
              "SUPER+SHIFT+CTRL,minus,incgaps,-1"

              "NONE,print,spawn_shell,uwsm app -- grim -g \"$(slurp)\" - | swappy -f -"

              "NONE,XF86AudioRaiseVolume,spawn_shell,uwsm app -- $HOME/.scripts/pactl.sh --raise"
              "NONE,XF86AudioLowerVolume,spawn_shell,uwsm app -- $HOME/.scripts/pactl.sh --lower"
              "NONE,XF86AudioMute,spawn_shell,uwsm app -- $HOME/.scripts/pactl.sh --mute"

              "NONE,XF86AudioNext,spawn_shell,uwsm app -- $HOME/.scripts/playerctl.sh --next"
              "NONE,XF86AudioPause,spawn_shell,uwsm app -- $HOME/.scripts/playerctl.sh --play-pause"
              "NONE,XF86AudioPlay,spawn_shell,uwsm app -- $HOME/.scripts/playerctl.sh --play-pause"
              "NONE,XF86AudioPrev,spawn_shell,uwsm app -- $HOME/.scripts/playerctl.sh --prev"
            ];

            mousebind = [
              "SUPER,btn_left,moveresize,curmove"
              "SUPER,btn_right,moveresize,curresize"
              # "NONE,btn_left,toggleoverview"
              # "NONE,btn_right,killclient"
            ];

            axisbind = [
              "SUPER,UP,viewtoright_have_client"
              "SUPER,DOWN,viewtoleft_have_client"
            ];
          };
        };

        # # https://wiki.nixos.org/wiki/Waybar
        # programs.waybar.enable = true;
        # xdg.configFile."waybar".source =
        #   config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/mango/.config/mango/waybar";

        home.packages = with pkgs; [
          playerctl
          ristretto
        ];
      };
    };

  flake.homeModules.launcher =
    {
      pkgs,
      config,
      osConfig,
      lib,
      ...
    }:
    let
      dotfilesPath = toString osConfig.primaryUser.dotfilesPath;
    in
    {
      config = lib.mkIf (osConfig.features.desktop-environment == "mango") {
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
    };

  flake.homeModules.screenshot =
    {
      pkgs,
      config,
      osConfig,
      lib,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.desktop-environment == "mango") {
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
    };

  flake.homeModules.file-explorer =
    {
      pkgs,
      lib,
      osConfig,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.desktop-environment == "mango") {
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
    };

  flake.homeModules.display-configuration =
    {
      pkgs,
      config,
      osConfig,
      lib,
      ...
    }:
    let
      dotfilesPath = toString osConfig.primaryUser.dotfilesPath;
    in
    {
      config = lib.mkIf (osConfig.features.desktop-environment == "mango") {
        home.packages = with pkgs; [
          wlr-randr
          wdisplays
        ];

        services.shikane = {
          enable = true;
          settings = {
            profile = [
              {
                name = "docked";
                exec = [
                  "notify-send shikane \"Profile $SHIKANE_PROFILE_NAME has been applied\""
                  "$HOME/.scripts/shikane-postswitch.sh"
                ];
                output = [
                  {
                    enable = true;
                    search = [
                      "m=49S405"
                      "s="
                      "v=Technical Concepts Ltd"
                    ];
                    mode = "3840x2160@60Hz";
                    position = {
                      x = 1920;
                      y = 0;
                    };
                    scale = 1.0;
                    transform = "normal";
                    adaptive_sync = false;
                  }
                  {
                    enable = true;
                    search = [
                      "m=0x0625"
                      "s="
                      "v=LG Display"
                    ];
                    mode = "1920x1080@143.998Hz";
                    position = {
                      x = 0;
                      y = 0;
                    };
                    scale = 1.0;
                    transform = "normal";
                    adaptive_sync = false;
                  }
                ];
              }
              {
                name = "mobile";
                exec = [
                  "notify-send shikane \"Profile $SHIKANE_PROFILE_NAME has been applied\""
                  "$HOME/.scripts/shikane-postswitch.sh"
                ];
                output = [
                  {
                    enable = true;
                    search = [
                      "m=0x0625"
                      "s="
                      "v=LG Display"
                    ];
                    mode = "1920x1080@143.998Hz";
                    position = {
                      x = 0;
                      y = 0;
                    };
                    scale = 1.0;
                    transform = "normal";
                    adaptive_sync = false;
                  }
                ];
              }
            ];
          };
        };

        home.file.".scripts/shikane-postswitch.sh".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/shikane/.scripts/shikane-postswitch.sh";
      };
    };

  flake.nixosModules.gnome =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.features.desktop-environment == "gnome") {
        # Enable the X11 windowing system.
        services.xserver = {
          enable = true;
          autoRepeatDelay = 200;
          autoRepeatInterval = 35;
        };

        # Enable the GNOME Desktop Environment.
        services.desktopManager.gnome.enable = true;
      };
    };
}
