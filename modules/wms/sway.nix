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
    environment.sessionVariables.GTK_CSD = "0";

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
      autoLogin = lib.mkIf (machine == "desktop") {
        enable = false;
        user = "corbin";
      };

      lightdm = {
        enable = true;

        greeters.gtk = {
          theme.name = "Adwaita-dark";
        };

        extraSeatDefaults = let
          lightdmSession = pkgs.writeShellScriptBin "lightdm-session" ''
            # From https://gist.github.com/glebzlat/bf207aad44da6e9f22b29651f37ae067
            # Wait until the Xorg process finishes
            while pgrep -u 0 Xorg > /dev/null; do
              sleep 0.1
            done

            if [ -z "$\{XDG_RUNTIME_DIR}" ]; then
              export XDG_RUNTIME_DIR=/run/user/$(id -u)
              mkdir -p $\{XDG_RUNTIME_DIR}
            fi

            # If your distro uses dbus-daemon instead of dbus-broker,
            # uncomment dbus-run-session line.
            # exec env dbus-run-session $@

            # On Fedora dbus-run-session tries to connect to DBus daemon,
            # which is not running
            exec env $@
          '';
        in "session-wrapper=${lightdmSession}/bin/lightdm-session";
      };

      defaultSession = "sway-uwsm";
    };

    programs.gtklock.enable = true;
  };
}
