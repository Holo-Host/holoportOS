let
  pkgs = import ./pkgs.nix {};
in

{ nixpkgs ? { outPath = pkgs.path; rev = "latest"; } }:

let
  inherit (pkgs.lib.trivial) version versionSuffix;
in

rec {
  channels = {
    holoport = pkgs.releaseTools.channel {
      name = "holoport";
      src = <holoport>;
      constituents = [ channels.nixpkgs tests.boot ];
    };

    nixpkgs = import <nixpkgs/nixos/lib/make-channel.nix> {
      inherit nixpkgs pkgs version versionSuffix;
    };
  };

  tests = {
    boot = import ./tests/boot.nix { inherit pkgs; };
  };
}
