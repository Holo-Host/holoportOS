{
  imports = [ <nixpkgs/nixos/modules/virtualisation/qemu-vm.nix> ./. ];

  virtualisation.diskSize = 4096;
}
