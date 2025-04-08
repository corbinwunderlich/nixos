{
  config,
  lib,
  pkgs,
  ...
}: {
  options.arduino.enable = lib.mkEnableOption "Enables arduino tools and kicad";

  config = lib.mkIf config.arduino.enable {
    environment.systemPackages = with pkgs; [arduino-cli arduino-language-server kicad];
  };
}
