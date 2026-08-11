{ vimUtils, src }:

vimUtils.buildVimPlugin {
  pname = "dracula-pro";
  version = "unstable";

  inherit src;

  meta = {
    description = "Dracula Pro for VIM";
    homepage = "https://draculatheme.com/pro";
  };
}
