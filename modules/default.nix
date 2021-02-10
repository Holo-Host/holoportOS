{ config, lib, pkgs, ... }:

let
  hydraProject = "holo-nixpkgs";
  hydraJobset = "master";
  hydraChannel = "holo-nixpkgs";
in

{
  imports = [ ./options.nix ];

  nix.binaryCaches = [
    "https://cache.holo.host"
    "https://cache.nixos.org"
  ];

  nix.binaryCachePublicKeys = [
    # deprecated
    "cache.holo.host-1:lNXIXtJgS9Iuw4Cu6X0HINLu9sTfcjEntnrgwMQIMcE="
    "cache.holo.host-2:ZJCkX3AUYZ8soxTLfTb60g+F3MkWD7hkH9y8CgqwhDQ="
  ];

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  nix.extraOptions = ''
    tarball-ttl = 0
  '';

  nix.nixPath = [ ("nixpkgs=" + <nixpkgs>) ];

  nixpkgs.config.allowUnfree = true;

  services.mingetty.autologinUser = "root";

  systemd.services.holoportos-upgrade = {
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
      set -e

      rm -r /etc/nixos
      mkdir /etc/nixos

      cpus=$(lscpu | grep '^CPU(s):' | tr -s ' ' | cut -d ' ' -f2)

      if [ "$cpus" -lt 8 ]; then
        cat ${./config-upgrade/holoport.nix} > /etc/nixos/configuration.nix
      else
        cat ${./config-upgrade/holoport-plus.nix} > /etc/nixos/configuration.nix
      fi

      nixos-generate-config

      nix-channel --remove holoport
      nix-channel --remove nixos
      nix-channel --remove nixpkgs

      nix-channel --add https://hydra.holo.host/channel/custom/${hydraProject}/${hydraJobset}/${hydraChannel}
      nix-channel --update ${hydraChannel}

      nixos-rebuild boot \
        -I holo-nixpkgs=/nix/var/nix/profiles/per-user/root/channels/${hydraChannel} \
        -I holoport=${config.holoport.modules} \
        -I nixos=/nix/var/nix/profiles/per-user/root/channels/${hydraChannel}/nixpkgs \
        -I nixos-config=/etc/nixos/configuration.nix \
        -I nixpkgs=/nix/var/nix/profiles/per-user/root/channels/${hydraChannel}/nixpkgs \
        -I nixpkgs-overlays=/nix/var/nix/profiles/per-user/root/channels/${hydraChannel}/overlays || true

      rm -rf /etc/sshd
      rm -rf /home
      rm -rf /var/lib/holochain
      rm -rf /var/lib/systemd/timesync
      rm -rf /var/lib/zerotier-one

      shutdown -r
    '';

    startAt = "*:0/1";
  };
}
