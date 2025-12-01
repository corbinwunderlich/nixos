{
  config,
  lib,
  pkgs,
  ...
}: {
  options.thunderbird.enable = lib.mkEnableOption "Enables Thunderbird";

  config = lib.mkIf config.thunderbird.enable {
    programs.thunderbird.enable = true;

    services.flatpak.enable = true;

    services.flatpak.packages = [
      "com.ulduzsoft.Birdtray"
    ];
  };
}
