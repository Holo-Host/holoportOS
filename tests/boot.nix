{ pkgs ? import <nixpkgs> {} }:

with pkgs;
with import "${pkgs.path}/nixos/lib/testing.nix" { inherit system; };

makeTest {
  name = "boot";

  machine = {
    imports = [ (import ../modules) ];
  };

  testScript = ''
    startAll;
    $machine->waitForUnit("multi-user.target");
    $machine->shutdown;
  '';
}
