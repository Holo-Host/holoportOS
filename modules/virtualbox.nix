{
  imports = [ <nixpkgs/nixos/modules/virtualisation/virtualbox-image.nix> ./. ];

  virtualisation.virtualbox.guest.x11 = false;
}
