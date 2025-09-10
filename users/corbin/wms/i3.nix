{
  config,
  lib,
  pkgs,
  machine,
  ...
}: let
  modifier = config.xsession.windowManager.i3.config.modifier;
  terminal = config.xsession.windowManager.i3.config.terminal;
in {
  options.i3.enable = lib.mkEnableOption "Enables i3";

  config = lib.mkIf config.i3.enable {
    home.packages = with pkgs; [autotiling nwg-look brightnessctl];

    home.pointerCursor = let
      getFrom = url: hash: name: {
        gtk.enable = true;
        x11.enable = true;
        name = name;
        size = 48;
        package = pkgs.runCommand "moveUp" {} ''
          mkdir -p $out/share/icons
          ln -s ${
            pkgs.fetchzip {
              url = url;
              hash = hash;
              stripRoot = false;
            }
          } $out/share/icons/${name}
        '';
      };
    in
      getFrom
      "https://github.com/sevmeyer/mocu-xcursor/releases/download/1.1/mocu-xcursor-1.1.zip"
      "sha256-KVPU545DSfjeOSoWp7k7JCezzGLNCWyV/+PtYoYV1wE=" "Mocu-Black-Left";

    xsession.windowManager.i3 = {
      enable = true;
      package = pkgs.i3;

      config = {
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
            command = "/home/corbin/xwayland";
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

            "${modifier}+ctrl+1" = "workspace number 1";
            "${modifier}+ctrl+2" = "workspace number 2";
            "${modifier}+ctrl+3" = "workspace number 3";
            "${modifier}+ctrl+4" = "workspace number 4";
            "${modifier}+ctrl+5" = "workspace number 5";
            "${modifier}+ctrl+6" = "workspace number 6";
            "${modifier}+ctrl+7" = "workspace number 7";
            "${modifier}+ctrl+8" = "workspace number 8";
            "${modifier}+ctrl+9" = "workspace number 9";
            "${modifier}+ctrl+0" = "workspace number 10";

            "${modifier}+Shift+1" = "move container to workspace number 1";
            "${modifier}+Shift+2" = "move container to workspace number 2";
            "${modifier}+Shift+3" = "move container to workspace number 3";
            "${modifier}+Shift+4" = "move container to workspace number 4";
            "${modifier}+Shift+5" = "move container to workspace number 5";
            "${modifier}+Shift+6" = "move container to workspace number 6";
            "${modifier}+Shift+7" = "move container to workspace number 7";
            "${modifier}+Shift+8" = "move container to workspace number 8";
            "${modifier}+Shift+9" = "move container to workspace number 9";
            "${modifier}+Shift+0" = "move container to workspace number 10";

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
            "${modifier}+d" = "exec dmenu_run -fn 'JetBrainsMono Nerd Font-10' -nb black";
            "${modifier}+e" = ''exec i3-dmenu-desktop --dmenu="dmenu -i -fn 'JetBrainsMono Nerd Font-10' -nb black"'';
            "${modifier}+Shift+q" = "kill";
          }
          else {
            "${modifier}+Shift+r" = "restart";

            "${modifier}+1" = "workspace number 1";
            "${modifier}+2" = "workspace number 2";
            "${modifier}+3" = "workspace number 3";
            "${modifier}+4" = "workspace number 4";
            "${modifier}+5" = "workspace number 5";
            "${modifier}+6" = "workspace number 6";
            "${modifier}+7" = "workspace number 7";
            "${modifier}+8" = "workspace number 8";
            "${modifier}+9" = "workspace number 9";
            "${modifier}+0" = "workspace number 10";

            "${modifier}+Shift+1" = "move container to workspace number 1";
            "${modifier}+Shift+2" = "move container to workspace number 2";
            "${modifier}+Shift+3" = "move container to workspace number 3";
            "${modifier}+Shift+4" = "move container to workspace number 4";
            "${modifier}+Shift+5" = "move container to workspace number 5";
            "${modifier}+Shift+6" = "move container to workspace number 6";
            "${modifier}+Shift+7" = "move container to workspace number 7";
            "${modifier}+Shift+8" = "move container to workspace number 8";
            "${modifier}+Shift+9" = "move container to workspace number 9";
            "${modifier}+Shift+0" = "move container to workspace number 10";

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
            "${modifier}+d" = "exec dmenu_run -fn 'JetBrainsMono Nerd Font-10' -nb black";
            "${modifier}+e" = ''exec i3-dmenu-desktop --dmenu="dmenu -i -fn 'JetBrainsMono Nerd Font-10' -nb black"'';
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

    xdg.configFile."nitrogen/nitrogen.cfg".text = ''
      [geometry]
      posx=680
      posy=554
      sizex=676
      sizey=191

      [nitrogen]
      view=icon
      recurse=true
      sort=alpha
      icon_caps=false
      dirs=/home/corbin/Pictures/wallpapers;
    '';

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
