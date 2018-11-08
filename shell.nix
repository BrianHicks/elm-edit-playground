with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "elm-edit";
  buildInputs = [
    git
    elmPackages.elm
    elmPackages.elm-format
    nodePackages.npm
  ];
}
