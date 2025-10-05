{
  config,
  pkgs,
  lib,
  ...
}: {
  options.firefox.enable = lib.mkEnableOption "Enables Firefox";

  config = lib.mkIf config.firefox.enable {
    programs.firefox.enable = true;
    environment.sessionVariables.MOZ_USE_XINPUT2 = "1";
  };
}
