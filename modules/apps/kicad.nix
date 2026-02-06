{
  config,
  lib,
  machine,
  ...
}: {
  options.kicad.enable = lib.mkEnableOption "Enables kicad";

  config = lib.mkIf config.kicad.enable {
    services.flatpak.enable = true;

    services.flatpak.packages = [
      "org.kicad.KiCad"
    ];

    services.flatpak.overrides."org.kicad.KiCad" = {
      Environment.DISPLAY =
        if machine == "vm"
        then ":0"
        else ":1";

      Context.sockets = ["x11"];
    };
  };
}
