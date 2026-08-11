inputs: final: prev: {
  dracula-gtk-theme = final.callPackage ./dracula-gtk-theme.nix { };

  vscode-extensions = prev.vscode-extensions // {
    datakurre = (prev.vscode-extensions.datakurre or { }) // {
      devenv = final.callPackage ./vscode-extensions/datakurre-devenv.nix { };
    };

    dracula-theme-pro = (prev.vscode-extensions.dracula-theme-pro or { }) // {
      theme-dracula-pro = final.callPackage ./vscode-extensions/theme-dracula-pro.nix {
        src = "${inputs.dracula-pro-vscode}/dracula-pro.vsix";
      };
    };
  };
}
