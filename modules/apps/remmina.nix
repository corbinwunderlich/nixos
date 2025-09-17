{
  config,
  lib,
  ...
}: {
  options.remmina.enable = lib.mkEnableOption "Enables Remmina, a RDP client";

  config = lib.mkIf config.remmina.enable {
    services.flatpak.enable = true;

    services.flatpak.packages = [
      "org.remmina.Remmina"
    ];
  };
}
