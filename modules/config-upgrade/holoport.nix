{
  imports = [
    <holopkgs/profiles/targets/holoport>
    ./hardware-configuration.nix
  ];
  
  system.holoportos.network = "live";
}
