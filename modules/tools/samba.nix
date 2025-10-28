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

    fileSystems."/mnt/siarnaq-home" = {
      device = "//siarnaq.ridgewood/home";
      fsType = "cifs";
      options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=3,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in [
        "${automount_opts},credentials=/var/lib/samba-credentials/samba-credentials,uid=1000,gid=100,mfsymlinks"
      ];
    };

    system.userActivationScripts.linksmbmount.text = let
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
  };
}
