{ self, config, ... }:

{
  flake.nixosModules.gaming = {
    imports = [
      self.nixosModules.gamemode
      self.nixosModules.gamescope
      self.nixosModules.steam
      self.nixosModules.wine
      self.nixosModules.vkbasalt
      self.nixosModules.sunshine
    ];
  };

  flake.homeModules.gaming = {
    imports = [
      self.homeModules.lutris
      self.homeModules.faugus
      self.homeModules.mangohud
      self.homeModules.chiaki
      self.homeModules.prism-launcher
      self.homeModules.vintage-story
      self.homeModules.hytale-launcher
      self.homeModules.heroic
      self.homeModules.moonlight
    ];
  };

  flake.nixosModules.gamemode =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.features.gaming.gamemode.enable) {
        # https://wiki.nixos.org/wiki/GameMode
        users.users."${config.primaryUser.username}".extraGroups = [ "gamemode" ];
        programs.gamemode = {
          enable = true;
          enableRenice = true;
          settings = {
            general = {
              reaper_freq = 5;
              desiredgov = "performance";
              defaultgov = "powersave";
              igpu_desiredgov = "powersave";
              igpu_power_threshold = 0.3;
              softrealtime = "off";
              renice = 10;
              ioprio = 0;
              inhibit_screensaver = 1;
              disable_splitlock = 1;
            };
          };
        };
      };
    };

  flake.nixosModules.gamescope = { lib, config, ... }: {
    config = lib.mkIf (config.features.gaming.gamescope.enable) {
      programs.gamescope = {
        enable = true;
        enableWsi = true;
        capSysNice = false;
      };
    };
  };

  flake.nixosModules.steam =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf (config.features.gaming.steam.enable) {
        # https://wiki.nixos.org/wiki/Steam
        programs.steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = false;
          extraCompatPackages = with pkgs; [
            proton-ge-bin
          ];
          extraPackages = [
            pkgs.hidapi # Dependency for Steam Controller (2026)
          ];
        };

        environment.systemPackages = with pkgs; [
          steam-run # Allows running games that expect an FHS-like environment
        ];
      };
    };

  flake.nixosModules.wine =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      config = lib.mkIf (config.features.gaming.wine.enable) {
        environment.systemPackages = with pkgs; [
          # https://wiki.nixos.org/wiki/Wine
          wineWow64Packages.unstable
          winetricks
          protonplus
          protontricks
        ];
      };
    };

  flake.nixosModules.vkbasalt =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      config = lib.mkIf (config.features.gaming.vkbasalt.enable) {
        environment.systemPackages = with pkgs; [
          vkbasalt
          vkbasalt-cli
        ];
      };
    };

  flake.nixosModules.sunshine =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf (config.features.gaming.sunshine.enable) {
        # https://wiki.nixos.org/wiki/Sunshine
        services.sunshine = {
          enable = true;
          autoStart = true;
          capSysAdmin = true;
          openFirewall = true;

          # https://docs.lizardbyte.dev/projects/sunshine/latest/md_docs_2configuration.html
          settings = {
            ###########
            # General #
            ###########
            locale = "en";
            sunshine_name = config.networking.hostName;
            global_prep_cmd = lib.mkIf (config.features.desktop-environment == "mango") (
              builtins.toJSON [
                {
                  do = "${pkgs.writeShellScript "sunshine-global-prep-do" ''
                    set -euo pipefail

                    # Enable virtual display
                    ${pkgs.mango}/bin/mmsg dispatch enable_monitor,HEADLESS-1

                    # Wait for HEADLESS-1 to be active
                    for i in $(seq 1 30); do
                      if ${pkgs.wlr-randr}/bin/wlr-randr | ${pkgs.gnugrep}/bin/grep -A 1 "HEADLESS-1" | ${pkgs.gnugrep}/bin/grep -q "Enabled: yes"; then
                        break
                      fi
                      sleep 0.1
                    done

                    # Get client parameters from Sunshine
                    WIDTH="''${SUNSHINE_CLIENT_WIDTH:-1920}"
                    HEIGHT="''${SUNSHINE_CLIENT_HEIGHT:-1080}"
                    FPS="''${SUNSHINE_CLIENT_FPS:-60}"

                    # Apply custom mode and position to virtual display
                    ${pkgs.wlr-randr}/bin/wlr-randr --output HEADLESS-1 --custom-mode "''${WIDTH}x''${HEIGHT}@''${FPS}Hz" --pos 1920,0 --scale 1 --on

                    # Switch focus to virtual display
                    ${pkgs.mango}/bin/mmsg dispatch focusmon,HEADLESS-1
                  ''}";

                  undo = "${pkgs.writeShellScript "sunshine-global-prep-undo" ''
                    set -euo pipefail

                    # Disable virtual display
                    ${pkgs.mango}/bin/mmsg dispatch disable_monitor,HEADLESS-1
                  ''}";
                }
              ]
            );
            notify_pre_releases = false;
            system_tray = true;

            #########
            # Input #
            #########
            controller = true;
            gamepad = "auto";
            keyboard = true;
            mouse = true;

            #################
            # Audio / Video #
            #################
            stream_audio = true;
            output_name = "HEADLESS-1";
          };

          applications.apps = [
          ]
          ++ lib.optional config.features.gaming.lutris.enable {
            name = "Lutris";
            cmd = "${pkgs.lutris}/bin/lutris";
            auto-detach = false;
            exclude-global-prep-cmd = false;
          }
          ++ lib.optional config.features.gaming.faugus.enable {
            name = "Faugus";
            cmd = "${pkgs.faugus-launcher}/bin/faugus-launcher";
            auto-detach = false;
            exclude-global-prep-cmd = false;
          };
        };

        users.users."${config.primaryUser.username}".extraGroups = [ "uinput" ];
        hardware.uinput.enable = true;
      };
    };

  flake.homeModules.lutris =
    {
      pkgs,
      osConfig,
      lib,
      ...
    }:
    let
      gamePreLaunch = pkgs.writeShellScript "game-pre-launch" ''
        ${lib.optionalString (osConfig.features.gaming.gamemode.enable) ''
          ${pkgs.gamemode}/bin/gamemoded -r &
          STATUS=$(${pkgs.gamemode}/bin/gamemoded -s)
          ${pkgs.libnotify}/bin/notify-send -i input-gaming -u normal "GameMode" "$STATUS"
        ''}

        ${lib.optionalString (osConfig.features.desktop-environment == "mango") ''
          dms ipc call inhibit enable
          dms ipc call notifications enableDoNotDisturbIndefinitely
        ''}
      '';
      gamePostExit = pkgs.writeShellScript "game-mode-disable" ''
        ${lib.optionalString (osConfig.features.desktop-environment == "mango") ''
          dms ipc call notifications disableDoNotDisturb
          dms ipc call inhibit disable
        ''}

        ${lib.optionalString (osConfig.features.gaming.gamemode.enable) ''
          pkill gamemoded
          STATUS=$(${pkgs.gamemode}/bin/gamemoded -s)
          ${pkgs.libnotify}/bin/notify-send -i input-gaming -u normal "GameMode" "$STATUS"
        ''}
      '';
    in
    {
      config = lib.mkIf (osConfig.features.gaming.lutris.enable) {
        programs.lutris = {
          enable = true;
          package = pkgs.lutris;
        };

        # TODO: Add Lutris settings

        # Pre Launch and Post Exit Scripts
        home.file.".local/bin/game-pre-launch.sh".source = gamePreLaunch;
        home.file.".local/bin/game-post-exit.sh".source = gamePostExit;
      };
    };

  flake.homeModules.faugus =
    {
      pkgs,
      config,
      osConfig,
      lib,
      ...
    }:
    let
      user = osConfig.primaryUser.username;

      baseConfig = {
        "accent-color" = "system";
        "auto-close-on-launch" = "False";
        "automatic-updates" = "True";
        "autostart-enabled" = "False";
        "background-mode" = "default";
        "backup-auto-enabled" = "False";
        "backup-dest-dir" = "";
        "backup-frequency" = "daily";
        "backup-last-date" = "";
        "backup-target-day" = "0";
        "banner-enabled" = "True";
        "categories-and-sort-enabled" = "True";
        "category" = "all";
        "cover-size" = "100";
        "default-prefix" = "/home/${osConfig.primaryUser.username}/Games/Faugus";
        "default-runner" = "Proton-GE Latest";
        "discrete-gpu" = "False";
        "donate-last" = "";
        "gamepad-navigation" = "True";
        "gamemode" = "True";
        "header-bar" = "True";
        "height" = "720";
        "interface-mode" = "SteamGridDB";
        "interface-theme" = "system";
        "labels-enabled" = "False";
        "language" = "en_US";
        "logging-enabled" = "False";
        "logging-warning" = "False";
        "lossless-location" = "";
        "mangohud" = "True";
        "minimized-startup-enabled" = "False";
        "mono-icon" = "False";
        "no-sleep-enabled" = "True";
        "playtime" = 0;
        "sdl-enabled" = "False";
        "show-donate" = "True";
        "show-hidden" = "False";
        "sort" = "alpha";
        "splash-window-enabled" = "True";
        "startup-window-size" = "None";
        "steam-user" = "all";
        "steamgriddb-api-key" = "@API_KEY@"; # Placeholder
        "system-tray" = "True";
        "theme-engine" = "system";
        "wayland-driver" = "False";
        "width" = "1280";
        "wow64-enabled" = "False";
        "zoom-enabled" = "True";
      };

      configFileTemplate = pkgs.writeText "faugus-config-template.json" (builtins.toJSON baseConfig);
    in
    {
      config = lib.mkIf (osConfig.features.gaming.faugus.enable) {
        home.packages = with pkgs; [
          faugus-launcher
        ];

        sops.secrets."API_KEYS__STEAMGRIDDB" = { };
        # Replace placeholder with secret on home-manager switch/activation
        home.activation.setupFaugusConfig = lib.hm.dag.entryAfter [ "writeBoundary" "sops-nix" ] ''
          KEY=$(cat ${config.sops.secrets."API_KEYS__STEAMGRIDDB".path} 2>/dev/null || echo "")

          # Target directory (change to ~/.config/faugus-launcher if needed)
          TARGET_DIR="$HOME/faugus-launcher"
          mkdir -p "$TARGET_DIR"

          ${pkgs.gnused}/bin/sed "s|@API_KEY@|$KEY|g" ${configFileTemplate} > "$TARGET_DIR/config.json"
          chmod 600 "$TARGET_DIR/config.json"
        '';
      };
    };

  flake.homeModules.mangohud =
    {
      lib,
      osConfig,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.gaming.mangohud.enable) {
        home.packages = with pkgs; [
          mangojuice
        ];

        programs.mangohud.enable = true;
        # TODO: Add mangohud settings
      };
    };

  flake.homeModules.chiaki =
    {
      pkgs,
      lib,
      osConfig,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.gaming.chiaki.enable) {
        home.packages = with pkgs; [
          chiaki-ng
        ];
      };
    };

  flake.homeModules.prism-launcher =
    {
      pkgs,
      lib,
      osConfig,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.gaming.prism-launcher.enable) {
        # https://wiki.nixos.org/wiki/Prism_Launcher
        home.packages = with pkgs; [
          prismlauncher
        ];
      };
    };

  flake.homeModules.vintage-story =
    {
      pkgs,
      lib,
      osConfig,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.gaming.vintage-story.enable) {
        home.packages = with pkgs; [
          vintagestory
        ];
      };
    };

  flake.homeModules.hytale-launcher =
    {
      pkgs,
      lib,
      osConfig,
      inputs,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.gaming.hytale-launcher.enable) {
        home.packages = with pkgs; [
          inputs.hytale-launcher.packages."${pkgs.stdenv.hostPlatform.system}".default
        ];
      };
    };

  flake.homeModules.heroic =
    {
      pkgs,
      lib,
      osConfig,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.gaming.heroic.enable) {
        # https://wiki.nixos.org/wiki/Heroic_Games_Launcher
        home.packages = with pkgs; [
          heroic
        ];
      };
    };

  flake.homeModules.moonlight =
    {
      pkgs,
      lib,
      osConfig,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.gaming.moonlight.enable) {
        home.packages = with pkgs; [
          moonlight-qt
        ];
      };
    };
}
