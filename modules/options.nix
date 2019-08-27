{ lib, ... }: with lib;

{
  options.holoport.modules = mkOption {
    default = cleanSource ../.;
    type = types.path;
  };
}
