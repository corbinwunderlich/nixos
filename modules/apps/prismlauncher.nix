{
  config,
  lib,
  pkgs,
  ...
}: {
  options.prismlauncher.enable = lib.mkEnableOption "Enables PrismLauncher";

  config = lib.mkIf config.prismlauncher.enable {
    environment.systemPackages = with pkgs; [
      jre8
      jre17_minimal
      jdk
    ];

    services.flatpak.enable = true;

    services.flatpak.packages = [
      "org.prismlauncher.PrismLauncher"
    ];
  };
}
