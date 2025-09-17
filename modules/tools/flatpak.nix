{
  config,
  lib,
  pkgs,
  ...
}: {
  options.flatpak.enable = lib.mkEnableOption "Enable flatpak";

  config = lib.mkIf config.flatpak.enable {
    services.flatpak.enable = true;

    xdg.portal.enable = true;
    xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
    xdg.portal.configPackages = with pkgs; [xfce.xfce4-session];
  };
}
