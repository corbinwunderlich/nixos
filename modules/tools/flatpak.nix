{
  config,
  lib,
  pkgs,
  ...
}: {
  options.flatpak.enable = lib.mkEnableOption "Enable flatpak";

  config = lib.mkIf config.flatpak.enable {
    services.flatpak = {
      enable = true;

      packages = ["com.github.tchx84.Flatseal"];

      update.auto.enable = true;
    };

    xdg.portal = lib.mkIf config.services.xserver.windowManager.i3.enable {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
      configPackages = with pkgs; [xfce.xfce4-session];
    };
  };
}
