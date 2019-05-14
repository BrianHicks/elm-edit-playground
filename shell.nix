with import (builtins.fetchTarball rec {
  # grab a hash from here: https://nixos.org/channels/
  name = "nixpkgs-darwin-19.03pre172607.4ed066fd40f";
  url = "https://github.com/nixos/nixpkgs/archive/4ed066fd40f7356cc2a8a2172d2225d16bb3e409.tar.gz";
  # Hash obtained using `nix-prefetch-url --unpack <url>`
  sha256 = "1naz3980b3h0b4i13by41jbsahvilbr7rvr4yg79y85ssw9890r2";
}) {};

let
  elmTools = import (pkgs.fetchFromGitHub {
    owner = "turboMaCk";
    repo = "nix-elm-tools";
    rev = "49b79886a43f816f53f3325dba05c40f28b5233d";
    sha256 = "03j352q3s8d4x79570vgiwc4sjlyj5vi0nnvi15z4x0haga3410r";
  }) { inherit pkgs; };

  brianhicksNUR = import (pkgs.fetchFromGitHub {
    owner = "BrianHicks";
    repo = "nur-packages";
    rev = "a1c451d41a5b5784b01de1f34bad01d3929cf00a";
    sha256 = "1kp25bh70ny09bha67qzw4lk1l2dp17j612xiym6zppi8462650l";
  }) { inherit pkgs; };
in
  stdenv.mkDerivation {
    name = "elm-edit";
    buildInputs = [
      brianhicksNUR.devd
      elmPackages.elm
      elmPackages.elm-format
      elmTools.elm-test
      git
      gnumake
    ];
  }
