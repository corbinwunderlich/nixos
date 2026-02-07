{
  config,
  lib,
  ...
}: {
  options.chromium.enable = lib.mkEnableOption "Enables Chromium";

  config = lib.mkIf config.chromium.enable {
    services.flatpak.enable = true;

    services.flatpak.packages = [
      "org.chromium.Chromium"
    ];
  };
}
