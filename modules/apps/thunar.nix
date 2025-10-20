{
  config,
  lib,
  pkgs,
  ...
}: {
  options.thunar.enable = lib.mkEnableOption "Enables Thunar";

  config = lib.mkIf config.thunar.enable {
    programs.thunar = {
      enable = true;
      plugins = with pkgs.xfce; [thunar-archive-plugin];
    };

    services.gvfs.enable = true;
    services.tumbler.enable = true;

    environment.systemPackages = with pkgs; [oculante vlc];

    xdg.mime.defaultApplications = {
      "application/pdf" = "firefox.desktop";

      "image/jpeg" = "oculante.desktop";
      "image/png" = "oculante.desktop";
      "image/*" = "oculante.desktop";
    };
  };
}
