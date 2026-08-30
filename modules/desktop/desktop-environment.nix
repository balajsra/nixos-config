{
  self,
  config,
  inputs,
  ...
}:
let
  gtkThemeName = "Dracula";
  gtkThemePackage = "dracula-gtk-theme";

  iconThemeName = "Papirus-Dark";
  iconThemePackage = "papirus-icon-theme";

  cursorThemeName = "breeze-hacked-cursor-theme";
  cursorThemeAltName = "Breeze_Hacked";
  cursorThemePackage = "breeze-hacked-cursor-theme";
  cursorSize = 24;
in
{
  flake.nixosModules.desktop-environment = {
    imports = [
      self.nixosModules.mango
      self.nixosModules.gnome
      self.nixosModules.file-explorer
    ];
  };

  flake.homeModules.desktop-environment = {
    imports = [
      self.homeModules.mango
      inputs.mango.hmModules.mango
      self.homeModules.dank-material-shell
      inputs.dank-material-shell.homeModules.dank-material-shell
      self.homeModules.danksearch
      inputs.danksearch.homeModules.dsearch
      self.homeModules.screenshot
      self.homeModules.theme
      self.homeModules.display
    ];
  };

  flake.nixosModules.mango =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      config = lib.mkIf (config.features.desktop-environment == "mango") {
        programs.mango = {
          enable = true;
          package = pkgs.mango;
        };

        # "https://wiki.nixos.org/wiki/UWSM"
        programs.uwsm = {
          enable = true;
          waylandCompositors = {
            # Make this session appear first alphabetically
            "mango" = {
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

        environment.systemPackages = [
          pkgs.${cursorThemePackage}
          pkgs.${iconThemePackage}
        ];
      };
    };

  flake.homeModules.mango =
    {
      pkgs,
      config,
      osConfig,
      lib,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.desktop-environment == "mango") {
        # https://mangowm.github.io/docs/nix-options/
        wayland.windowManager.mango = {
          enable = true;
          # Point Home Manager to system installed package
          package = pkgs.mango;
          # UWSM handles the service, so home manager shouldn't
          systemd.enable = false;

          settings = {
            #######################
            # Basic Configuration #
            #######################
            # https://mangowm.github.io/docs/configuration/basics#autostart
            exec-once = [
              "uwsm finalize &"

              # Create the virtual output, wait until it appears in wlr-randr, then disable it
              "${pkgs.writeShellScript "mango-init-headless" ''
                set -euo pipefail

                # Create virtual display
                ${pkgs.mango}/bin/mmsg dispatch create_virtual_output

                # Make sure virtual display gets created
                for i in $(seq 1 60); do
                  if ${pkgs.wlr-randr}/bin/wlr-randr | ${pkgs.gnugrep}/bin/grep -q "HEADLESS-1"; then
                    break
                  fi
                  sleep 0.05
                done

                # Disable virtual display
                ${pkgs.mango}/bin/mmsg dispatch disable_monitor,HEADLESS-1
              ''}"

              # Launch applications
              "uwsm app -- fumon &"
              "uwsm app -- kdeconnectd --replace &"
              "uwsm app -- kdeconnect-indicator &"
              "uwsm app -- udiskie -a -n -s &"
              "uwsm app -- nextcloud &"
            ];

            ############
            # Monitors #
            ############
            # https://mangowm.github.io/docs/configuration/monitors#tearing-game-mode
            allow_tearing = 0;

            #################
            # Input Devices #
            #################
            # https://mangowm.github.io/docs/configuration/input/#keyboard-settings
            repeat_rate = 25;
            repeat_delay = 600;
            numlockon = 1;
            xkb_rules = {
              layout = "us";
            };

            # https://mangowm.github.io/docs/configuration/input/#mouse-settings
            mouse = {
              natural_scrolling = 0;
              accel_profile = 1;
              accel_speed = -0.25;
              left_handed = 0;
              middle_button_emulation = false;
              scroll_method = 1;
              click_method = 2;
              send_events_mode = 0;
            };

            # https://mangowm.github.io/docs/configuration/input/#trackpad-settings
            disable_trackpad = 0;
            tap_to_click = 1;
            tap_and_drag = 1;
            drag_lock = 1;
            trackpad = {
              natural_scrolling = 1;
              accel_profile = 2;
              accel_speed = 0.0;
              scroll_method = 1;
              click_method = 2;
              send_events_mode = 0;
              left_handed = 0;
              disable_while_typing = 1;
              scroll_factor = 1.0;
            };
            swipe_min_threshold = 1;
            button_map = 0;

            # https://mangowm.github.io/docs/configuration/input/#touchscreen-settings
            touch = {
              enable = 1;
              enable_mouse_emulation = 0;
            };

            #################
            # Miscellaneous #
            #################
            # https://mangowm.github.io/docs/configuration/miscellaneous#system--hardware
            xwayland = {
              persistence = 1;
              ignore_scale = 0;
            };
            syncobj_enable = 0;
            allow_lock_transparent = 0;
            allow_shortcuts_inhibit = 1;

            # https://mangowm.github.io/docs/configuration/miscellaneous#focus--input
            focus_on_activate = 1;
            sloppyfocus = 1;
            warpcursor = 1;
            cursor_hide_timeout = 5;
            cursor_hide_on_keypress = 0;
            drag_tile_to_tile = 1;
            axis_bind_apply_timeout = 100;

            # https://mangowm.github.io/docs/configuration/miscellaneous#multi-monitor--tags
            focus_cross_monitor = 0;
            exchange_cross_monitor = 1;
            focus_cross_tag = 0;
            view_current_to_back = 0;
            scratchpad_cross_monitor = 1;
            single_scratchpad = 1;

            # https://mangowm.github.io/docs/configuration/miscellaneous#window-behavior
            enable_floating_snap = 1;
            snap_distance = 30;
            no_border_when_single = 0;
            idleinhibit_ignore_visible = 0;
            tag_carousel = 0;

            ###########
            # Theming #
            ###########
            # https://mangowm.github.io/docs/visuals/theming#dimensions
            borderpx = 2;
            gappih = 20;
            gappiv = 20;
            gappoh = 30;
            gappov = 30;

            # https://mangowm.github.io/docs/visuals/theming#colors
            rootcolor = "0x282a36ff";
            bordercolor = "0x282a36ff";
            focuscolor = "bd93f9ff";
            urgentcolor = "0xff5555ff";

            # https://mangowm.github.io/docs/visuals/theming#state-specific-colors
            maximizescreencolor = "0x282a36ff";
            scratchpadcolor = "0xf1fa8cff";
            globalcolor = "0x8be9fdff";
            overlaycolor = "0x50fa7bff";

            # https://mangowm.github.io/docs/visuals/theming#cursor-theme
            cursor_size = cursorSize;
            cursor_theme = "${cursorThemeAltName}";

            ##################
            # Window Effects #
            ##################
            # https://mangowm.github.io/docs/visuals/effects#blur
            blur = 1;
            blur_layer = 0;
            blur_optimized = 1;
            blur_params = {
              radius = 5;
              num_passes = 3;
              noise = 0.0117;
              brightness = 1.0;
              contrast = 0.8916;
              saturation = 1.2;
            };

            # https://mangowm.github.io/docs/visuals/effects#shadows
            shadows = 1;
            layer_shadows = 1;
            shadow_only_floating = 1;
            shadows_size = 10;
            shadows_blur = 15;
            shadows_position = {
              x = 0;
              y = 0;
            };
            shadowscolor = "0x1a1a1aee";

            # https://mangowm.github.io/docs/visuals/effects#opacity--corner-radius
            border_radius = 10;
            no_radius_when_single = 0;
            focused_opacity = 1.0;
            unfocused_opacity = 1.0;

            ##############
            # Animations #
            ##############
            # https://mangowm.github.io/docs/visuals/animations#enabling-animations
            animations = 1;
            layer_animations = 1;

            # https://mangowm.github.io/docs/visuals/animations#animation-types
            animation_type = {
              open = "slide";
              close = "slide";
            };
            layer_animation_type = {
              open = "slide";
              close = "slide";
            };

            # https://mangowm.github.io/docs/visuals/animations#fade-settings
            animation_fade_in = 1;
            animation_fade_out = 1;
            fadein_begin_opacity = 0.5;
            fadeout_begin_opacity = 0.8;

            # https://mangowm.github.io/docs/visuals/animations#zoom-settings
            zoom = {
              initial_ratio = 0.3;
              end_ratio = 0.8;
            };

            # https://mangowm.github.io/docs/visuals/animations#durations
            animation_duration = {
              move = 500;
              open = 400;
              tag = 350;
              close = 800;
              focus = 0;
            };

            # https://mangowm.github.io/docs/visuals/animations#custom-bezier-curves
            animation_curve = {
              open = "0.46,1.0,0.29,1";
              move = "0.46,1.0,0.29,1";
              tag = "0.46,1.0,0.29,1";
              close = "0.08,0.92,0,1";
              focus = "0.46,1.0,0.29,1";
            };

            # https://mangowm.github.io/docs/visuals/animations#tag-animation-direction
            tag_animation_direction = 1;

            ###########
            # Layouts #
            ###########
            # https://mangowm.github.io/docs/window-management/layouts#scroller-layout
            scroller_structs = 20;
            scroller_default_proportion = 0.8;
            scroller_focus_center = 0;
            scroller_prefer_center = 0;
            scroller_prefer_overspread = 1;
            edge_scroller_pointer_focus = 1;
            edge_scroller_focus_allow_speed = 0.0;
            scroller_proportion_preset = "0.5,0.8,1.0";
            scroller_ignore_proportion_single = 0;
            scroller_default_proportion_single = 1.0;

            # https://mangowm.github.io/docs/window-management/layouts#master-stack-layouts
            new_is_master = 1;
            default_mfact = 0.50;
            default_nmaster = 1;
            tag_num = 9;
            tag_gather = 0;
            smartgaps = 0;
            center_master_overspread = 0;
            center_when_single_stack = 1;

            #########
            # Rules #
            #########
            # https://mangowm.github.io/docs/window-management/rules#tag-rules
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

            ############
            # Overview #
            ############
            # https://mangowm.github.io/docs/window-management/overview#overview-settings
            hotarea_size = 10;
            enable_hotarea = 1;
            hotarea_corner = 0;
            overviewgappi = 5;
            overviewgappo = 30;

            ##############
            # Scratchpad #
            ##############
            # https://mangowm.github.io/docs/window-management/scratchpad#appearance
            scratchpad_width_ratio = 0.8;
            scratchpad_height_ratio = 0.8;

            ################
            # Key Bindings #
            ################
            # https://mangowm.github.io/docs/bindings/keys#syntax
            bind = [
              "SUPER,r,reload_config"

              "SUPER+SHIFT,Return,spawn_shell,uwsm app -- ${osConfig.features.terminal.emulator}"
              "SUPER,e,spawn_shell,uwsm app -- ${osConfig.features.editor.gui}"
              "SUPER,u,spawn_shell,uwsm app -- ${osConfig.features.browser.default}"

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

              # Moonlight Client Keybindings
              "ALT+SHIFT,c,killclient"
              "ALT+SHIFT,f,togglefullscreen"
              "ALT+SHIFT,v,focusmon,HEADLESS-1"
            ];

            ####################
            # Mouse & Gestures #
            ####################
            # https://mangowm.github.io/docs/bindings/mouse-gestures#mouse-bindings
            mousebind = [
              "SUPER,btn_left,moveresize,curmove"
              "SUPER,btn_right,moveresize,curresize"
              # "NONE,btn_left,toggleoverview"
              # "NONE,btn_right,killclient"
            ];

            # https://mangowm.github.io/docs/bindings/mouse-gestures#axis-bindings
            axisbind = [
              "SUPER,UP,viewtoright_have_client"
              "SUPER,DOWN,viewtoleft_have_client"
            ];
          };
        };
      };
    };

  flake.homeModules.dank-material-shell =
    {
      osConfig,
      config,
      lib,
      pkgs,
      inputs,
      ...
    }:
    let
      mangoConfigPath = toString /home/${osConfig.primaryUser.username}/.config/mango;
      wallpaperDir = "/home/${osConfig.primaryUser.username}/NextCloud/Wallpapers/Desktop";
    in
    {
      config = lib.mkIf (osConfig.features.desktop-environment == "mango") {
        # https://danklinux.com/docs/dankmaterialshell/nixos-flake#configuration-options
        programs.dank-material-shell = {
          enable = true;

          systemd = {
            enable = true; # Systemd service for auto-start
            restartIfChanged = true; # Auto-restart dms.service when dank-material-shell changes
          };

          # Core features
          enableSystemMonitoring = true; # System monitoring widgets (dgop)
          enableVPN = osConfig.features.networking.vpn.enable; # VPN management widget
          enableDynamicTheming = false; # Wallpaper-based theming (matugen)
          enableAudioWavelength = true; # Audio visualizer (cava)
          enableCalendarEvents = true; # Calendar integration (khal)
          enableClipboardPaste = true; # Pasting items from the clipboard (wtype)

          settings = {
            # Theme
            currentThemeName = "custom";
            currentThemeCategory = "custom";
            customThemeFile = "/home/${osConfig.primaryUser.username}/.config/DankMaterialShell/themes/dracula.json";
            dynamicTheming = false;

            # Widget Styling
            widgetColorMode = "colorful";
            cornerRadius = 10;

            # Icon Theme
            iconThemeDark = "${iconThemeName}";
            iconThemeLight = "System Default";
            iconThemePerMode = false;
            lastAppliedIconTheme = "${iconThemeName}";

            # Time Format
            use24HourClock = false;
            showSeconds = false;
            padHours12Hour = false;

            # Date Format
            showWeekNumber = true;
            firstDayOfWeek = -1;
            calendarBackend = "auto";

            # Weather
            weatherEnabled = true;
            useFahrenheit = true;
            useAutoLocation = true;

            # System Sounds
            soundsEnabled = true;
            useSystemSoundTheme = false;
            soundLogin = false;
            soundNewNotification = true;
            soundVolumeChanged = true;
            soundPluggedIn = true;
            muteSoundsWhenMediaPlaying = true;

            # Workspace Settings
            showWorkspaceIndex = false;
            showWorkspaceName = true;
            showWorkspacePadding = false;

            # On-screen Displays
            osdAlwaysShowValue = true;
            osdPosition = 5;
            osdVolumeEnabled = true;
            osdMediaVolumeEnabled = true;
            osdMediaPlaybackEnabled = false;
            osdBrightnessEnabled = true;
            osdIdleInhibitorEnabled = true;
            osdMicMuteEnabled = true;
            osdCapsLockEnabled = true;
            osdPowerProfileEnabled = false;
            osdAudioOutputEnabled = true;

            # Lock Screen Behavior
            lockBeforeSuspend = true;
            loginctlLockIntegration = true;

            # Battery Protection & Charging
            batteryLowThreshold = 20;
            batteryNotifyLow = false;
            batteryNotificationType = 0;
            batteryCriticalThreshold = 10;
            batteryNotifyCritical = true;

            # Control Center
            controlCenterTileColorMode = "primary";
            controlCenterShowNetworkIcon = true;
            controlCenterShowBluetoothIcon = true;
            controlCenterShowAudioIcon = true;
            controlCenterShowAudioPercent = false;
            controlCenterShowVpnIcon = true;
            controlCenterShowBrightnessIcon = false;
            controlCenterShowBrightnessPercent = false;
            controlCenterShowMicIcon = false;
            controlCenterShowMicPercent = false;
            controlCenterShowBatteryIcon = false;
            controlCenterShowPrinterIcon = false;
            controlCenterShowScreenSharingIcon = true;
            controlCenterShowIdleInhibitorIcon = false;
            controlCenterShowDoNotDisturbIcon = false;
            centeringMode = "geometric";
            controlCenterWidgets = [
              {
                id = "volumeSlider";
                enabled = true;
                width = 50;
              }
              {
                id = "brightnessSlider";
                enabled = true;
                width = 50;
              }
              {
                id = "wifi";
                enabled = true;
                width = 50;
              }
              {
                id = "bluetooth";
                enabled = true;
                width = 50;
              }
              {
                id = "audioOutput";
                enabled = true;
                width = 50;
              }
              {
                id = "audioInput";
                enabled = true;
                width = 50;
              }
              {
                id = "builtin_vpn";
                enabled = true;
                width = 50;
              }
              {
                id = "doNotDisturb";
                enabled = true;
                width = 50;
              }
              {
                id = "idleInhibitor";
                enabled = true;
                width = 50;
              }
              {
                id = "nightMode";
                enabled = true;
                width = 50;
              }
            ];

            # Dank Bar
            barConfigs = [
              {
                id = "default";
                name = "Main Bar";
                enabled = true;
                position = 0;
                screenPreferences = [
                  "all"
                ];
                showOnLastDisplay = true;
                leftWidgets = [
                  "launcherButton"
                  "workspaceSwitcher"
                  "focusedWindow"
                ];
                centerWidgets = [
                  "music"
                  "clock"
                  "weather"
                ];
                rightWidgets = [
                  "systemTray"
                  "clipboard"
                  {
                    id = "diskUsage";
                    enabled = true;
                    mountPath = "/";
                    diskUsageMode = 0;
                    minimumWidth = true;
                  }
                  "cpuUsage"
                  "memUsage"
                  {
                    id = "controlCenterButton";
                    enabled = true;
                    showAudioPercent = true;
                    showBrightnessIcon = true;
                    showMicIcon = true;
                    showMicPercent = true;
                    showBatteryIcon = true;
                    showPrinterIcon = true;
                    showIdleInhibitorIcon = true;
                    showDoNotDisturbIcon = true;
                    showBrightnessPercent = true;
                  }
                  "notificationButton"
                ];
                spacing = 4;
                innerPadding = 4;
                bottomGap = 0;
                transparency = 0;
                widgetTransparency = 0.85;
                squareCorners = false;
                noBackground = false;
                gothCornersEnabled = false;
                gothCornerRadiusOverride = false;
                borderEnabled = false;
                fontScale = 1;
                autoHide = false;
                openOnOverview = false;
                visible = true;
                popupGapsAuto = true;
                maximizeWidgetText = false;
                removeWidgetPadding = false;
                maximizeWidgetIcons = false;
                widgetOutlineEnabled = false;
                iconScale = 1;
                barInsetPadding = 4;
                useOverlayLayer = false;
                hoverPopouts = false;
              }
            ];
          };

          session = {
            # Wallpaper
            perMonitorWallpaper = false;
            perModeWallpaper = false;
            wallpaperTransition = "random";
            includedTransitions = [
              "fade"
              "wipe"
              "disc"
              "stripes"
              "iris bloom"
              "pixelate"
              "portal"
            ];
            wallpaperCyclingEnabled = false;

            # Night Mode
            nightModeEnabled = true;
            nightModeTemperature = 4500;
            nightModeHighTemperature = 6500;
            nightModeAutoEnabled = true;
            nightModeAutoMode = "location";
            nightModeStartHour = 18;
            nightModeStartMinute = 0;
            nightModeEndHour = 6;
            nightModeEndMinute = 0;
            nightModeUseIPLocation = true;
            nightModeLocationProvider = "";

            # Dark Mode
            isLightMode = false;
          };
        };

        xdg.configFile."DankMaterialShell/themes/dracula.json".source =
          "${inputs.dracula-dank-material-shell}/themes/dracula/theme.json";

        systemd.user.services.dms-wallpaper-randomizer = {
          Unit = {
            Description = "Select a random DMS wallpaper on startup";
            BindsTo = [ "dms.service" ];
            After = [
              "graphical-session.target"
              "dms.service"
            ];
          };

          Service = {
            Type = "oneshot";

            ExecStart = pkgs.writeShellScript "dms-random-picker" ''
              if [ ! -d "${wallpaperDir}" ]; then
                echo "Error: Wallpaper directory '${wallpaperDir}' does not exist."
                exit 1
              fi

              # Select a random wallpaper
              RANDOM_WP=$(${pkgs.findutils}/bin/find "${wallpaperDir}" -type f | ${pkgs.coreutils}/bin/shuf -n 1)

              if [ -z "$RANDOM_WP" ]; then
                echo "Error: No wallpaper files were found in '${wallpaperDir}'."
                exit 1
              fi

              echo "Selected wallpaper candidate: '$RANDOM_WP'"

              # Retry up to 15 seconds for DMS IPC target to become available
              for i in $(${pkgs.coreutils}/bin/seq 1 15); do
                OUTPUT=$(${config.programs.dank-material-shell.package}/bin/dms ipc call wallpaper set "$RANDOM_WP" 2>&1)
                if [ $? -eq 0 ] && [[ "$OUTPUT" != *"Target not found"* ]]; then
                  echo "Success: Set wallpaper to '$RANDOM_WP' on attempt $i."
                  exit 0
                fi
                ${pkgs.coreutils}/bin/sleep 1
              done

              echo "Error: Timed out waiting for DMS IPC target 'wallpaper' after 15 seconds."
              echo "Last DMS IPC response: $OUTPUT"
              exit 1
            '';
          };

          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
        };

        # https://danklinux.com/docs/dankmaterialshell/compositors#mangowc-configuration
        wayland.windowManager.mango = {
          settings.bind = [
            # Application Launchers
            "SUPER,p,spawn,dms ipc call spotlight toggle"
            "SUPER,b,spawn,dms ipc call bar toggle index 0"
            "SUPER,w,spawn,dms ipc call dankdash wallpaper"

            # Menus
            "SUPER+CTRL,p,spawn,dms ipc call control-center toggle"
            "SUPER+CTRL,c,spawn,dms ipc call clipboard toggle"
            "SUPER+CTRL,n,spawn,dms ipc call notifications toggle"
            "SUPER+CTRL,q,spawn,dms ipc call powermenu toggle"

            # Volume Controls
            "NONE,XF86AudioRaiseVolume,spawn,dms ipc call audio increment 5"
            "NONE,XF86AudioLowerVolume,spawn,dms ipc call audio decrement 5"
            "NONE,XF86AudioMute,spawn,dms ipc call audio mute"

            # Brightness Controls
            "NONE,XF86MonBrightnessUp,spawn,dms ipc call brightness increment 5"
            "NONE,XF86MonBrightnessDown,spawn,dms ipc call brightness decrement 5"

            # Media Controls
            "NONE,XF86AudioNext,spawn,dms ipc call mpris next"
            "NONE,XF86AudioPause,spawn,dms ipc call mpris playPause"
            "NONE,XF86AudioPlay,spawn,dms ipc call mpris playPause"
            "NONE,XF86AudioPrev,spawn,dms ipc call mpris previous"

            # Screenshot
            "NONE,Print,spawn_shell,dms screenshot --stdout | ${pkgs.swappy}/bin/swappy -f -"
          ];

          extraConfig = ''
            # Disable animation on DMS layers
            layerrule=noanim:1,layer_name:^dms
          '';
        };
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

  flake.nixosModules.file-explorer =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      config = lib.mkIf (config.features.desktop-environment == "mango") {
        # https://wiki.nixos.org/wiki/Thunar
        programs.thunar = {
          enable = true;
          plugins = with pkgs; [
            thunar-archive-plugin
            thunar-media-tags-plugin
            thunar-vcs-plugin
            thunar-volman
          ];
        };
        programs.xfconf.enable = true;
        services.gvfs.enable = true; # Mount, trash, and other functionalities
        services.tumbler.enable = true; # Thumbnail support for images

        environment.systemPackages = with pkgs; [
          engrampa
          p7zip
          unzip
          zip
        ];
      };
    };

  flake.homeModules.danksearch =
    {
      osConfig,
      config,
      lib,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.desktop-environment == "mango") {
        # https://danklinux.com/docs/danksearch/nixos-flake
        programs.dsearch = {
          enable = true;

          # Custom configuration (TOML format)
          # See https://danklinux.com/docs/danksearch/configuration for full list of options
          config = {
            # Server configuration
            listen_addr = ":43654";

            # Index settings
            index_path = "~/.cache/danksearch/index";
            max_file_bytes = 2097152; # 2MB
            worker_count = 4;
            index_all_files = true;

            # Auto-reindex settings
            auto_reindex = false;
            reindex_interval_hours = 24;

            # Text file extensions
            text_extensions = [
              ".txt"
              ".md"
              ".go"
              ".py"
              ".js"
              ".ts"
              ".jsx"
              ".tsx"
              ".json"
              ".yaml"
              ".yml"
              ".toml"
              ".html"
              ".css"
              ".rs"
            ];

            # Index paths configuration
            index_paths = [
              {
                path = "~";
                max_depth = 0; # No limit
                exclude_hidden = true;
                exclude_dirs = [
                  "node_modules"
                  ".git"
                  "target"
                  "dist"
                  "build"
                ];
              }
            ];
          };
        };
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

  flake.homeModules.theme =
    { pkgs, ... }:
    {
      gtk = {
        enable = true;
        colorScheme = "dark";

        # Theme
        gtk4.theme = null;
        theme = {
          name = "${gtkThemeName}";
          package = pkgs.${gtkThemePackage};
        };

        # Icons
        iconTheme = {
          name = "${iconThemeName}";
          package = pkgs.${iconThemePackage};
        };

        # Cursors
        cursorTheme = {
          name = "${cursorThemeName}";
          package = pkgs.${cursorThemePackage};
          size = cursorSize;
        };
      };

      qt = {
        enable = true;
        platformTheme.name = "qtct";
        style.name = "kvantum";
      };

      home.packages = with pkgs; [
        hicolor-icon-theme
        libsForQt5.qtstyleplugin-kvantum # Engine backing for Qt5 applications
        kdePackages.qtstyleplugin-kvantum # Engine backing for Qt6 applications (Kdenlive)
        libsForQt5.qt5ct # Layout controller for Qt5 apps
        kdePackages.qt6ct # Layout controller for Qt6 apps
      ];

      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "${gtkThemeName}";
          icon-theme = "${iconThemeName}";
          cursor-theme = "${cursorThemeName}";
        };
      };

      home.sessionVariables = {
        XDG_DATA_DIRS = "$XDG_DATA_DIRS:${pkgs.${iconThemePackage}}/share:${pkgs.hicolor-icon-theme}/share";
      };

      systemd.user.sessionVariables = {
        XDG_DATA_DIRS = "$XDG_DATA_DIRS:${pkgs.${iconThemePackage}}/share:${pkgs.hicolor-icon-theme}/share";
      };

      xdg.configFile = {
        # # Dracula GTK theme has a bug: https://github.com/dracula/gtk/issues/316
        # "gtk-4.0/assets".source = "${pkgs.${gtkThemePackage}}/share/themes/Dracula/gtk-4.0/assets";
        # "gtk-4.0/gtk.css".source = "${pkgs.${gtkThemePackage}}/share/themes/Dracula/gtk-4.0/gtk.css";
        # "gtk-4.0/gtk-dark.css".source =
        #   "${pkgs.${gtkThemePackage}}/share/themes/Dracula/gtk-4.0/gtk-dark.css";

        "Kvantum/kvantum.kvconfig".text = ''
          [General]
          theme=Dracula-purple-solid
        '';

        "Kvantum/Dracula".source = "${pkgs.${gtkThemePackage}}/share/Kvantum/Dracula";
        "Kvantum/Dracula-purple".source = "${pkgs.${gtkThemePackage}}/share/Kvantum/Dracula-purple";
        "Kvantum/Dracula-purple-solid".source =
          "${pkgs.${gtkThemePackage}}/share/Kvantum/Dracula-purple-solid";
        "Kvantum/Dracula-Solid".source = "${pkgs.${gtkThemePackage}}/share/Kvantum/Dracula-Solid";

        "qt5ct/qt5ct.conf".text = ''
          [Appearance]
          style=kvantum
          icon_theme=${iconThemeName}
        '';

        "qt6ct/qt6ct.conf".text = ''
          [Appearance]
          style=kvantum
          icon_theme=${iconThemeName}
        '';
      };
    };

  flake.homeModules.display =
    {
      config,
      osConfig,
      lib,
      ...
    }:
    {
      config = lib.mkIf osConfig.features.display.kanshi.enable {
        services.kanshi = {
          enable = true;
          systemdTarget = "graphical-session.target";
          settings = osConfig.features.display.kanshi.profiles;
        };
      };
    };
}
