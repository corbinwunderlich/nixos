{
  config,
  lib,
  ...
}: {
  options.flatpak.enable = lib.mkEnableOption "Enable flatpak";

  config = lib.mkIf config.flatpak.enable {
    services.flatpak = {
      enable = true;

      packages = ["com.github.tchx84.Flatseal"];

      update.auto.enable = true;
    };
  };
}
