{
  pkgs,
  config,
  lib,
  machine,
  ...
}: {
  options.sway.enable = lib.mkEnableOption "Enables swaywm";

  config = lib.mkIf config.sway.enable {
    environment.systemPackages = with pkgs; [grim slurp wl-clipboard dunst ulauncher swaysome uwsm];

    services.gnome.gnome-keyring.enable = true;

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    programs.uwsm = {
      enable = true;
      waylandCompositors = {
        sway = {
          prettyName = "Sway";
          comment = "Sway compositor managed by UWSM";
          binPath = "${pkgs.sway}/bin/sway";
        };
      };
    };

    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = false;
    };

    services.xserver.enable = true;

    security.polkit.enable = true;

    services.xserver.displayManager = {
      sddm = {
        enable = true;

        wayland = {
          enable = true;
        };

        settings = let
          westonConfig = pkgs.writeText "sddmWestonConfig" ''
            [output]
            name=DP-2
            mode=3840x2160@150
            force-on=true

            [output]
            name=DP-1
            mode=1920x1200@60
            transform=rotate-270
          '';
        in {
          Wayland = {
            CompositorCommand = "${pkgs.weston}/bin/weston --shell=kiosk -c ${westonConfig}";
          };
        };
      };

      autoLogin = lib.mkIf (machine == "desktop") {
        enable = true;
        user = "corbin";
      };

      setupCommands = ''
        ${pkgs.xorg.xrandr}/bin/xrandr --output DP-1 --off
        ${pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --on
      '';

      defaultSession = "sway-uwsm";
    };

    programs.gtklock.enable = true;
  };
}
