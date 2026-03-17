{
  config,
  lib,
  ...
}: {
  options.firefox.enable = lib.mkEnableOption "Enables Firefox";

  config = lib.mkIf config.firefox.enable {
    programs.firefox.enable = true;
    environment.sessionVariables = {
      MOZ_USE_XINPUT2 = "1";
      MOZ_ENABLE_WAYLAND =
        if (config.sway.enable || config.hyprland.enable || config.environment.sessionVariables.NIXOS_OZONE_WL)
        then "1"
        else "0";
    };
  };
}
