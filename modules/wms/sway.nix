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

    environment.sessionVariables = {
      GTK_CSD = "0";
      LD_PRELOAD = let
        gtk3-nocsd = pkgs.stdenv.mkDerivation {
          pname = "gtk3-nocsd";
          version = "3.0.8";

          src = pkgs.fetchFromGitHub {
            owner = "ZaWertun";
            repo = "gtk3-nocsd";
            rev = "v3.0.8";
            sha256 = "sha256-BOsQqxaVdC5O6EnB3KZinKSj0U5mCcX8HSjRmSBUFks=";
          };

          nativeBuildInputs = with pkgs; [
            pkg-config
          ];

          buildInputs = with pkgs; [
            gtk3
            gobject-introspection
          ];

          installPhase = ''
            mkdir -p $out/lib
            mkdir -p $out/bin
            cp libgtk3-nocsd.so.0 $out/lib/
            cp gtk3-nocsd $out/bin/
          '';
        };
      in "${gtk3-nocsd}/lib/libgtk3-nocsd.so.0";

      NIXOS_OZONE_WL = "1";
    };

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
    };

    services.displayManager = {
      defaultSession = "sway-uwsm";

      autoLogin = lib.mkIf (machine == "desktop") {
        enable = false;
        user = "corbin";
      };
    };

    programs.gtklock.enable = true;
  };
}
