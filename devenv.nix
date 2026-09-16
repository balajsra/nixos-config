{
  pkgs,
  ...
}:

{
  packages = with pkgs; [
    age
    git
    jq
    just
    just-lsp
    nixd
    nixfmt
    ssh-to-age
    yaml-language-server
    yq
  ];
}
