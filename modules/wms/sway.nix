{
  pkgs,
  config,
  lib,
  ...
}: {
  options.sway.enable = lib.mkEnableOption "Enables swaywm";

  config = let
    swayConfig = pkgs.writeText "greetd-sway-config" ''
      exec "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l; swaymsg exit"

      bindsym Mod4+shift+e exec swaynag \
        -t warning \
        -m 'What do you want to do?' \
        -b 'Shutdown' 'systemctl poweroff' \
        -b 'Reboot' 'systemctl reboot' \
        -b 'Sleep' 'systemctl suspend'
      include /etc/sway/config.d/*
    '';

    sway-uwsm = pkgs.writeShellScriptBin "sway+uwsm" ''
      uwsm start sway-uwsm.desktop
    '';
  in
    lib.mkIf config.sway.enable {
      environment.systemPackages = with pkgs; [grim slurp wl-clipboard dunst ulauncher swaysome uwsm] ++ [sway-uwsm];

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

      services.greetd = let
      in {
        enable = true;
        restart = true;

        settings = {
          default_session = {
            command = "${pkgs.uwsm}/bin/uwsm start -- ${pkgs.sway}/bin/sway --config ${swayConfig}";
            user = "corbin";
          };
        };
      };

      environment.etc."greetd/environments".text = ''
        sway+uwsm
        sway
        zsh
        bash
      '';

      programs.gtklock.enable = true;
    };
}
