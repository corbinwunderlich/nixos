{
  config,
  lib,
  pkgs,
  ...
}: {
  options.prismlauncher.enable = lib.mkEnableOption "Enables PrismLauncher";

  config = lib.mkIf config.prismlauncher.enable {
    environment.systemPackages = with pkgs; [
      prismlauncher

      jre8
      jre17_minimal
      jdk
    ];
  };
}
