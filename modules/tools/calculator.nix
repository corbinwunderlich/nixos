{
  config,
  lib,
  pkgs,
  ...
}: {
  options.calculator.enable = lib.mkEnableOption "Enables Qalculate";

  config = lib.mkIf config.bottles.enable {
    services.flatpak.enable = true;

    services.flatpak.packages = [
      "io.github.Qalculate"
    ];

    environment.systemPackages = with pkgs; [calc];
  };
}
