{ vscode-utils, src }:

vscode-utils.buildVscodeExtension {
  pname = "theme-dracula-pro";
  version = "2.2.2";

  vscodeExtName = "theme-dracula-pro";
  vscodeExtPublisher = "dracula-theme-pro";
  vscodeExtUniqueId = "dracula-theme-pro.theme-dracula-pro";

  inherit src;

  extensionPackageSystemPath = "extension";

  meta = {
    description = "Dracula Pro for VSCode";
    homepage = "https://draculatheme.com/pro";
  };
}
