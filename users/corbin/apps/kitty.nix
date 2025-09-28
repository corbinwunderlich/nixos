{
  lib,
  config,
  machine,
  ...
}: {
  options.kitty.enable = lib.mkEnableOption "Enables Kitty";

  config = lib.mkIf config.kitty.enable {
    programs.kitty = {
      enable = true;

      environment = {
        "TERM" = "xterm-256color";
        "DISPLAY" = ":0";
      };

      shellIntegration.mode = "no-cursor";

      settings = {
        font_family = "JetBrainsMono NF SemiBold";
        bold_font = "JetBrainsMono NF Bold";
        italic_font = "JetBrainsMono NF SemiBold Italic";
        bold_italic_font = "JetBrainsMono NF Bold Italic";

        font_size = 9;

        cursor_shape = "underline";
        cursor_shape_unfocused = "underline";

        cursor_underline_thickness = 2;

        cursor_blink_interval = 0;

        default_pointer_shape = "arrow";

        repaint_delay = 6;

        window_margin_width = 5;

        tab_bar_edge = "top";
        tab_bar_margin_height = "6 0";
        tab_bar_style = "fade";

        tab_bar_align = "left";

        active_tab_font_style = "bold";

        background_opacity =
          if config.wayland.windowManager.hyprland.enable
          then 0
          else 100;
      };
    };
  };
}
