{
  config,
  lib,
  pkgs,
  ...
}: {
  options.fcitx.enable = lib.mkEnableOption "Enables Fcitx5 ui config files";

  config = lib.mkIf config.fcitx.enable {
    xdg.configFile."fcitx5/conf/classicui.conf".source = pkgs.writeText "fcitx5-classicui.conf" ''
      Vertical Candidate List = True

      WheelForPaging = True

      Font = JetBrainsMono Nerd Font Demi-Bold 10
      MenuFont = Inter Display SemiBold Demi-Bold 10
      TrayFont = Inter Display SemiBold Demi-Bold 10

      PreferTextIcon = True

      ShowLayoutNameInIcon = True

      TrayOutlineColor = #00000000

      UseInputMethodLanguageToDisplayText = True

      Theme = Fluentdark-solid
      DarkTheme = Fluentdark-solid

      UseAccentColor = True

      EnableFractionalScale = True
    '';
  };
}
