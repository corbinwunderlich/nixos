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
      wrapperFeatures.gtk = true;
    };

    services.xserver.enable = true;

    security.polkit.enable = true;

    services.greetd = let
    in {
      enable = true;
      restart = true;

      settings = {
        default_session = lib.mkIf (machine == "laptop") {
          command = "uwsm start sway-uwsm.desktop";
          user = "corbin";
        };

        initial_session = lib.mkIf (machine != "laptop") {
          command = "uwsm start sway-uwsm.desktop";
          user = "corbin";
        };
      };
    };

    environment.etc."greetd/environments".text = ''
      sway
      zsh
      bash
    '';

    programs.gtklock.enable = true;
  };
}
