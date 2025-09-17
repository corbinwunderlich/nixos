{
  config,
  lib,
  ...
}: {
  options.bottles.enable = lib.mkEnableOption "Enables Bottles";

  config = lib.mkIf config.bottles.enable {
    services.flatpak.enable = true;

    services.flatpak.packages = [
      "com.usebottles.bottles"
    ];
  };
}
