{
  config,
  lib,
  pkgs,
  ...
}: {
  options.kicad.enable = lib.mkEnableOption "Enables kicad";

  config = lib.mkIf config.kicad.enable {
    services.flatpak.enable = true;

    services.flatpak.packages = [
      "org.kicad.KiCad"
    ];
  };
}
