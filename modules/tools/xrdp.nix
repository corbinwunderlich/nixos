{
  config,
  lib,
  pkgs,
  ...
}: let
  xpra-html5 = pkgs.callPackage ./xpra-html5.nix {};

  xpraOverride = pkgs.xpra.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (lib.remove pkgs.clang oldAttrs.nativeBuildInputs) ++ [pkgs.cudaPackages.cuda_nvcc];

    postInstall = oldAttrs.postInstall + "\n mkdir -p $out/share/www" + "\n cp -r ${xpra-html5}/* $out/share/www/";
  });

  xpra = xpraOverride.override {
    nvidia_x11 = config.hardware.nvidia.package;
    nv-codec-headers-10 = pkgs.nv-codec-headers-12;
    withNvenc = true;
    withHtml = false;
  };
in {
  options.xrdp.enable = lib.mkEnableOption "Enables xrdp";

  config = lib.mkIf config.xrdp.enable {
    environment.systemPackages = [xpra xpra-html5];

    security.polkit.enable = true;

    hardware.uinput.enable = true;

    boot.kernelModules = ["v4l2loopback" "uinput"];
    boot.extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];

    systemd.user.services."xwfb" = {
      enable = true;
      after = ["network.target"];

      serviceConfig = {
        Restart = "always";
        RestartSec = "5s";
      };

      unitConfig.ConditionUser = "corbin";

      path = with pkgs; [cage] ++ config.services.xserver.windowManager.i3.extraPackages;

      script = let
        initScript = pkgs.writeShellScriptBin "init" ''
          ${pkgs.systemd}/bin/systemctl --user import-environment PATH DISPLAY XAUTHORITY DESKTOP_SESSION XDG_CONFIG_DIRS XDG_DATA_DIRS XDG_RUNTIME_DIR XDG_SESSION_ID DBUS_SESSION_BUS_ADDRESS || true
          ${pkgs.dbus}/bin/dbus/dbus-update-activation-environment --systemd --all || true

          unset WAYLAND_DISPLAY
          export XDG_SESSION_TYPE=x11
          export SDL_VIDEODRIVER=x11
          export GDK_BACKEND=x11
          export QT_QPA_PLATFORM=xcb
          export MOZ_X11_EGL=true

          export PATH="''${XDG_BIN_HOME}:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"

          ${pkgs.i3}/bin/i3
        '';
      in ''
        ${pkgs.xwayland-run}/bin/xwfb-run -d :1 -f /home/corbin/.Xauthority -c cage -n 1 -- ${initScript}/bin/init
      '';
    };

    systemd.user.services."xpra" = {
      enable = true;

      wantedBy = ["default.target"];
      bindsTo = ["xwfb.service"];

      environment.DISPLAY = ":1";
      environment.LD_LIBRARY_PATH = "${pkgs.libGL}/lib";
      environment.XAUTHORITY = "/home/corbin/.Xauthority";

      serviceConfig = {
        Restart = "always";
      };

      unitConfig.ConditionUser = "corbin";

      script = ''
        ${xpra}/bin/xpra start-desktop --use-display :1 --daemon=no --pulseaudio=no --mdns=no --speaker=yes --sound-source=pulse  --html=${xpra-html5.out} --bind-wss=0.0.0.0:14500,auth=file,filename=/home/corbin/password.txt --video-encoders=nvjpeg,jpeg,x264 --ssl-key=/home/corbin/.xpra/cloudflare-key.pem --ssl-cert=/home/corbin/.xpra/cloudflare-cert.pem
      '';
    };

    users.users.corbin.linger = true;

    xdg.menus.enable = true;
  };
}
