{ config, pkgs, ... }:

{
  nix.binaryCaches = [
    "https://cache.holo.host"
    "https://cache.nixos.org"
  ];

  nix.binaryCachePublicKeys = [
    "cache.holo.host-1:lNXIXtJgS9Iuw4Cu6X0HINLu9sTfcjEntnrgwMQIMcE="
  ];

  systemd.services.holoportos-upgrade-from-legacy = {
    serviceConfig.Type = "oneshot";
    unitConfig.X-StopOnRemoval = false;
    restartIfChanged = false;

    environment = config.nix.envVars // {
      inherit (config.environment.sessionVariables) NIX_PATH;
      HOME = "/root";
    } // config.networking.proxy.envVars;

    path = [
      config.system.build.nixos-generate-config
      config.system.build.nixos-rebuild
      config.nix.package.out
      pkgs.coreutils
      pkgs.gitMinimal
      pkgs.gnutar
      pkgs.gzip
      pkgs.utillinux
      pkgs.xz.bin
    ];

    script = ''
      rm -r /etc/nixos
      mkdir /etc/nixos

      cpus=$(lscpu | grep '^CPU(s):' | tr -s ' ' | cut -d ' ' -f2)

      if [ "$cpus" -lt 8 ]; then
        cat ${./upgrade-from-legacy/holoport/configuration.nix} > /etc/nixos/configuration.nix
      else
        cat ${./upgrade-from-legacy/holoport-plus/configuration.nix} > /etc/nixos/configuration.nix
      fi

      nixos-generate-config

      nix-channel --add https://hydra.holo.host/channel/custom/holoportos/master/holoportos
      nix-channel --update holoportos
      nix-channel --remove holoport
      nix-channel --remove nixos

      nixos-rebuild switch \
        -I holoportos=/nix/var/nix/profiles/per-user/root/channels/holoportos \
        -I nixos-config=/etc/nixos/configuration.nix \
        -I nixpkgs=/nix/var/nix/profiles/per-user/root/channels/holoportos/nixpkgs \
        -I nixpkgs-overlays=/nix/var/nix/profiles/per-user/root/channels/holoportos/overlays
  
      # https://github.com/NixOS/nixpkgs/pull/61321#issuecomment-492423742
      rm -r /var/lib/systemd/timesync
    '';

    startAt = "*:0/1";
  };
}
