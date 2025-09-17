{
  config,
  lib,
  pkgs,
  ...
}: {
  options.bambu-studio.enable = lib.mkEnableOption "Enables Bambu Studio slicer and other 3d printing utilities";

  config = lib.mkIf config.bambu-studio.enable {
    services.flatpak.enable = true;

    services.flatpak.packages = [
      "com.bambulab.BambuStudio"
    ];
  };
}
