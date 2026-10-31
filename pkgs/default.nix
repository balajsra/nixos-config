inputs: final: prev: {
  dracula-gtk-theme = final.callPackage ./dracula-gtk-theme.nix {
    src = inputs.dracula-gtk-theme;
  };

  fallout-grub-theme = final.callPackage ./fallout-grub-theme.nix {
    src = inputs.fallout-grub-theme;
  };

  fallout-plymouth-theme = final.callPackage ./fallout-plymouth-theme.nix {
    src = inputs.fallout-plymouth-theme;
  };

  vimPlugins = prev.vimPlugins // {
    dracula-pro = final.callPackage ./vimPlugins/dracula-pro.nix {
      src = inputs.dracula-pro-vim-theme;
    };
  };

  vscode-extensions = prev.vscode-extensions // {
    datakurre = (prev.vscode-extensions.datakurre or { }) // {
      devenv = final.callPackage ./vscode-extensions/datakurre-devenv.nix { };
    };

    dracula-theme-pro = (prev.vscode-extensions.dracula-theme-pro or { }) // {
      theme-dracula-pro = final.callPackage ./vscode-extensions/theme-dracula-pro.nix {
        src = "${inputs.dracula-pro-vscode-theme}/dracula-pro.vsix";
      };
    };
  };
}
