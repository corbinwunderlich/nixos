{
  pkgs,
  lib,
  config,
  ...
}: {
  options.vesktop.enable = lib.mkEnableOption "Enables Vesktop";

  config = lib.mkIf config.vesktop.enable {
    services.flatpak.enable = true;

    services.flatpak.packages = [
      "dev.vencord.Vesktop"
    ];
  };
}
