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

      (pkgs.callPackage ../../../packages/sw_swaybar.nix {sw = pkgs.callPackage ../../../packages/sw.nix {};})
    ];

    xdg.configFile."ulauncher/user-themes/black" = {
      force = true;
      recursive = true;

      source = pkgs.fetchFromGitHub {
        owner = "corbinwunderlich";
        repo = "black-ulauncher-theme";
        rev = "main";
        hash = "sha256-YV+pOCSdamZam1+AALxvyiR42ZkEtxE5/uaRff3yXJU=";
      };
    };

    xdg.configFile."ulauncher/settings.json".source = pkgs.writeText "ulauncher-settings.json" (builtins.toJSON {
      "blacklisted-desktop-dirs" = "/usr/share/locale:/usr/share/app-install:/usr/share/kservices5:/usr/share/fk5:/usr/share/kservicetypes5:/usr/share/applications/screensavers:/usr/share/kde4:/usr/share/mimelnk";
      "clear-previous-query" = true;
      "disable-desktop-filters" = false;
      "grab-mouse-pointer" = true;
      "hotkey-show-app" = "<Primary>space";
      "render-on-screen" = "mouse-pointer-monitor";
      "show-indicator-icon" = true;
      "show-recent-apps" = "0";
      "terminal-command" = "kitty";
      "theme-name" = "Black-Theme";
    });

    home.pointerCursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 18;
      x11 = {
        enable = true;
        defaultCursor = "Adwaita";
      };
      gtk.enable = true;
      sway.enable = true;
    };

    services.swayidle = let
      display = status: "swaymsg 'output * power ${status}'";
    in {
      enable = true;

      timeouts =
        [
          {
            timeout = 900;
            command = display "off";
            resumeCommand = display "on";
          }
        ]
        ++ (lib.optional (machine == "laptop") {
          timeout = 300;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        });

      events = [
        {
          event = "before-sleep";
          command =
            if machine == "laptop"
            then "${pkgs.gtklock}/bin/gtklock -M eDP-1"
            else if machine == "desktop"
            then "${pkgs.gtklock}/bin/gtklock -M DP-1"
            else "${pkgs.gtklock}/bin/gtklock";
        }
      ];
    };

    wayland.windowManager.sway = {
      enable = true;

      package = pkgs.sway;

      xwayland = machine == "vm";

      config = let
        modifier = config.wayland.windowManager.sway.config.modifier;
        terminal = config.wayland.windowManager.sway.config.terminal;
        launcher = "DISPLAY=:0 ${pkgs.ulauncher}/bin/ulauncher --no-window-shadow";
        swaysome = "${pkgs.swaysome}/bin/swaysome";
      in {
        output =
          if (machine == "desktop")
          then {
            DP-1 = {
              scale = "1.5";
              mode = "3840x2160@150hz";
              position = "0,0";
              adaptive_sync = "true";
            };
            DP-2 = {
              scale = "1.5";
              mode = "3840x2160@120hz";
              position = "2560,0";
              adaptive_sync = "true";
            };
          }
          else {
            eDP-1 = {
              scale = "2";
              mode = "2880x1800@120hz";
              position = "0,0";
              adaptive_sync = "true";
            };
          };

        modifier =
          if machine == "vm"
          then "Mod1"
          else "Mod4";

        input."type:touchpad" = {
          tap = "enabled";
        };

        terminal = "kitty";

        fonts = {
          names = ["JetBrainsMono Nerd Font"];
          style = "SemiBold";
          size = 9.0;
        };

        bars = let
          bar = {
            fontSize,
            output ? "*",
          }: {
            command = "sw_swaybar";

            extraConfig =
              ''
                font JetBrainsMono Nerd Font-${toString fontSize}:SemiBold
              ''
              + lib.optionalString (output != "*") ''
                output ${output}
              '';

            statusCommand = "i3status";
          };
        in
          if machine == "desktop"
          then [
            (bar
              {
                fontSize = 32;
              })
          ]
          else if machine == "laptop"
          then [
            (bar
              {
                fontSize = 26;
                output = "eDP-1";
              })

            (bar
              {
                fontSize = 14;
                output = "DP-2";
              })
          ]
          else if machine == "vm"
          then [
            (bar {fontSize = 14;})
          ]
          else [];

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
            command = "env NIXOS_OZONE_WL=1 ${pkgs._1password-gui}/bin/1password --silent";
            always = true;
          }
          {
            command = "${swaysome} init 1";
            always = false;
          }
          (lib.mkIf (machine != "vm")
            {
              command = "${pkgs.uwsm}/bin/uwsm app -- ${pkgs.xwayland-satellite}/bin/xwayland-satellite :0";
              always = true;
            })
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
            "${modifier}+s" = "exec ${pkgs.slurp}/bin/slurp | ${pkgs.grim}/bin/grim -g - - | ${pkgs.wl-clipboard}/bin/wl-copy";
            "${modifier}+p" = "exec ${pkgs._1password-gui}/bin/1password --quick-access";
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
            "${modifier}+s" = "exec ${pkgs.slurp}/bin/slurp | ${pkgs.grim}/bin/grim -g - - | ${pkgs.wl-clipboard}/bin/wl-copy";
            "${modifier}+p" = "exec ${pkgs._1password-gui}/bin/1password --quick-access";

            "XF86MonBrightnessDown" = "exec brightnessctl s 10%-";
            "XF86MonBrightnessUp" = "exec brightnessctl s 10%+";

            "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
            "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
            "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
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

    dconf.settings = {
      "org/gnome/desktop/background" = {
        picture-uri-dark = "file://${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.src}";
      };

      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };

    gtk = {
      enable = true;

      iconTheme = {
        name = "kora";
        package = pkgs.kora-icon-theme;
      };

      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };

      font = {
        name = "Inter SemiBold";
        package = pkgs.inter;
        size = 9.75;
      };
    };
  };
}
