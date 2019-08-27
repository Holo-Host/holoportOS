{ pkgs ? import ./pkgs.nix {} }:

with pkgs;

let
  root = toString ./.;
in

stdenvNoCC.mkDerivation {
  name = "holopkgs";

  shellHook = ''
    holoportos-build-vm() {
      nixos-rebuild build-vm -I nixos-config=${root}/modules
    }
  '';

  buildInputs = [ ((nixos {}).nixos-rebuild) ];

  NIX_PATH = builtins.concatStringsSep ":" [
    "holoport=${root}"
    "nixpkgs=${pkgs.path}"
  ];

  QEMU_OPTS = "-m 8192";
}
