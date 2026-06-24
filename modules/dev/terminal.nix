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
    ];
  };

  flake.homeModules.bash =
    {
      pkgs,
      config,
      osConfig,
      lib,
      ...
    }:
    let
      nixosConfigPath = toString osConfig.primaryUser.nixosConfigPath;
      dotfilesPath = toString osConfig.primaryUser.dotfilesPath;
    in
    {
      config = lib.mkIf (osConfig.features.terminal.bash.enable) {
        programs.bash = {
          enable = true;
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
      ...
    }:
    let
      nixosConfigPath = toString osConfig.primaryUser.nixosConfigPath;
      dotfilesPath = toString osConfig.primaryUser.dotfilesPath;
    in
    {
      config = lib.mkIf (osConfig.features.terminal.fish.enable) {
        # https://nixos.wiki/wiki/Fish
        programs.fish = {
          enable = true;
          generateCompletions = true;

          shellAliases = {
            # Colorize grep output (good for log files)
            grep = "grep --color=auto";
            egrep = "egrep --color=auto";
            fgrep = "fgrep --color=auto";

            # confirm before overwriting something
            cp = "cp -i";
            mv = "mv -i";
            rm = "rm -i";

            # Replace ls and tree with eza
            ls = "eza";
            tree = "eza -T";
            cat = "bat";
          };

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
            if [ "$TERM" = "linux" ]
                then
                printf %b '\e[40m' '\e[8]' # set default background to color 0 'dracula-bg'
                printf %b '\e[37m' '\e[8]' # set default foreground to color 7 'dracula-fg'
                printf %b '\e]P0282a36' # redefine 'black'          as 'dracula-bg'
                printf %b '\e]P86272a4' # redefine 'bright-black'   as 'dracula-comment'
                printf %b '\e]P1ff5555' # redefine 'red'            as 'dracula-red'
                printf %b '\e]P9ff7777' # redefine 'bright-red'     as '#ff7777'
                printf %b '\e]P250fa7b' # redefine 'green'          as 'dracula-green'
                printf %b '\e]PA70fa9b' # redefine 'bright-green'   as '#70fa9b'
                printf %b '\e]P3f1fa8c' # redefine 'brown'          as 'dracula-yellow'
                printf %b '\e]PBffb86c' # redefine 'bright-brown'   as 'dracula-orange'
                printf %b '\e]P4bd93f9' # redefine 'blue'           as 'dracula-purple'
                printf %b '\e]PCcfa9ff' # redefine 'bright-blue'    as '#cfa9ff'
                printf %b '\e]P5ff79c6' # redefine 'magenta'        as 'dracula-pink'
                printf %b '\e]PDff88e8' # redefine 'bright-magenta' as '#ff88e8'
                printf %b '\e]P68be9fd' # redefine 'cyan'           as 'dracula-cyan'
                printf %b '\e]PE97e2ff' # redefine 'bright-cyan'    as '#97e2ff'
                printf %b '\e]P7f8f8f2' # redefine 'white'          as 'dracula-fg'
                printf %b '\e]PFffffff' # redefine 'bright-white'   as '#ffffff'
                clear
            end

            # Auto-start TMUX safely for interactive sessions
            if status is-interactive
            and not set -q TMUX
                tmux new-session
            end

            # Devenv Auto Activation
            deven hook fish | source
          '';
        };
        xdg.configFile."fish/themes/Dracula_Official.theme".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/fish/.config/fish/themes/Dracula_Official.theme";

        home.sessionVariables = {
          # Dracula theme for Docker BuildKit - https://draculatheme.com/docker
          BUILDKIT_COLORS = "run=189,147,249:cancel=241,250,140:error=255,85,85:warning=241,250,140";
          # Dracula theme for GNU grep - https://draculatheme.com/grep
          GREP_COLORS = "mt=1;38;2;255;85;85:fn=38;2;255;121;198:ln=38;2;80;250;123:bn=38;2;80;250;123:se=38;2;139;233;253";
        };

        home.packages = with pkgs; [
          krabby
          eza
          bat
        ];

        # https://wiki.nixos.org/wiki/Starship
        programs.starship = {
          enable = true;
          enableFishIntegration = true;
        };
        xdg.configFile."starship.toml".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/starship/.config/starship.toml";

        # https://wiki.nixos.org/wiki/Tmux
        programs.tmux = {
          enable = true;
          shortcut = "a"; # Changes prefix from C-b to C-a
          secureSocket = true;
          shell = "/etc/profiles/per-user/${osConfig.primaryUser.username}/bin/fish";
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

                set -g @dracula-colors "
                  white=\"#f8f8f2\"
                  gray=\"#44475a\"
                  dark_gray=\"#282a36\"
                  light_purple=\"#bd93f9\"
                  dark_purple=\"#6272a4\"
                  cyan=\"#8be9fd\"
                  green=\"#50fa7b\"
                  orange=\"#ffb86c\"
                  red=\"#ff5555\"
                  pink=\"#ff79c6\"
                  yellow=\"#f1fa8c\"
                "
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

  flake.homeModules.terminal-emulator = {
    imports = [
      self.homeModules.foot
      self.homeModules.ghostty
    ];
  };

  flake.homeModules.foot =
    {
      config,
      osConfig,
      lib,
      ...
    }:
    let
      dotfilesPath = toString osConfig.primaryUser.dotfilesPath;
    in
    {
      config = lib.mkIf (osConfig.features.terminal.emulator == "foot") {
        programs.foot = {
          enable = true;
          server.enable = true;
        };
        xdg.configFile."foot".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/foot/.config/foot";
      };
    };

  flake.homeModules.ghostty =
    {
      config,
      osConfig,
      lib,
      pkgs,
      ...
    }:
    let
      dotfilesPath = toString osConfig.primaryUser.dotfilesPath;
    in
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
              if osConfig.features.terminal.fish.enable then
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

            theme = "Dracula";
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
      };
    };
}
