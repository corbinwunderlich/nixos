{
  config,
  lib,
  pkgs,
  ...
}: {
  options.flatpak.enable = lib.mkEnableOption "Enable flatpak";

  config = lib.mkIf config.flatpak.enable {
    services.flatpak.enable = true;
    systemd.services.flatpak-repo = {
      wantedBy = ["multi-user.target"];
      path = [pkgs.flatpak];
      script = ''
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      '';
    };
  };
}
