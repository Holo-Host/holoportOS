{
  imports = [
    <holoportos/profiles/targets/holoport>
    ./hardware-configuration.nix
  ];
  
  system.holoportos.network = "live";
}
