{
  config,
  lib,
  pkgs,
  machine,
  ...
}: {
  options.sway.enable = lib.mkEnableOption "Enables swaywm";

  config = lib.mkIf config.sway.enable {
    home.packages = with pkgs; [
      ulauncher
      swaysome
      xwayland-satellite
    ];

    wayland.windowManager.sway = {
      enable = true;

      #package = pkgs.swayfx;
      package = pkgs.sway;

      xwayland = false;

      config = let
        modifier = config.wayland.windowManager.sway.config.modifier;
        terminal = config.wayland.windowManager.sway.config.terminal;
        launcher = "DISPLAY=:0 ${pkgs.ulauncher}/bin/ulauncher --no-window-shadow";
        swaysome = "${pkgs.swaysome}/bin/swaysome";
      in {
        output = lib.mkIf (machine == "desktop") {
          DP-2 = {
            scale = "1.5";
            mode = "3840x2160@150hz";
            position = "0,0";
            adaptive_sync = "true";
          };
          DP-1 = {
            mode = "1920x1200@60hz";
            transform = "90";
            position = "2560,-300";
          };
        };

        modifier =
          if machine == "vm"
          then "Mod1"
          else "Mod4";

        terminal = "kitty";

        fonts = {
          names = ["JetBrainsMono Nerd Font"];
          style = "SemiBold";
          size = 9.0;
        };

        bars = [
          {
            fonts = {
              names = ["JetBrainsMono Nerd Font"];
              style = "SemiBold";
              size = 9.0;
            };

            statusCommand = "i3status";
          }
        ];

        window = {
          border = 2;
          titlebar = false;
          hideEdgeBorders = "smart";
        };

        floating = {
          border = 2;
          titlebar = false;
        };

        startup = [
          {
            command = "${pkgs.autotiling}/bin/autotiling";
            always = true;
          }
          {
            command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &";
            always = true;
          }
          {
            command = "${pkgs._1password-gui}/bin/1password --silent";
            always = true;
          }
          {
            command = "${swaysome} init 1";
            always = false;
          }
          {
            command = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
            always = false;
          }
          {
            command = "${swaysome} focus-group 2; ${swaysome} focus-group 0";
            always = false;
          }
        ];

        defaultWorkspace = "workspace number 1";

        modes = {
          resize = {
            Up = "resize grow height 10 px or 10 ppt";
            Down = "resize shrink height 10 px or 10 ppt";
            Left = "resize shrink width 10 px or 10 ppt";
            Right = "resize grow width 10 px or 10 ppt";

            Return = "mode default";
            Escape = "mode default";
            "${modifier}+r" = "mode default";
          };
        };

        keybindings =
          if (machine == "vm")
          then {
            "${modifier}+Shift+r" = "restart";

            "${modifier}+ctrl+1" = "exec ${swaysome} focus 1";
            "${modifier}+ctrl+2" = "exec ${swaysome} focus 2";
            "${modifier}+ctrl+3" = "exec ${swaysome} focus 3";
            "${modifier}+ctrl+4" = "exec ${swaysome} focus 4";
            "${modifier}+ctrl+5" = "exec ${swaysome} focus 5";
            "${modifier}+ctrl+6" = "exec ${swaysome} focus 6";
            "${modifier}+ctrl+7" = "exec ${swaysome} focus 7";
            "${modifier}+ctrl+8" = "exec ${swaysome} focus 8";
            "${modifier}+ctrl+9" = "exec ${swaysome} focus 9";
            "${modifier}+ctrl+0" = "exec ${swaysome} focus 10";

            "${modifier}+Shift+1" = "exec swaysome move 1";
            "${modifier}+Shift+2" = "exec swaysome move 2";
            "${modifier}+Shift+3" = "exec swaysome move 3";
            "${modifier}+Shift+4" = "exec swaysome move 4";
            "${modifier}+Shift+5" = "exec swaysome move 5";
            "${modifier}+Shift+6" = "exec swaysome move 6";
            "${modifier}+Shift+7" = "exec swaysome move 7";
            "${modifier}+Shift+8" = "exec swaysome move 8";
            "${modifier}+Shift+9" = "exec swaysome move 9";
            "${modifier}+Shift+0" = "exec swaysome move 10";

            "${modifier}+Left" = "focus left";
            "${modifier}+Right" = "focus right";
            "${modifier}+Up" = "focus up";
            "${modifier}+Down" = "focus down";

            "${modifier}+Shift+Left" = "move left";
            "${modifier}+Shift+Right" = "move right";
            "${modifier}+Shift+Up" = "move up";
            "${modifier}+Shift+Down" = "move down";

            "${modifier}+r" = "mode resize";

            "${modifier}+f" = "fullscreen toggle";

            "${modifier}+Shift+v" = "focus mode_toggle";
            "${modifier}+v" = "floating toggle";

            "${modifier}+Return" = "exec ${terminal}";
            "${modifier}+d" = "exec ${launcher}";
            "${modifier}+e" = "exec ${launcher}";
            "${modifier}+Shift+q" = "kill";
          }
          else {
            "${modifier}+Shift+r" = "restart";

            "${modifier}+1" = "exec ${swaysome} focus 1";
            "${modifier}+2" = "exec ${swaysome} focus 2";
            "${modifier}+3" = "exec ${swaysome} focus 3";
            "${modifier}+4" = "exec ${swaysome} focus 4";
            "${modifier}+5" = "exec ${swaysome} focus 5";
            "${modifier}+6" = "exec ${swaysome} focus 6";
            "${modifier}+7" = "exec ${swaysome} focus 7";
            "${modifier}+8" = "exec ${swaysome} focus 8";
            "${modifier}+9" = "exec ${swaysome} focus 9";
            "${modifier}+0" = "exec ${swaysome} focus 10";

            "${modifier}+Shift+1" = "exec swaysome move 1";
            "${modifier}+Shift+2" = "exec swaysome move 2";
            "${modifier}+Shift+3" = "exec swaysome move 3";
            "${modifier}+Shift+4" = "exec swaysome move 4";
            "${modifier}+Shift+5" = "exec swaysome move 5";
            "${modifier}+Shift+6" = "exec swaysome move 6";
            "${modifier}+Shift+7" = "exec swaysome move 7";
            "${modifier}+Shift+8" = "exec swaysome move 8";
            "${modifier}+Shift+9" = "exec swaysome move 9";
            "${modifier}+Shift+0" = "exec swaysome move 10";

            "${modifier}+Left" = "focus left";
            "${modifier}+Right" = "focus right";
            "${modifier}+Up" = "focus up";
            "${modifier}+Down" = "focus down";

            "${modifier}+Shift+Left" = "move left";
            "${modifier}+Shift+Right" = "move right";
            "${modifier}+Shift+Up" = "move up";
            "${modifier}+Shift+Down" = "move down";

            "${modifier}+r" = "mode resize";

            "${modifier}+f" = "fullscreen toggle";

            "${modifier}+Shift+v" = "focus mode_toggle";
            "${modifier}+v" = "floating toggle";

            "${modifier}+Return" = "exec ${terminal}";
            "${modifier}+d" = "exec ${launcher}";
            "${modifier}+e" = "exec ${launcher}";
            "${modifier}+Shift+q" = "kill";

            "XF86MonBrightnessDown" = "exec brightnessctl s 5%-";
            "XF86MonBrightnessUp" = "exec brightnessctl s 5%+";
          };
      };
    };

    programs.i3status = {
      enable = true;

      general = {
        colors = true;
        interval = 1;
      };

      modules = {
        "cpu_usage" = {
          position = 1;
          settings.format = "%usage";
        };

        "battery all" = {
          position = 2;
          enable = machine == "laptop";
          settings = {
            format = "%percentage %status";
            format_percentage = "%.0f%s";
            status_chr = "and charging";
            status_bat = "on battery";
            status_unk = "";
            status_full = "";
            status_idle = "";
            last_full_capacity = true;
          };
        };

        "tztime local" = {
          position = 3;
          settings.format = "%H:%M:%S";
        };

        "ipv6".enable = false;
        "wireless _first_".enable = false;
        "ethernet _first_".enable = false;
        "disk /".enable = false;
        "load".enable = false;
        "memory".enable = false;
      };
    };

    gtk = {
      enable = true;

      iconTheme = {
        name = "kora";
        package = pkgs.kora-icon-theme;
      };

      theme = {
        name = "Adwaita-dark-amoled";
        package = pkgs.stdenvNoCC.mkDerivation {
          pname = "adwaita-dark-amoled";
          version = "2023-06-03";

          src = pkgs.fetchFromGitLab {
            owner = "tearch-linux";
            repo = "artworks/themes-and-icons/Adwaita-dark-amoled";
            rev = "7fd16477";
            hash = "sha256-tMMTUM0stpBcyAC0Y8w79m9VYTdyEJNg6yyei64Ut6w=";
          };

          installPhase = ''
            mkdir -p $out/share/themes/Adwaita-dark-amoled
            cp -a $src/gtk-2.0 $src/gtk-3.0 $out/share/themes/Adwaita-dark-amoled
          '';
        };
      };

      font = {
        name = "Inter SemiBold";
        package = pkgs.inter;
        size = 9.75;
      };
    };
  };
}
