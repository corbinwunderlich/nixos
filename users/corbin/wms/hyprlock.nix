{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options.hyprlock.enable = lib.mkEnableOption "Enables Hyprlock";

  config = lib.mkIf config.hyprlock.enable {
    programs.hyprlock = {
      enable = true;
      package = inputs.hyprlock.packages.${pkgs.stdenv.hostPlatform.system}.hyprlock;

      settings = {
        general = {
          hide_cursor = false;
          disable_loading_bar = false;
        };

        background = {
          path = "/home/corbin/Pictures/wallpapers/cities/wallhaven-gpedg3_3840x2160.png";

          blur_passes = 4;
          blur_size = 2;
          noise = 0;
          brightness = 0.7;
          vibrancy = 0.6;
          vibrancy_darkness = 0;
          contrast = 0.9;
        };

        input-field = {
          monitor = "DP-2";
          size = "200, 50";

          placeholder_text = "";

          outline_thickness = 0;
          inner_color = "rgba(10, 10, 10, 0.1)";
          font_color = "rgb(255, 255, 255)";

          shadow_passes = 4;
          shadow_size = 2;
          shadow_boost = 3;

          dots_size = 0.2;
          dots_spacing = 0.15;
          dots_center = true;
          dots_rounding = -1;

          fade_on_empty = false;
          hide_input = false;
          rounding = -1;

          position = "0, -40";
          halign = "center";
          valign = "center";
        };

        label = {
          monitor = "DP-2";

          text = "cmd[update:100] date +%H:%M:%S";
          text_align = "center";

          color = "rgb(255, 255, 255)";
          font_size = 75;
          font_family = "JetBrainsMono Nerd Font Mono";

          position = "0, 100";
          halign = "center";
          valign = "center";
        };
      };
    };
  };
}
