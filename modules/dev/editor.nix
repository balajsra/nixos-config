{ self, ... }:

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
    { config, ... }:
    {
      programs.nano.enable = config.features.editor.nano.enable;
    };

  flake.nixosModules.vim =
    { config, ... }:
    {
      programs.vim.enable = config.features.editor.vim.enable;
    };

  flake.homeModules.vim =
    {
      osConfig,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf (osConfig.features.editor.vim.enable) {
        programs.vim = {
          enable = true;

          plugins = with pkgs.vimPlugins; [
            dracula-pro
          ];

          settings = {
            number = true;
            relativenumber = true;
            tabstop = 4;
            shiftwidth = 4;
            expandtab = true;
          };

          extraConfig = ''
            " Don't try to be vi compatible
            set nocompatible

            " Pick a leader key
            let mapleader = "\\"

            " Security
            set modelines=0

            " Show file stats
            set ruler

            " Blink cursors on error instead of beeping
            set visualbell

            " Encoding
            set encoding=utf-8

            " Whitespace & Indentation
            set wrap
            set textwidth=110
            set formatoptions=tcqrn1
            set softtabstop=4
            set noshiftround
            set smarttab
            set autoindent

            " Cursor Motion
            set scrolloff=3
            set backspace=indent,eol,start
            set matchpairs+=<:>

            " Allow hidden buffers
            set hidden

            " Rendering
            set ttyfast

            " Status bar
            set laststatus=2

            " Last line
            set showmode
            set showcmd

            " Searching
            set hlsearch
            set incsearch
            set ignorecase
            set smartcase
            set showmatch
            nnoremap / /\v
            vnoremap / /\v
            map <leader><space> :let @/=""<cr>

            " Formatting
            map <leader>q gqip

            " Visualize tabs and newlines
            set listchars=tab:▸\ ,eol:¬
            map <leader>l :set list!<CR>

            " Exit Insert Mode Easily
            inoremap jk <esc>

            " UI Config
            set cursorline
            filetype indent on
            set wildmenu
            set lazyredraw

            " Load start packages explicitly before activating theme
            packloadall

            " Enable Dracula Pro Theme
            syntax enable
            let g:dracula_colorterm = 0
            colorscheme dracula-pro
          '';
        };
      };
    };

  flake.homeModules.vscode =
    {
      pkgs,
      osConfig,
      lib,
      ...
    }:
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
              bodil.file-browser
              datakurre.devenv
              dracula-theme-pro.theme-dracula-pro
              eamodio.gitlens
              elijah-potter.harper
              esbenp.prettier-vscode
              james-yu.latex-workshop
              jnoortheen.nix-ide
              johnpapa.vscode-peacock
              kahole.magit
              miguelsolorio.fluent-icons
              ms-vscode-remote.remote-ssh
              ms-vscode-remote.remote-ssh-edit
              ms-vscode.cmake-tools
              ms-vscode.cpptools
              ms-vscode.live-server
              ms-vscode.remote-explorer
              nefrob.vscode-just-syntax
              redhat.vscode-yaml
              rust-lang.rust-analyzer
              tamasfe.even-better-toml
              tomoki1207.pdf
              usernamehw.errorlens
              vscode-icons-team.vscode-icons
              vscodevim.vim
              vspacecode.vspacecode
              vspacecode.whichkey
              yzhang.markdown-all-in-one
            ];

            userSettings = {
              ##########
              # Window #
              ##########
              "window.density.layout" = "compact";
              "window.menuBarVisibility" = "classic";

              #############
              # Workbench #
              #############
              "workbench.activityBar.location" = "hidden";
              "workbench.colorTheme" = "Dracula Pro";
              "workbench.editor.highlightModifiedTabs" = true;
              "workbench.editor.showTabs" = "none";
              "workbench.editorAssociations" = {
                "git-rebase-todo" = "default";
              };
              "workbench.experimental.modernUI" = true;
              "workbench.iconTheme" = "vscode-icons";
              "workbench.panel.defaultLocation" = "bottom";
              "workbench.productIconTheme" = "fluent-icons";
              "workbench.secondarySideBar.defaultVisibility" = "hidden";
              "workbench.settings.enableNaturalLanguageSearch" = false;
              "workbench.sideBar.location" = "left";
              "workbench.startupEditor" = "none";
              "workbench.welcomePage.walkthroughs.openOnInstall" = false;

              ##########
              # Editor #
              ##########
              "editor.bracketPairColorization.enabled" = true;
              "editor.cursorBlinking" = "smooth";
              "editor.cursorSmoothCaretAnimation" = "on";
              "editor.fontFamily" = "MonaspiceNe Nerd Font";
              "editor.fontLigatures" =
                "'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'ss07', 'ss08', 'calt', 'dlig'";
              "editor.fontSize" = 14;
              "editor.formatOnPaste" = true;
              "editor.formatOnSave" = true;
              "editor.formatOnSaveMode" = "file";
              "editor.guides.bracketPairs" = "active";
              "editor.insertSpaces" = true;
              "editor.lineNumbers" = "relative";
              "editor.linkedEditing" = true;
              "editor.minimap.enabled" = false;
              "editor.quickSuggestions" = {
                other = true;
                comments = true;
                strings = true;
              };
              "editor.quickSuggestionsDelay" = 0;
              "editor.renderWhitespace" = "all";
              "editor.rulers" = [ 110 ];
              "editor.smoothScrolling" = true;
              "editor.suggestSelection" = "first";
              "editor.tabSize" = 4;
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
              "editor.wordWrap" = "on";

              ############
              # Explorer #
              ############
              "explorer.autoReveal" = false;
              "explorer.confirmDelete" = false;
              "explorer.confirmDragAndDrop" = false;

              #########
              # Files #
              #########
              "files.associations" = {
                "*.rasi" = "css";
              };
              "files.insertFinalNewline" = true;
              "files.trimFinalNewlines" = true;
              "files.trimTrailingWhitespace" = true;

              #######
              # Vim #
              #######
              "vim.easymotion" = true;
              "vim.handleKeys" = {
                "<C-b>" = false;
              };
              "vim.hlsearch" = true;
              "vim.insertModeKeyBindingsNonRecursive" = [
                {
                  before = [
                    "j"
                    "k"
                  ];
                  after = [ "<Esc>" ];
                }
              ];
              "vim.normalModeKeyBindingsNonRecursive" = [
                {
                  before = [ "<space>" ];
                  commands = [ "vspacecode.space" ];
                }
                {
                  before = [ "," ];
                  commands = [
                    "vspacecode.space"
                    {
                      command = "whichkey.triggerKey";
                      args = "m";
                    }
                  ];
                }
              ];
              "vim.surround" = true;
              "vim.useSystemClipboard" = true;
              "vim.visualModeKeyBindingsNonRecursive" = [
                {
                  before = [ "<space>" ];
                  commands = [ "vspacecode.space" ];
                }
                {
                  before = [ "," ];
                  commands = [
                    "vspacecode.space"
                    {
                      command = "whichkey.triggerKey";
                      args = "m";
                    }
                  ];
                }
                {
                  before = [ ">" ];
                  commands = [ "editor.action.indentLines" ];
                }
                {
                  before = [ "<" ];
                  commands = [ "editor.action.outdentLines" ];
                }
              ];

              ##############
              # VSpaceCode #
              ##############
              "vspacecode.bindingOverrides" = [
                # Use project manager extension for switching
                {
                  keys = [
                    "p"
                    "p"
                  ];
                  name = "+Switch project";
                  type = "command";
                  command = "projectManager.listProjects";
                }
                # Remove redundant keybind
                {
                  keys = [
                    "p"
                    "l"
                  ];
                  position = -1;
                }
                # Save project to project manager
                {
                  keys = [
                    "p"
                    "s"
                  ];
                  name = "+Save project";
                  type = "command";
                  command = "projectManager.saveProject";
                }
                # Edit projects in project manager
                {
                  keys = [
                    "p"
                    "e"
                  ];
                  name = "Edit projects";
                  type = "command";
                  command = "projectManager.editProjects";
                }
              ];

              ############
              # Terminal #
              ############
              "terminal.integrated.cursorBlinking" = true;
              "terminal.integrated.cursorStyle" = "line";
              "terminal.integrated.defaultProfile.linux" =
                if osConfig.features.terminal.tmux.enable then
                  "tmux"
                else if osConfig.features.terminal.fish.enable then
                  "fish"
                else if osConfig.features.terminal.bash.enable then
                  "bash"
                else
                  "bash";
              "terminal.integrated.fontFamily" = "MonaspiceNe Nerd Font";
              "terminal.integrated.sendKeybindingsToShell" = "all-commands";
              "terminal.integrated.shellIntegration.enabled" = false;
              "terminal.integrated.suggest.enabled" = false;
              "terminal.integrated.suggest.inlineSuggestion" = "off";

              ##############################
              # Language Specific Settings #
              ##############################
              "[cpp]" = {
                "editor.defaultFormatter" = "ms-vscode.cpptools";
              };
              "[html]" = {
                "editor.defaultFormatter" = "esbenp.prettier-vscode";
              };
              "[javascript]" = {
                "editor.defaultFormatter" = "esbenp.prettier-vscode";
              };
              "[latex]" = {
                "editor.defaultFormatter" = "James-Yu.latex-workshop";
              };
              "[markdown]" = {
                "editor.defaultFormatter" = "yzhang.markdown-all-in-one";
              };

              #######
              # Nix #
              #######
              "nix.enableLanguageServer" = true;
              "nix.serverPath" = "nixd";
              "nix.serverSettings" = {
                nixd = {
                  formatting = {
                    commands = [ "nixfmt" ];
                  };
                };
              };

              ############
              # Prettier #
              ############
              "prettier.endOfLine" = "auto";
              "prettier.proseWrap" = "always";
              "prettier.tabWidth" = 4;
              "prettier.useTabs" = true;

              ##################
              # Latex Workshop #
              ##################
              "latex-workshop.view.pdf.viewer" = "tab";

              #######
              # Git #
              #######
              "git.autofetch" = true;

              #########
              # CMake #
              #########
              "cmake.configureOnOpen" = false;

              ###############
              # Diff Editor #
              ###############
              "diffEditor.ignoreTrimWhitespace" = false;

              ###################
              # Project Manager #
              ###################
              "projectManager.cacheProjectsBetweenSessions" = true;
              "projectManager.checkInvalidPathsBeforeListing" = true;
              "projectManager.git.baseFolders" = [
                "$home/Projects"
                "$home/.config"
              ];
              "projectManager.ignoreProjectsWithinProjects" = true;
              "projectManager.removeCurrentProjectFromList" = false;
              "projectManager.showParentFolderInfoOnDuplicates" = true;
              "projectManager.showProjectNameInStatusBar" = true;
              "projectManager.sortList" = "Name";
              "projectManager.supportSymlinksOnBaseFolders" = true;

              ############
              # VS Icons #
              ############
              "vsicons.dontShowNewVersionMessage" = true;

              ###########
              # Peacock #
              ###########
              "peacock.affectTabActiveBorder" = true;
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

              ##########
              # Devenv #
              ##########
              "devenv.restart.automatic" = true;
              "devenv.status.showChangesCount" = true;
              "devenv.watchForChanges" = true;

              #############
              # Telemetry #
              #############
              "telemetry.telemetryLevel" = "off";

              ############
              # Security #
              ############
              "security.workspace.trust.untrustedFiles" = "open";

              ######
              # AI #
              ######
              "chat.disableAIFeatures" = true;
            };

            keybindings = [
              # Trigger vspacecode in empty editor group
              {
                key = "space";
                command = "vspacecode.space";
                when = "activeEditorGroupEmpty && focusedView == '' && !whichkeyActive && !inputFocus";
              }
              # Trigger vspacecode when sidebar is in focus
              {
                key = "space";
                command = "vspacecode.space";
                when = "sideBarFocus && !inputFocus && !whichkeyActive";
              }
              # Keybindings required for edamagit
              # https://github.com/kahole/edamagit#vim-support-vscodevim
              # Cannot be added to package.json because keybinding replacements
              {
                key = "tab";
                command = "extension.vim_tab";
                when = "editorTextFocus && vim.active && !inDebugRepl && vim.mode != 'Insert' && editorLangId != 'magit'";
              }
              {
                key = "tab";
                command = "-extension.vim_tab";
                when = "editorTextFocus && vim.active && !inDebugRepl && vim.mode != 'Insert'";
              }
              {
                key = "x";
                command = "magit.discard-at-point";
                when = "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
              }
              {
                key = "k";
                command = "-magit.discard-at-point";
              }
              {
                key = "-";
                command = "magit.reverse-at-point";
                when = "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
              }
              {
                key = "v";
                command = "-magit.reverse-at-point";
              }
              {
                key = "shift+-";
                command = "magit.reverting";
                when = "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
              }
              {
                key = "shift+v";
                command = "-magit.reverting";
              }
              {
                key = "shift+o";
                command = "magit.resetting";
                when = "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
              }
              {
                key = "shift+x";
                command = "-magit.resetting";
              }
              {
                key = "x";
                command = "-magit.reset-mixed";
              }
              {
                key = "ctrl+u x";
                command = "-magit.reset-hard";
              }
              # Extra ref menu support for edamagit with the key "y"
              # Cannot be added to package.json because keybinding replacements
              {
                key = "y";
                command = "-magit.show-refs";
              }
              {
                key = "y";
                command = "vspacecode.showMagitRefMenu";
                when = "editorTextFocus && editorLangId == 'magit' && vim.mode == 'Normal'";
              }
              # Extra refresh menu support for edamagit with the key "g"
              # Cannot be added to package.json because keybinding replacements
              {
                key = "g";
                command = "-magit.refresh";
                when = "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
              }
              {
                key = "g";
                command = "vspacecode.showMagitRefreshMenu";
                when = "editorTextFocus && editorLangId == 'magit' && vim.mode =~ /^(?!SearchInProgressMode|CommandlineInProgress).*$/";
              }
              # Easy navigation in quick open/QuickPick
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
              # Easy navigation in suggestion/intellisense
              # Cannot be added to package.json because of conflict with vim's default bindings
              {
                key = "ctrl+j";
                command = "selectNextSuggestion";
                when = "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus";
              }
              {
                key = "ctrl+k";
                command = "selectPrevSuggestion";
                when = "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus";
              }
              {
                key = "ctrl+l";
                command = "acceptSelectedSuggestion";
                when = "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus";
              }
              # Easy navigation in parameter hint (i.e. traverse the hints when there's multiple overload for one method)
              # Cannot be added to package.json because of conflict with vim's default bindings
              {
                key = "ctrl+j";
                command = "showNextParameterHint";
                when = "editorFocus && parameterHintsMultipleSignatures && parameterHintsVisible";
              }
              {
                key = "ctrl+k";
                command = "showPrevParameterHint";
                when = "editorFocus && parameterHintsMultipleSignatures && parameterHintsVisible";
              }
              # Easy navigation in code action
              {
                key = "ctrl+j";
                command = "selectNextCodeAction";
                when = "codeActionMenuVisible";
              }
              {
                key = "ctrl+k";
                command = "selectPrevCodeAction";
                when = "codeActionMenuVisible";
              }
              {
                key = "ctrl+l";
                command = "acceptSelectedCodeAction";
                when = "codeActionMenuVisible";
              }
              # Add ctrl+h/l to navigate in file browser
              {
                key = "ctrl+h";
                command = "file-browser.stepOut";
                when = "inFileBrowser";
              }
              {
                key = "ctrl+l";
                command = "file-browser.stepIn";
                when = "inFileBrowser";
              }
              # Toggle sidebar with ctrl+b
              {
                key = "ctrl+b";
                command = "workbench.action.toggleSidebarVisibility";
              }
            ];
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
