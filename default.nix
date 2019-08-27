{ nixpkgs ? { outPath = <nixpkgs>; rev = "latest"; } }:

with import nixpkgs {};

let
  inherit (lib.trivial) version versionSuffix;
in

rec {
  channels = {
    holoport = releaseTools.channel {
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

  virtualbox = (import <nixpkgs/nixos> {
    configuration.imports = [
      ./modules/virtualbox.nix
    ];
  }).config.system.build.virtualBoxOVA;
}
