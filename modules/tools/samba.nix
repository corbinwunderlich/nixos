{
  config,
  lib,
  pkgs,
  ...
}: {
  options.samba.enable =
    lib.mkEnableOption "Enables CIFS fileshare for Siarnaq";

  config = lib.mkIf config.samba.enable {
    environment.systemPackages = [pkgs.cifs-utils];

    system.userActivationScripts.linknfsmount.text = let
      link = {
        mount,
        target,
      }: ''
        if [[ ! -h "${target}" ]]; then
          ln -s "${mount}" "${target}"
        fi
      '';
    in
      link {
        mount = "/mnt/siarnaq-home/Projects";
        target = "$HOME/Projects";
      };

    boot.supportedFilesystems = ["nfs"];

    fileSystems."/mnt/siarnaq-home" = {
      device = "siarnaq.ridgewood:/volume1/homes/corbin";
      fsType = "nfs";
      options = ["nfsvers=4.1" "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600"];
    };

    services.nfs = {
      idmapd.settings = {
        General = {
          Domain = "ridgewood";
        };
      };
    };

    boot.extraModprobeConfig = ''
      options nfs nfs4_disable_idmapping=0
      options nfsd nfs4_disable_idmapping=0
    '';
  };
}
