{
  lib,
  config,
  ...
}: {
  options.ghostty.enable = lib.mkEnableOption "Enables Ghostty";

  config = lib.mkIf config.ghostty.enable {
    programs.ghostty = {
      enable = true;

      enableZshIntegration = true;

      installVimSyntax = true;

      settings = {
        background = "000000";
        foreground = "ffffff";

        cursor-color = "#ffffff";

        theme = "arcoiris";

        font-family = "JetBrainsMono Nerd Font";
        font-family-bold = "JetBrainsMono Nerd Font";
        font-family-italic = "JetBrainsMono Nerd Font";
        font-family-bold-italic = "JetBrainsMono Nerd Font";

        font-style = "Bold";
        font-style-bold = "ExtraBold";
        font-style-italic = "Bold Italic";
        font-style-bold-italic = "ExtraBold Italic";

        font-size = 9;

        cursor-style-blink = false;
        cursor-style = "underline";
        adjust-cursor-thickness = 3;
        adjust-underline-thickness = 5;

        focus-follows-mouse = true;

        window-padding-x = 5;
        window-padding-y = 5;
        window-padding-color = "extend";
      };
    };
  };
}
