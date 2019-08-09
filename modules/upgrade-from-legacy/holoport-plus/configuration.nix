{
  imports = [
    <holoportos/profiles/targets/holoport-plus>
    ./hardware-configuration.nix
  ];
  
  system.holoportos.network = "live";
}
