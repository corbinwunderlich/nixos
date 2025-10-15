{
  lib,
  config,
  ...
}: {
  options.ghostty.enable = lib.mkEnableOption "Enables Ghostty";

  config = lib.mkIf config.ghostty.enable {
    programs.ghostty = {
      enable = true;

      installVimSyntax = true;

      settings = {
        background = "000000";
        foreground = "ffffff";

        font-family = "JetBrainsMono Nerd Font";
        font-family-bold = "JetBrainsMono Nerd Font";
        font-family-italic = "JetBrainsMono Nerd Font";
        font-family-bold-italic = "JetBrainsMono Nerd Font";
        #font-family-bold = "JetBrainsMono NF Bold";
        #font-family-italic = "JetBrainsMono NF SemiBold Italic";
        #font-family-bold-italic = "JetBrainsMono NF Bold Italic";

        font-style = "Bold";
        font-style-bold = "ExtraBold";
        font-style-italic = "Bold Italic";
        font-style-bold-italic = "ExtraBold Italic";

        font-size = 9;

        shell-integration-features = "no-cursor";
        cursor-style-blink = false;

        cursor-style = "underline";

        focus-follows-mouse = true;

        window-padding-x = 5;
        window-padding-y = 5;
        window-padding-color = "extend";
      };
    };
  };
}
