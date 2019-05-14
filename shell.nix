with import (builtins.fetchTarball rec {
  # grab a hash from here: https://nixos.org/channels/
  name = "nixpkgs-darwin-18.09pre153446.836d1d7c1cc";
  url = "https://github.com/nixos/nixpkgs/archive/836d1d7c1cce26eda233dc925c8093e5a5d86ad3.tar.gz";
  # Hash obtained using `nix-prefetch-url --unpack <url>`
  sha256 = "1vibh9k2swmsq07v2fsqxhc0lxn0gnk48jsykxbb42bvlsxisxdi";
}) {};

let
  elmTools = import (pkgs.fetchFromGitHub {
    owner = "turboMaCk";
    repo = "nix-elm-tools";
    rev = "49b79886a43f816f53f3325dba05c40f28b5233d";
    sha256 = "03j352q3s8d4x79570vgiwc4sjlyj5vi0nnvi15z4x0haga3410r";
  }) { inherit pkgs; };
in
  stdenv.mkDerivation {
    name = "elm-edit";
    buildInputs = [
      elmPackages.elm
      elmPackages.elm-format
      elmTools.elm-test
      git
      gnumake
    ];
  }
