final: prev: {
  dracula-gtk-theme = final.callPackage ./dracula-gtk-theme.nix { };

  vscode-extensions = prev.vscode-extensions // {
    datakurre = (prev.vscode-extensions.datakurre or { }) // {
      devenv = final.callPackage ./vscode-extensions/datakurre-devenv.nix { };
    };
  };
}
