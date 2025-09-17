{
  pkgs,
  lib,
  config,
  ...
}: {
  options.dunst.enable = lib.mkEnableOption "Enables the dunst notification daemon";

  config = lib.mkIf config.dunst.enable {
    services.dunst = {
      enable = true;
      package = pkgs.dunst;

      iconTheme = {
        name = "kora";
        package = pkgs.kora-icon-theme;
      };

      settings = {
        global = {
          monitor = 0;
          follow = "none";

          width = 300;
          height = 100;

          origin = "top-right";
          offset = "10x50";

          scale = 0;

          notification_limit = 4;

          progress_bar = true;
          progress_bar_height = 10;
          progress_bar_frame_width = 1;
          progress_bar_min_width = 150;
          progress_bar_max_width = 300;
          progress_bar_corner_radius = 0;
          progress_bar_corners = "all";

          icon_corner_radius = 0;
          icon_corners = "all";

          indicate_hidden = "yes";

          transparency =
            if config.wayland.windowManager.hyprland.enable
            then 100
            else 0;

          separator_height = 10;

          padding = 8;

          horizontal_padding = 8;

          text_icon_padding = 0;

          frame_width =
            if config.wayland.windowManager.hyprland.enable
            then 0
            else 2;

          gap_size = 20;

          separator_color = "frame";

          sort = "yes";

          font = "JetBrainsMono nerd Font SemiBold 9";
          markup = "full";
          format = ''
            <b><big>%a</big></b>
            \n%s
            \n%b'';

          line_height = 0;

          alignment = "left";
          vertical_alignment = "center";

          show_age_threshold = 60;

          ellipsize = "middle";

          ignore_newline = "no";

          stack_duplicates = true;

          hide_duplicate_count = false;

          show_indicators = "no";

          enable_recursive_icon_lookup = true;

          sticky_history = "yes";

          history_length = 20;

          browser = "${pkgs.xdg-utils}/bin/xdg-open";

          always_run_script = true;

          title = "Dunst";
          class = "Dunst";

          corner_radius =
            if config.wayland.windowManager.hyprland.enable
            then 10
            else 0;

          corners = "all";

          ignore_dbusclose = false;

          force_xwayland = false;

          force_xinerama = false;

          mouse_left_click = "close_current";
          mouse_middle_click = "do_action, close_current";
          mouse_right_click = "close_all";
        };

        urgency_low = {
          background = "#000000";
          foreground = "#888888";
          timeout = 10;
          #default_icon = /path/to/icon
        };

        urgency_normal = {
          background = "#000000";
          foreground = "#ffffff";
          timeout = 10;
          override_pause_level = 30;
          #default_icon = /path/to/icon
        };

        urgency_critical = {
          background = "#000000";
          foreground = "#ffffff";
          frame_color = "#ff0000";
          timeout = 0;
          override_pause_level = 60;
          #default_icon = /path/to/icon
        };
      };
    };
  };
}
