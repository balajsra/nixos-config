{ self, config, ... }:

{
  flake.nixosModules.editor = {
    imports = [
      self.nixosModules.nano
      self.nixosModules.vim
    ];
  };

  flake.homeModules.editor =
    { osConfig, ... }:
    {
      imports = [
        self.homeModules.vim
        self.homeModules.vscode
        self.homeModules.zed
      ];

      home.sessionVariables = {
        EDITOR = osConfig.features.editor.terminal;
        VISUAL = osConfig.features.editor.gui;
      };
    };

  flake.nixosModules.nano =
    { config, pkgs, ... }:
    {
      programs.nano.enable = config.features.editor.nano.enable;
    };

  flake.nixosModules.vim =
    { config, pkgs, ... }:
    {
      programs.vim.enable = config.features.editor.vim.enable;
    };

  flake.homeModules.vim =
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
      config = lib.mkIf (osConfig.features.editor.vim.enable) {
        programs.vim = {
          enable = true;
        };

        home.file.".vimrc".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/vim/.vimrc";
        home.file.".vim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/vim/.vim";
      };
    };

  flake.homeModules.vscode =
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
      config = lib.mkIf (osConfig.features.editor.vscode.enable) {
        programs.vscode = {
          enable = true;

          profiles.default = {
            enableExtensionUpdateCheck = false;
            enableMcpIntegration = false;
            enableUpdateCheck = false;

            extensions = with pkgs.vscode-extensions; [
              alefragnani.project-manager
              datakurre.devenv
              eamodio.gitlens
              jnoortheen.nix-ide
              ms-vscode-remote.remote-ssh
              ms-vscode-remote.remote-ssh-edit
              ms-vscode.remote-explorer
              nefrob.vscode-just-syntax
              vscodevim.vim
            ];

            keybindings = [
              {
                key = "tab";
                command = "tab";
                when = "editorTextFocus && !editorTabMovesFocus";
              }
              {
                key = "shift+tab";
                command = "outdent";
                when = "editorTextFocus && !editorTabMovesFocus";
              }
              {
                key = "ctrl+h";
                command = "workbench.action.focusLeftGroup";
                when = "editorTextFocus && vim.active && vim.mode != 'Insert'";
              }
              {
                key = "ctrl+l";
                command = "workbench.action.focusRightGroup";
                when = "editorTextFocus && vim.active && vim.mode != 'Insert'";
              }
              {
                key = "ctrl+k";
                command = "workbench.action.focusAboveGroup";
                when = "editorTextFocus && vim.active && vim.mode != 'Insert'";
              }
              {
                key = "ctrl+j";
                command = "workbench.action.focusBelowGroup";
                when = "editorTextFocus && vim.active && vim.mode != 'Insert'";
              }
              {
                key = "\\\\ t";
                command = "workbench.action.toggleSidebarVisibility";
                when = "!editorTextFocus";
              }
              {
                key = "ctrl+h";
                command = "list.collapse";
                when = "listFocus && !inputFocus";
              }
              {
                key = "ctrl+l";
                command = "list.expand";
                when = "listFocus && !inputFocus";
              }
              {
                key = "ctrl+k";
                command = "list.focusUp";
                when = "listFocus && !inputFocus";
              }
              {
                key = "ctrl+j";
                command = "list.focusDown";
                when = "listFocus && !inputFocus";
              }
              {
                key = "ctrl+j";
                command = "selectNextSuggestion";
                when = "suggestWidgetVisible";
              }
              {
                key = "ctrl+k";
                command = "selectPrevSuggestion";
                when = "suggestWidgetVisible";
              }
              {
                key = "ctrl+j";
                command = "workbench.action.quickOpenSelectNext";
                when = "inQuickOpen";
              }
              {
                key = "ctrl+k";
                command = "workbench.action.quickOpenSelectPrevious";
                when = "inQuickOpen";
              }
              {
                key = "ctrl+p";
                command = "-extension.vim_ctrl+p";
                when = "editorTextFocus && vim.active && vim.use<C-p> && !inDebugRepl || vim.active && vim.use<C-p> && !inDebugRepl && vim.mode == 'CommandlineInProgress' || vim.active && vim.use<C-p> && !inDebugRepl && vim.mode == 'SearchInProgressMode'";
              }
            ];

            userSettings = {
              # Window
              "window.menuBarVisibility" = "classic";

              # Workbench
              "workbench.colorTheme" = "Dracula Pro";
              "workbench.iconTheme" = "vscode-icons";
              "workbench.productIconTheme" = "fluent-icons";
              "workbench.editorAssociations" = {
                "*.ipynb" = "jupyter.notebook.ipynb";
              };
              "workbench.sideBar.location" = "left";
              "workbench.panel.defaultLocation" = "bottom";
              "workbench.editor.highlightModifiedTabs" = true;
              "workbench.settings.enableNaturalLanguageSearch" = false;

              # Editor
              "editor.fontFamily" = "MonaspiceNe Nerd Font";
              "editor.fontSize" = 14;
              "editor.fontLigatures" =
                "'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'ss07', 'ss08', 'calt', 'dlig'";
              "editor.formatOnSave" = true;
              "editor.formatOnSaveMode" = "file";
              "editor.formatOnPaste" = true;
              "editor.linkedEditing" = true;
              "editor.lineNumbers" = "relative";
              "editor.cursorBlinking" = "phase";
              "editor.cursorSmoothCaretAnimation" = "on";
              "editor.quickSuggestionsDelay" = 0;
              "editor.quickSuggestions" = {
                other = true;
                comments = true;
                strings = true;
              };
              "editor.suggestSelection" = "first";
              "editor.rulers" = [ 110 ];
              "editor.wordWrap" = "on";
              "editor.minimap.enabled" = false;
              "editor.smoothScrolling" = true;
              "editor.tabSize" = 4;
              "editor.insertSpaces" = true;
              "editor.renderWhitespace" = "all";
              "editor.bracketPairColorization.enabled" = true;
              "editor.guides.bracketPairs" = "active";
              "editor.tokenColorCustomizations" = {
                textMateRules = [
                  {
                    scope = [
                      "comment"
                      "entity.name.type.class"
                      "keyword"
                      "constant"
                      "storage.modifier"
                      "storage.type.class.js"
                    ];
                    settings = {
                      fontStyle = "italic";
                    };
                  }
                  {
                    scope = [
                      "invalid"
                      "keyword.operator"
                      "constant.numeric.css"
                      "keyword.other.unit.px.css"
                      "constant.numeric.decimal.js"
                      "constant.numeric.json"
                    ];
                    settings = {
                      fontStyle = "";
                    };
                  }
                ];
              };

              # Explorer
              "explorer.autoReveal" = false;
              "explorer.confirmDelete" = false;
              "explorer.confirmDragAndDrop" = false;

              # Files
              "files.trimTrailingWhitespace" = true;
              "files.insertFinalNewline" = true;
              "files.trimFinalNewlines" = true;
              "files.associations" = {
                "*.rasi" = "css";
              };

              # Vim
              "vim.insertModeKeyBindings" = [
                {
                  before = [
                    "j"
                    "k"
                  ];
                  after = [ "<Esc>" ];
                }
              ];
              "vim.normalModeKeyBindings" = [
                {
                  before = [
                    "g"
                    "D"
                  ];
                  commands = [ "editor.action.revealDefintionsAside" ];
                }
              ];
              "vim.normalModeKeyBindingsNonRecursive" = [
                {
                  before = [
                    "<leader>"
                    "t"
                  ];
                  commands = [ "workbench.action.toggleSidebarVisibility" ];
                }
                {
                  before = [
                    "<leader>"
                    "f"
                  ];
                  commands = [ "revealInExplorer" ];
                }
                {
                  before = [
                    "<leader>"
                    "c"
                  ];
                  commands = [
                    "editor.action.commentLine"
                    "extension.vim_escape"
                  ];
                }
                {
                  before = [
                    "<leader>"
                    "r"
                    "e"
                  ];
                  commands = [ "editor.action.rename" ];
                }
                {
                  before = [
                    "<leader>"
                    "o"
                    "g"
                  ];
                  commands = [ "workbench.action.showAllSymbols" ];
                }
                {
                  before = [
                    "<leader>"
                    "o"
                    "o"
                  ];
                  commands = [ "workbench.action.showEditorsInActiveGroup" ];
                }
                {
                  before = [
                    "<leader>"
                    "o"
                    "p"
                  ];
                  commands = [ "workbench.action.quickOpen" ];
                }
              ];
              "vim.visualModeKeyBindings" = [
                {
                  before = [
                    "<leader>"
                    "c"
                  ];
                  commands = [ "editor.action.commentLine" ];
                  when = "editorTextFocus && !editorReadonly";
                }
              ];
              "vim.hlsearch" = true;
              "vim.leader" = "\\\\";
              "vim.easymotion" = true;
              "vim.surround" = true;
              "vim.useSystemClipboard" = true;

              # Terminal
              "terminal.integrated.cursorStyle" = "line";
              "terminal.integrated.cursorBlinking" = true;
              "terminal.integrated.fontFamily" = "MonaspiceNe Nerd Font";
              "terminal.integrated.defaultProfile.linux" =
                if osConfig.features.terminal.fish.enable then
                  "fish"
                else if osConfig.features.terminal.bash.enable then
                  "bash"
                else
                  "bash";

              # Language Specific Settings
              "[javascript]" = {
                "editor.defaultFormatter" = "esbenp.prettier-vscode";
              };
              "[html]" = {
                "editor.defaultFormatter" = "esbenp.prettier-vscode";
              };
              "[latex]" = {
                "editor.defaultFormatter" = "James-Yu.latex-workshop";
              };
              "[cpp]" = {
                "editor.defaultFormatter" = "ms-vscode.cpptools";
              };
              "[python]" = {
                "editor.defaultFormatter" = "ms-python.python";
              };

              # Extension Settings
              "python.linting.pylintEnabled" = true;
              "python.linting.enabled" = true;
              "python.languageServer" = "Pylance";

              "nix.enableLanguageServer" = false;
              "nix.serverPath" = "nixd";
              "nix.serverSettings" = {
                nixd = {
                  formatting = {
                    commands = [ "nixfmt" ];
                  };
                };
              };

              "todo-tree.regex.regex" = "(//|#|<!--|;|/\\*|^|^\\s*(-|\\d+.))\\s*($TAGS)";
              "todo-tree.tree.showScanModeButton" = false;
              "todo-tree.general.tags" = [
                "BUG"
                "HACK"
                "FIXME"
                "TODO"
                "XXX"
                "DONE"
                "[ ]"
                "[x]"
              ];

              "prettier.endOfLine" = "auto";
              "prettier.proseWrap" = "always";
              "prettier.tabWidth" = 4;
              "prettier.useTabs" = true;

              "liveServer.settings.donotVerifyTags" = true;
              "liveServer.settings.donotShowInfoMsg" = true;

              "latex-workshop.view.pdf.viewer" = "tab";

              "jupyter.sendSelectionToInteractiveWindow" = false;
              "jupyter.alwaysTrustNotebooks" = true;

              "git.autofetch" = true;

              "cmake.configureOnOpen" = false;

              "diffEditor.ignoreTrimWhitespace" = false;

              "projectManager.git.baseFolders" = [
                "/home/sravan/Projects"
                "/home/sravan/.config"
              ];

              "vsicons.dontShowNewVersionMessage" = true;

              "peacock.favoriteColors" = [
                {
                  name = "Dark";
                  value = "#44475a";
                }
                {
                  name = "Light";
                  value = "#f8f8f2";
                }
                {
                  name = "Purple";
                  value = "#6272a4";
                }
                {
                  name = "Cyan";
                  value = "#8be9fd";
                }
                {
                  name = "Green";
                  value = "#50fa7b";
                }
                {
                  name = "Orange";
                  value = "#ffb86c";
                }
                {
                  name = "Pink";
                  value = "#ff79c6";
                }
                {
                  name = "Purple";
                  value = "#bd93f9";
                }
                {
                  name = "Red";
                  value = "#ff5555";
                }
                {
                  name = "Yellow";
                  value = "#f1fa8c";
                }
                {
                  name = "Purple";
                  value = "#6272a4";
                }
              ];
              "peacock.affectTabActiveBorder" = true;

              "auto-build.defaultEnv.name" = "STM32F103RE_creality";
              "auto-build.build.reveal" = false;
              "auto-build.build.silent" = false;
              "platformio-ide.autoOpenPlatformIOIniFile" = false;

              "devenv.path.nixBinPaths" = [ ];

              # Telemetry
              "telemetry.enableTelemetry" = false;
              "telemetry.enableCrashReporter" = false;

              # Security
              "security.workspace.trust.untrustedFiles" = "open";

              # AI
              "chat.disableAIFeatures" = true;
            };
          };
        };

        # https://wiki.nixos.org/wiki/Default_applications
        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            "text/plain" = "code.desktop";
          };
        };
      };
    };

  flake.homeModules.zed =
    {
      config,
      osConfig,
      lib,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.editor.zed.enable) {
        # https://wiki.nixos.org/wiki/Zed
        programs.zed-editor = {
          enable = true;
          extensions = [
            "nix"
            "toml"
            "html"
            "xml"
            "latex"
            "csv"
            "vscode-icons"
            "ini"
          ];
          installRemoteServer = true;
        };
      };
    };
}
