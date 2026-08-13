{ self, config, ... }:

{
  flake.homeModules.terminal =
    { pkgs, osConfig, ... }:
    {
      imports = [
        self.homeModules.shell
        self.homeModules.terminal-emulator
      ];

      home.sessionVariables.TERMINAL = osConfig.features.terminal.emulator;
    };

  flake.homeModules.shell = {
    imports = [
      self.homeModules.bash
      self.homeModules.fish
      self.homeModules.starship
      self.homeModules.eza
      self.homeModules.tmux
      self.homeModules.grep
    ];
  };

  flake.homeModules.bash =
    {
      pkgs,
      config,
      osConfig,
      lib,
      inputs,
      ...
    }:
    let
      nixosConfigPath = toString osConfig.primaryUser.nixosConfigPath;
      bashTtyScript = builtins.readFile "${inputs.dracula-tty}/dracula-tty.sh";
    in
    {
      config = lib.mkIf (osConfig.features.terminal.bash.enable) {
        programs.bash = {
          enable = true;
          initExtra = ''
            # TTY/Linux console coloring tweaks
            ${bashTtyScript}
          '';
        };

        home.packages = with pkgs; [
          bash-completion
        ];
      };
    };

  flake.homeModules.fish =
    {
      pkgs,
      config,
      osConfig,
      lib,
      inputs,
      ...
    }:
    let
      nixosConfigPath = toString osConfig.primaryUser.nixosConfigPath;

      bashTtyScript = builtins.readFile "${inputs.dracula-tty}/dracula-tty.sh";
      # Convert POSIX 'if/then/fi' syntax to native Fish 'if/end' syntax dynamically
      fishTtyScript =
        builtins.replaceStrings
          [ "if [ \"$TERM\" = \"linux\" ]; then" "fi" ]
          [ "if test \"$TERM\" = \"linux\"" "end" ]
          bashTtyScript;
    in
    {
      config = lib.mkIf (osConfig.features.terminal.fish.enable) {
        # https://wiki.nixos.org/wiki/Fish
        programs.fish = {
          enable = true;
          generateCompletions = true;

          functions = {
            fish_greeting = {
              body = ''
                clear
                krabby random
                echo "¸.·´¯`·.´¯`·.¸¸.·´¯`·.¸><(((º>"
              '';
            };
          };

          interactiveShellInit = ''
            # Choose Dracula Theme
            fish_config theme choose "Dracula_Official"

            # TTY/Linux console coloring tweaks
            ${fishTtyScript}
          '';
        };
        xdg.configFile."fish/themes/Dracula_Official.theme".source =
          "${inputs.dracula-fish}/themes/Dracula Official.theme";

        home.packages = with pkgs; [
          krabby
        ];
      };
    };

  flake.homeModules.starship =
    {
      config,
      osConfig,
      lib,
      pkgs,
      inputs,
      ...
    }:
    let
      baseStarshipToml = builtins.readFile "${inputs.dracula-pro-starship}/starship/themes/dracula-pro.toml";
      baseConfig = builtins.fromTOML baseStarshipToml;

      myOverrides = {
        add_newline = false;
        command_timeout = 1000;

        format = lib.concatStrings [
          "[](comment)"
          "$directory"
          "[](fg:comment bg:pink)"
          "$git_branch"
          "$git_status"
          "[](fg:pink bg:cyan)"
          "$c"
          "$elixir"
          "$elm"
          "$golang"
          "$haskell"
          "$java"
          "$julia"
          "$nodejs"
          "$nim"
          "$rust"
          "[](fg:orange bg:green)"
          "$cmd_duration"
          "[](fg:green)"
          "\n"
          "$character"
        ];

        character = {
          format = "$symbol";
          success_symbol = "[  󱞪 ❯❯❯](bold green)  ";
          error_symbol = "[  󱞪 ❯❯❯](bold red)  ";
        };

        username = {
          show_always = true;
          style_user = "bg:current_line";
          style_root = "bg:current_line";
          format = "[ ]($style)";
        };

        directory = {
          style = "bg:comment fg:foreground";
          format = "[ $path ]($style)";
          truncation_length = 4;
          truncate_to_repo = true;
          truncation_symbol = "…/";
          read_only = "";
          substitutions = {
            ".config" = "  ";
            "~" = " ";
            "Attachments" = " 󰁦 ";
            "Books" = " 󱉟 ";
            "config" = "  ";
            "Config" = "  ";
            "Data" = "  ";
            "Desktop" = "  ";
            "Documents" = " 󰈙 ";
            "Downloads" = "  ";
            "dropbox" = "  ";
            "Finances" = "  ";
            "Games" = "  ";
            "google-drive" = "  ";
            "ISOs" = " 󰗮 ";
            "Music" = "  ";
            "onedrive" = "  ";
            "Personal" = "  ";
            "Pictures" = "  ";
            "PrismLauncher" = " 󰍳 ";
            "Projects" = " 󰊢";
            "Spotify" = "  ";
            "Steam" = "  ";
            "System" = "  ";
            "Videos" = "  ";
          };
        };

        direnv = {
          symbol = "  ";
          style = "bg:orange fg:background";
          format = "[ $symbol$loaded/$allowed ]($style)";
          disabled = true;
        };

        c = {
          symbol = " ";
          style = "bg:cyan fg:background";
          format = "[ $symbol ($version) ]($style)";
        };

        cmd_duration = {
          min_time = 0;
          style = "bg:green fg:background";
          format = "[ 󱎫 $duration ]($style)";
          show_notifications = true;
          min_time_to_notify = 5000;
        };

        docker_context = {
          symbol = " ";
          style = "bg:orange fg:background";
          format = "[ $symbol $context ]($style) $path";
        };

        elixir = {
          symbol = " ";
          style = "bg:cyan fg:background";
          format = "[ $symbol ($version) ]($style)";
        };

        elm = {
          symbol = " ";
          style = "bg:cyan fg:background";
          format = "[ $symbol ($version) ]($style)";
        };

        git_branch = {
          symbol = "";
          style = "bg:pink fg:background";
          format = "[ $symbol $branch ]($style)";
        };

        git_status = {
          style = "bg:pink fg:background";
          format = "[($all_status$ahead_behind )]($style)";
        };

        golang = {
          symbol = " ";
          style = "bg:cyan fg:background";
          format = "[ $symbol ($version) ]($style)";
        };

        haskell = {
          symbol = " ";
          style = "bg:cyan fg:background";
          format = "[ $symbol ($version) ]($style)";
        };

        java = {
          symbol = " ";
          style = "bg:cyan fg:background";
          format = "[ $symbol ($version) ]($style)";
        };

        julia = {
          symbol = " ";
          style = "bg:cyan fg:background";
          format = "[ $symbol ($version) ]($style)";
        };

        nodejs = {
          symbol = "";
          style = "bg:cyan fg:background";
          format = "[ $symbol ($version) ]($style)";
        };

        nim = {
          symbol = " ";
          style = "bg:cyan fg:background";
          format = "[ $symbol ($version) ]($style)";
        };

        rust = {
          symbol = "";
          style = "bg:cyan fg:background";
          format = "[ $symbol ($version) ]($style)";
        };

        time = {
          disabled = false;
          time_format = "%X";
          style = "bg:orange";
          format = "[[  $time ](bg:orange)]($style)";
        };
      };
      finalConfig = lib.recursiveUpdate baseConfig myOverrides;
    in
    {
      # https://wiki.nixos.org/wiki/Starship
      programs.starship = {
        enable = true;
        enableBashIntegration = osConfig.features.terminal.bash.enable;
        enableFishIntegration = osConfig.features.terminal.fish.enable;
        settings = finalConfig;
      };
    };

  flake.homeModules.eza =
    {
      config,
      osConfig,
      lib,
      pkgs,
      inputs,
      ...
    }:
    {
      programs.eza = {
        enable = true;
        enableBashIntegration = osConfig.features.terminal.bash.enable;
        enableFishIntegration = osConfig.features.terminal.fish.enable;
        git = true;
        icons = "auto";
      };

      xdg.configFile."eza/theme.yml".source = "${inputs.eza-themes}/themes/dracula.yml";

      home.shellAliases = {
        # Replace ls and tree with eza
        ls = "eza";
        tree = "eza -T";
      };
    };

  flake.homeModules.tmux =
    {
      config,
      osConfig,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.terminal.tmux.enable) {
        # https://wiki.nixos.org/wiki/Tmux
        programs.tmux = {
          enable = true;
          shortcut = "a"; # Changes prefix from C-b to C-a
          secureSocket = true;
          shell =
            if osConfig.features.terminal.fish.enable then
              "${pkgs.fish}/bin/fish"
            else if osConfig.features.terminal.bash.enable then
              "${pkgs.bashInteractive}/bin/bash"
            else
              "/run/current-system/sw/bin/bash";
          mouse = true;
          sensibleOnTop = true;

          plugins = with pkgs.tmuxPlugins; [
            {
              plugin = dracula;
              extraConfig = ''
                set -g @dracula-show-powerline true
                set -g @dracula-show-flags true
                set -g @dracula-refresh-rate 5
                set -g @dracula-show-left-icon session
                set -g @dracula-show-empty-plugins false
                set -g @dracula-plugins "git cpu-usage ram-usage battery time"
              '';
            }
          ];

          extraConfig = ''
            # Window splitting overrides
            bind | split-window -h
            bind - split-window -v
            unbind '"'
            unbind %

            # Quick reload shortcut (Points to the Home Manager generated config path)
            bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded..."

            # Pane navigation (Alt + Arrow / Alt + Vim keys)
            bind -n M-Left select-pane -L
            bind -n M-h select-pane -L

            bind -n M-Right select-pane -R
            bind -n M-l select-pane -R

            bind -n M-Up select-pane -U
            bind -n M-k select-pane -U

            bind -n M-Down select-pane -D
            bind -n M-j select-pane -D

            # Misc preferences
            set-option -g allow-rename off
            set -g pane-border-status top
          '';
        };
      };
    };

  flake.homeModules.grep =
    {
      config,
      osConfig,
      lib,
      pkgs,
      ...
    }:
    {
      programs = {
        grep = {
          enable = true;
          colors = {
            # Dracula theme for GNU grep - https://draculatheme.com/grep
            mt = "1;38;2;255;85;85";
            fn = "38;2;255;121;198";
            ln = "38;2;80;250;123";
            bn = "38;2;80;250;123";
            se = "38;2;139;233;253";
          };
        };

        ripgrep-all.enable = true;
      };

      home = {
        sessionVariables = {
          RIPGREP_CONFIG_PATH = "${config.xdg.configHome}/ripgrep/config";
        };
        shellAliases = {
          rgrep = "rga";
        };
      };

      xdg.configFile."ripgrep/config".text = ''
        # Dracula theme for ripgrep - https://draculatheme.com/ripgrep
        --colors=path:fg:0xbd,0x93,0xf9
        --colors=line:fg:0x50,0xfa,0x7b
        --colors=column:fg:0x50,0xfa,0x7b
        --colors=match:fg:0xff,0x55,0x55
      '';
    };

  flake.homeModules.terminal-emulator = {
    imports = [
      self.homeModules.ghostty
    ];
  };

  flake.homeModules.ghostty =
    {
      config,
      osConfig,
      lib,
      pkgs,
      inputs,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.terminal.emulator == "ghostty") {
        # https://wiki.nixos.org/wiki/Ghostty
        programs.ghostty = {
          enable = true;
          enableBashIntegration = osConfig.features.terminal.bash.enable;
          enableFishIntegration = osConfig.features.terminal.fish.enable;
          systemd.enable = true;
          settings = {
            command =
              if osConfig.features.terminal.tmux.enable then
                "${pkgs.tmux}/bin/tmux"
              else if osConfig.features.terminal.fish.enable then
                "${pkgs.fish}/bin/fish"
              else if osConfig.features.terminal.bash.enable then
                "${pkgs.bashInteractive}/bin/bash"
              else
                "/run/current-system/sw/bin/bash";

            font-family = "MonaspiceNe NFM";
            font-family-bold = "MonaspiceNe NFM Bold";
            font-family-italic = "MonaspiceNe NFM Italic";
            font-family-bold-italic = "MonaspiceNe NFM Bold Italic";
            font-size = 12.0;

            cursor-color = "#CCCCCC";
            cursor-opacity = 1;
            cursor-style = "bar";
            cursor-style-blink = true;

            mouse-scroll-multiplier = 0.5;

            theme = "dracula-pro";
            background-opacity = 0.8;

            window-decoration = false;
            window-padding-x = "5,5";
            window-padding-y = "5,0";

            copy-on-select = true;

            title = "Ghostty";
            auto-update = "off";
            desktop-notifications = true;
          };
        };

        xdg.configFile."ghostty/themes/dracula-pro".source = "${inputs.dracula-pro-ghostty}/pro";
      };
    };
}
