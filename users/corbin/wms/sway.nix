{
  config,
  lib,
  pkgs,
  machine,
  inputs,
  ...
}: {
  options.sway.enable = lib.mkEnableOption "Enables swaywm";

  config = lib.mkIf config.sway.enable {
    home.packages = with pkgs; [
      ulauncher
      swaysome
      xwayland-satellite
      cliphist
      wl-clipboard

      nwg-displays

      inputs.self.packages.x86_64-linux.sw_swaybar
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

    xdg.configFile."ulauncher/settings.json".source = pkgs.writeText "ulauncher-settings.json" (
      builtins.toJSON {
        "blacklisted-desktop-dirs" = "/usr/share/locale:/usr/share/app-install:/usr/share/kservices5:/usr/share/fk5:/usr/share/kservicetypes5:/usr/share/applications/screensavers:/usr/share/kde4:/usr/share/mimelnk";
        "clear-previous-query" = true;
        "disable-desktop-filters" = false;
        "grab-mouse-pointer" = true;
        "hotkey-show-app" = "<Primary>space";
        "render-on-screen" = "mouse-pointer-monitor";
        "show-indicator-icon" = true;
        "show-recent-apps" = "0";
        "terminal-command" = "ghostty";
        "theme-name" = "Black-Theme";
      }
    );

    home.sessionVariables = {
      DISPLAY =
        if machine == "vm"
        then ":0"
        else ":1";
    };

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

    services.polkit-gnome.enable = true;

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
          {
            timeout = 300;
            command = "${pkgs.brightnessctl}/bin/brightnessctl --save; ${pkgs.brightnessctl}/bin/brightnessctl set 5%";
            resumeCommand = "${pkgs.brightnessctl}/bin/brightnessctl --restore";
          }
        ]
        ++ (lib.optional (machine == "laptop") {
          timeout = 600;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        });

      events = {
        "before-sleep" =
          if machine == "laptop"
          then "${pkgs.gtklock}/bin/gtklock -M eDP-1"
          else if machine == "desktop"
          then "${pkgs.gtklock}/bin/gtklock -M DP-1"
          else "${pkgs.gtklock}/bin/gtklock";
      };
    };

    systemd.user.services.xwayland-satellite = lib.mkIf (machine != "vm") {
      Unit = {
        Description = "Xwayland outside your Wayland";
        BindsTo = ["wayland-session@sway.target"];
        PartOf = ["wayland-session@sway.target"];
        After = ["wayland-session@sway.target"];
        Requisite = ["wayland-session@sway.target"];
      };

      Service = {
        Type = "notify";
        NotifyAccess = "all";
        ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite :1";
        StandardOutput = "journal";
        Restart = "always";
        RestartSec = 1;
      };

      Install = {
        WantedBy = ["wayland-session@sway.target"];
      };
    };

    wayland.windowManager.sway = {
      enable = true;

      package = pkgs.sway;

      xwayland = machine == "vm";

      config = let
        modifier = config.wayland.windowManager.sway.config.modifier;
        terminal = config.wayland.windowManager.sway.config.terminal;
        display =
          if machine == "vm"
          then ":0"
          else ":1";

        launcher = "DISPLAY=${display} ${pkgs.ulauncher}/bin/ulauncher --no-window-shadow";
        swaysome = "${pkgs.swaysome}/bin/swaysome";
      in {
        output =
          if (machine == "desktop")
          then {
            DP-1 = {
              scale = "1.5";
              mode = "3840x2160@120hz";
              position = "0,0";
              adaptive_sync = "false";
            };
            DP-2 = {
              scale = "1.5";
              mode = "3840x2160@150hz";
              position = "2560,0";
              adaptive_sync = "false";
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
          dwt = "disabled";
        };

        terminal = "ghostty";

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
            (bar {
              fontSize = 32;
            })
          ]
          else if machine == "laptop"
          then [
            (bar {
              fontSize = 26;
              output = "eDP-1";
            })

            (bar {
              fontSize = 14;
              output = "DP-8";
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
            command = "${swaysome} init 1";
            always = false;
          }
          {
            command = "${pkgs.wl-clipboard}/bin/wl-paste --watch cliphist store";
            always = true;
          }
          {
            command = let
              script = pkgs.writeShellScript "1password-autostart" ''
                sleep 3;
                ${pkgs.uwsm}/bin/uwsm-app -- ${pkgs._1password-gui}/bin/1password --silent
              '';
            in "${script}";
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

        keybindings = let
          numKeys = map toString (lib.range 0 9);

          numberFromKeyCombo = combo: let
            number = lib.last (lib.stringToCharacters combo);
          in
            if number == "0"
            then "10"
            else number;

          focusKeys = lib.genAttrs (map (
              key:
                if machine == "vm"
                then "${modifier}+ctrl+${key}"
                else "${modifier}+${key}"
            )
            numKeys) (combo: "exec ${swaysome} focus ${numberFromKeyCombo combo}");

          moveKeys = lib.genAttrs (map (key: "${modifier}+Shift+${key}") numKeys) (
            combo: "exec ${swaysome} move ${numberFromKeyCombo combo}"
          );
        in
          focusKeys
          // moveKeys
          // (
            let
              slurp = "${pkgs.slurp}/bin/slurp";
              grim = "${pkgs.grim}/bin/grim";
              wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
              _1password = "${pkgs._1password-gui}/bin/1password";
              hyprpicker = "${pkgs.hyprpicker}/bin/hyprpicker";
              wlogout = "${pkgs.wlogout}/bin/wlogout";
            in {
              "${modifier}+Shift+r" = "restart";

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
              "${modifier}+s" = "exec ${slurp} | ${grim} -g - - | ${wl-copy}";
              "${modifier}+p" = "exec ${_1password} --quick-access";
              "${modifier}+c" = "exec ${hyprpicker} -a";
              "${modifier}+o" = "exec ${wlogout}";
            }
          )
          // (
            if machine != "vm"
            then let
              brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
              pactl = "${pkgs.pulseaudio}/bin/pactl";
            in {
              "XF86MonBrightnessDown" = "exec ${brightnessctl} s 10%-";
              "XF86MonBrightnessUp" = "exec ${brightnessctl} s 10%+";

              "XF86AudioMute" = "exec ${pactl} set-sink-mute @DEFAULT_SINK@ toggle";
              "XF86AudioRaiseVolume" = "exec ${pactl} set-sink-volume @DEFAULT_SINK@ +5%";
              "XF86AudioLowerVolume" = "exec ${pactl} set-sink-volume @DEFAULT_SINK@ -5%";
            }
            else {}
          );
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

    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

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

      gtk4.theme = config.gtk.theme;

      font = {
        name = "Inter SemiBold";
        package = pkgs.inter;
        size = 9.75;
      };
    };
  };
}
