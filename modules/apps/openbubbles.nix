{
  lib,
  config,
  ...
}: {
  options.openbubbles.enable = lib.mkEnableOption "Enables OpenBubbles";

  config = lib.mkIf config.openbubbles.enable {
    services.flatpak.enable = true;

    services.flatpak.packages = [
      "app.openbubbles.OpenBubbles"
    ];
  };
}
