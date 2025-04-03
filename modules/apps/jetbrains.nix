{
  config,
  lib,
  pkgs,
  ...
}: {
  options.jetbrains.enable = lib.mkEnableOption "Enables the JetBrains suite of IDEs";

  config = lib.mkIf config.jetbrains.enable {
    environment.systemPackages = with pkgs.jetbrains; [
      idea-community-bin
    ];
  };
}
