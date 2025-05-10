{
  config,
  lib,
  pkgs,
  ...
}: {
  options.kicad.enable = lib.mkEnableOption "Enables kicad";

  config = lib.mkIf config.kicad.enable {
    environment.systemPackages = with pkgs; [kicad temurin-jre-bin-21];
  };
}
