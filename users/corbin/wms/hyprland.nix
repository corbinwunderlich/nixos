{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  nixpkgs.config.allowUnfree = true;

  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    ${pkgs.ags}/bin/ags &
    ${pkgs.hyprpaper}/bin/hyprpaper &
    ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &
    ${pkgs._1password-gui}/bin/1password --silent &
    ${
      inputs.hyprland.packages.${pkgs.system}.hyprland
    }/bin/hyprctl setcursor rose-pine-hyprcursor 24 &
    fcitx5 -dr &
    fcitx5-remote -r &
  '';
in {
  imports = [./widgets/ags.nix];

  options.hyprland.enable = lib.mkEnableOption "Enables Hyprland";

  config = lib.mkIf config.hyprland.enable {
    home.packages = [
      pkgs.hyprcursor
      pkgs.rose-pine-cursor
      pkgs.kora-icon-theme
      pkgs.nwg-look
      inputs.hyprland-contrib.packages.${pkgs.system}.grimblast
      pkgs.slurp
      pkgs.wl-clipboard
      pkgs.xorg.xrandr
      inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
      pkgs.hyprpicker
      pkgs.libnotify
    ];

    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;

      package = pkgs.rose-pine-cursor;
      name = "BreezeX-RosePine-Linux";
      size = 24;
    };

    gtk = {
      enable = true;

      iconTheme = {
        package = pkgs.kora-icon-theme;
        name = "kora";
      };

      cursorTheme = {
        name = "BreezeX-RosePine-Linux";
        package = pkgs.rose-pine-cursor;
        size = 24;
      };

      theme = {
        name = "Materia-dark";
        package = pkgs.materia-theme-transparent;
      };

      font = {
        name = "Inter SemiBold";
        package = pkgs.inter;
        size = 9.75;
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      settings = {
        exec-once = "${startupScript}/bin/start";

        env = [
          "HYPRCURSOR_THEME,rose-pine-hyprcursor"
          "HYPRCURSOR_SIZE,24"
          "XCURSOR_THEME, rose-pine-cursor"
          "XCURSOR_SIZE, 24"
        ];

        cursor.no_hardware_cursors = false;

        monitor = [
          "DP-2,3840x2160@150,0x0,1.5"
          "DP-1,1920x1200@60,2560x-500,1,transform,3"
        ];

        xwayland.force_zero_scaling = true;

        input = {
          kb_layout = "us";

          follow_mouse = 1;
        };

        general = {
          gaps_in = 7;
          gaps_out = 14;

          border_size = 0;

          layout = "dwindle";
        };

        misc = {
          vrr = 1;
        };

        decoration = {
          rounding = 10;

          blur = {
            enabled = true;

            size = 2;
            passes = 4;
            noise = 0;
            brightness = 0.7;
            vibrancy = 0.6;
            contrast = 0.9;

            new_optimizations = true;

            popups = 1;
          };

          shadow = {
            enabled = true;
            range = 40;
            render_power = 4;
            color = "rgba(1a1a1a40)";
          };

          blurls = ["dunst" "ags-bar" "top-bar" "fcitx" "fcitx5"];

          layerrule = [
            "blur, notifications"
            "blur, notifications"
            "ignorezero, notifications"
            "ignorezero, ulauncher"
            "ignorezero, launcher"
            "blur, ags-drawer"
            "blur, top-bar"
            "blur, quick-settings"
            "ignorezero, quick-settings"
            "blur, volume-popup"
            "ignorezero, volume-popup"
            "blur, desktop-context-menu"
            "ignorezero, desktop-context-menu"
            "blur, fcitx"
            "blur, fcitx5"
          ];
        };

        animations = {
          enabled = "yes";

          bezier = [
            "openBezier, 0.2, 0.9, 0.1, 1.07"
            "workspaceBezier, 0.4, 0.9, 0.1, 1"
          ];

          animation = [
            "windows, 1, 6, openBezier"
            "windowsIn, 1, 6, openBezier, popin 0%"
            "windowsOut, 1, 7, default, popin 80%"
            "fade, 1, 7, default"
            "workspaces, 1, 7, workspaceBezier, slide"
          ];
        };

        dwindle = {
          pseudotile = "yes";
          preserve_split = "yes";
        };

        device = {
          name = "turtle-beach-burst-ii-air-dongle-mouse";
          sensitivity = 0.7;
        };

        windowrule = [
          "float, ^(1Password)$"
          "center, ^(1Password)$"

          "opacity 0.999, ^(firefox)$"

          "float, ^(wofi)$"
          "move 78 42, ^(wofi)$"
          "animation slidevert, ^(wofi)$"

          "monitor DP-1, ^(vesktop)$"
          "workspace 2, ^(vesktop)$"
        ];

        "$mainMod" = "SUPER";

        bind = [
          "$mainMod, W, exec, ags -t ags-drawer"

          # Screenshot with grimblast
          ", code:107, exec, grimblast copysave area"

          # Volume control for thinkpad t14
          ", code:121, exec,bash ~/.config/hypr/volume 0%"
          ", code:122, exec,bash ~/.config/hypr/volume -10%"
          ", code:123, exec,sh ~/.config/hypr/volume +10% "

          # Brightness control for thinkpad t14
          ", code:232, exec, brightnessctl s 10%-"
          ", code:233, exec, brightnessctl s +10%"

          "$mainMod SHIFT, Q, killactive, "
          "$mainMod, M, exit, "
          "$mainMod, E, exec, thunar"
          "$mainMod, V, togglefloating, "
          "$mainMod, D, exec, wofi --show drun -W 335 -H 600 --allow-images -b -n -e -i -c ~/.config/wofi/config"
          ''$mainMod, C, exec, notify-send -t 10000 "Your color was: $(hyprpicker -a)"''
          "$mainMod, P, pseudo,"
          "$mainMod, J, togglesplit,"

          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"

          "$mainMod, f, fullscreen"

          "$mainMod,R,submap,resize"

          "$mainMod, 1, split-workspace, 1"
          "$mainMod, 2, split-workspace, 2"
          "$mainMod, 3, split-workspace, 3"
          "$mainMod, 4, split-workspace, 4"
          "$mainMod, 5, split-workspace, 5"
          "$mainMod, 6, split-workspace, 6"
          "$mainMod, 7, split-workspace, 7"
          "$mainMod, 8, split-workspace, 8"
          "$mainMod, 9, split-workspace, 9"
          "$mainMod, 0, split-workspace, 10"

          "$mainMod SHIFT, 1, split-movetoworkspace, 1"
          "$mainMod SHIFT, 2, split-movetoworkspace, 2"
          "$mainMod SHIFT, 3, split-movetoworkspace, 3"
          "$mainMod SHIFT, 4, split-movetoworkspace, 4"
          "$mainMod SHIFT, 5, split-movetoworkspace, 5"
          "$mainMod SHIFT, 6, split-movetoworkspace, 6"
          "$mainMod SHIFT, 7, split-movetoworkspace, 7"
          "$mainMod SHIFT, 8, split-movetoworkspace, 8"
          "$mainMod SHIFT, 9, split-movetoworkspace, 9"
          "$mainMod SHIFT, 0, split-movetoworkspace, 10"

          "$mainMod SHIFT, up, movewindow, u"
          "$mainMod SHIFT, down, movewindow, d"
          "$mainMod SHIFT, left, movewindow, l"
          "$mainMod SHIFT, right, movewindow, r"

          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"
        ];

        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];

        bindr = ["$mainMod, RETURN, exec, kitty"];

        plugin.split-monitor-workspaces = {
          keep_focused = 1;
          enable_persistent_workspaces = 0;
        };
      };

      extraConfig = ''
        $mainMod = SUPER

        bind = $mainMod, R, submap, resize

        submap = resize

        bind = , right, resizeactive, 25 0
        bind =, left, resizeactive, -25 0
        bind =, up, resizeactive, -25 0
        bind =, down, resizeactive, 25 0

        bind =, escape, submap, reset

        submap = reset
      '';

      plugins = [
        inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
      ];
    };

    programs.ags = {
      enable = true;

      configDir = ./widgets/ags;

      extraPackages = with pkgs; [gtksourceview webkitgtk accountsservice];
    };

    programs.wofi.enable = true;

    programs.wofi.style = ''
      #window {
        background-color: rgba(0, 0, 0, 0);
      }

      #inner-box {
        margin: 10px;
      }

      #input {
        background-color: rgba(120, 120, 120, 0.3);
        border: none;
        color: white;
        margin-top: 10px;
        margin-left: 10px;
        margin-right: 10px;
        border-radius: 5px;
        font-family: Inter SemiBold, sans-serif;
      }

      #input:selected {
        outline: none;
        border: none;
      }

      #img {
        min-height: 16px;
        min-width: 16px;
        margin: 5px;
        margin-right: 10px;
      }

      #entry {
        font-family: Inter SemiBold, sans-serif;
        border-radius: 5px;
        min-width: 100px;
        outline: none;
      }

      #entry:selected {
        background-color: rgba(120, 120, 120, 0.3);
      }

      #unselected {
        color: white;
      }
    '';
  };
}
