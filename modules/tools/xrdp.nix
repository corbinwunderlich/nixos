{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  xpra-html5 = pkgs.callPackage ./xpra-html5.nix {};

  xpraOverride = pkgs.xpra.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (lib.remove pkgs.clang oldAttrs.nativeBuildInputs) ++ [pkgs.cudaPackages.cuda_nvcc];

    postInstall = oldAttrs.postInstall + "\n mkdir -p $out/share/www" + "\n cp -r ${xpra-html5}/* $out/share/www/";
  });

  xpra = xpraOverride.override {
    withHtml = false;
  };

  novnc =
    pkgs.novnc.overrideAttrs
    (old: rec {
      pname = "novnc-pointer-lock";

      src = pkgs.fetchFromGitHub {
        owner = "happylabdab2";
        repo = "noVNC";
        rev = "master";
        hash = "sha256-9WRBDj2Z6L9dYPqsLe2BuCMLp4B7D9M51rMIDkhQaHM=";
      };

      nativeBuildInputs = [pkgs.gnused pkgs.makeWrapper];

      propagatedBuildInputs = with pkgs;
        [
          socat
          coreutils-full
        ]
        ++ (with pkgs.gst_all_1; [
          gstreamer
          gst-plugins-bad
          gst-plugins-good
          gst-plugins-base
          gst-plugins-ugly
        ]);

      postInstall = let
        audioPlugin = pkgs.fetchFromGitHub {
          owner = "me-asri";
          repo = "noVNC-audio-plugin";
          rev = "main";
          hash = "sha256-UmAPTroUYmhL6kizXmtoTVWjHrIKpg4EBh6hn6ldB4E=";
        };

        gstLibPath = path: path + "/lib/gstreamer-1.0";
      in ''
        cp ${audioPlugin}/audio-plugin.js $out/share/webapps/novnc/
        cp ${audioPlugin}/audio-proxy.sh $out/bin/audio-proxy

        wrapProgram $out/bin/audio-proxy \
          --prefix PATH : ${lib.makeBinPath propagatedBuildInputs} \
          --prefix GST_PLUGIN_PATH : ${gstLibPath pkgs.gst_all_1.gstreamer}:${gstLibPath pkgs.gst_all_1.gst-plugins-good}:${gstLibPath pkgs.gst_all_1.gst-plugins-base}:${gstLibPath pkgs.gst_all_1.gst-plugins-bad}:${gstLibPath pkgs.gst_all_1.gst-plugins-ugly}

        sed -i \
          '48a\
          <script type="module" crossorigin="anonymous" src="audio-plugin.js"></script>;

          s/websockify/websockify?token=vnc/g;

          s/value="remote"/value="remote" selected/g' $out/share/webapps/novnc/vnc.html
      '';
    });
in {
  imports = [inputs.sops-nix.nixosModules.sops];

  options.xrdp.enable = lib.mkEnableOption "Enables xrdp";

  config = lib.mkIf config.xrdp.enable {
    environment.systemPackages =
      [xpra xpra-html5]
      ++ [
        pkgs.python313Packages.websockify
        novnc
        pkgs.wayvnc
      ];

    services.pulseaudio = {
      systemWide = true;
      extraConfig = ''
        load-module module-null-sink sink_name=novnc_sink sink_properties=device.description="NoVNC_OGG_Stream_Output"
      '';
    };

    systemd.user.services."audio-proxy" = {
      enable = true;
      after = ["network.target"];
      bindsTo = ["websockify.service"];
      wantedBy = ["default.target"];

      serviceConfig = {
        RestartSec = 5;
        Restart = "always";
      };

      unitConfig.ConditionUser = "corbin";

      path = with pkgs; [(ffmpeg-full.override {withUnfree = true;}) pulseaudioFull libvorbis netcat-openbsd libopus libopusenc libwebm socat];

      environment.GST_PLUGIN_PATH = let
        gstLibPath = path: path + "/lib/gstreamer-1.0";
      in "${gstLibPath pkgs.gst_all_1.gstreamer}:${gstLibPath pkgs.gst_all_1.gst-plugins-good}:${gstLibPath pkgs.gst_all_1.gst-plugins-base}:${gstLibPath pkgs.gst_all_1.gst-plugins-bad}:${gstLibPath pkgs.gst_all_1.gst-plugins-ugly}";

      script = ''
        ffmpeg \
          -fflags nobuffer -f pulse -i novnc_sink.monitor \
          -vn -c:a libfdk_aac -ac 2 -ar 44100 -bitrate 8000 \
          -async 1 -hls_time 0.5 -hls_list_size 5 -hls_flags delete_segments+split_by_time \
          -f hls /home/corbin/noVNC/stream/index.m3u8
      '';
    };

    systemd.user.services."websockify" = {
      enable = true;
      requires = ["sway.service"];
      wantedBy = ["default.target"];
      after = ["wayvnc.service"];

      serviceConfig = {
        RestartSec = 5;
        Restart = "always";
      };

      unitConfig.ConditionUser = "corbin";

      path = with pkgs.python313Packages; [websockify];

      script = let
        tokenFile = pkgs.writeText "websockify-token" ''
          vnc: 127.0.0.1:5900
          audio: 127.0.0.1:5711
        '';
      in ''
        websockify \
          --web=/home/corbin/noVNC \
          --token-plugin=TokenFile \
          --token-source=${tokenFile} \
          8081
      '';
    };

    systemd.user.services."sway" = {
      enable = true;
      wantedBy = ["default.target"];
      after = ["network.target"];
      wants = ["wayvnc.service" "websockify.service"];

      serviceConfig = {
        RestartSec = 5;
        Restart = "always";
      };

      unitConfig.ConditionUser = "corbin";

      script = ''
        export PATH="''${XDG_BIN_HOME}:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"

        export DISPLAY=:0
        export XDG_SESSION_TYPE=wayland
        export XDG_SESSION_ID=1
        export XDG_SESSION_DESKTOP=sway

        WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1 ${pkgs.sway}/bin/sway
      '';
    };

    systemd.user.services."wayvnc" = {
      enable = true;
      wantedBy = ["default.target"];
      after = ["network.target" "sway.service"];
      bindsTo = ["sway.service"];

      serviceConfig = {
        RestartSec = 5;
        Restart = "always";
      };

      unitConfig.ConditionUser = "corbin";

      path = with pkgs; [wayvnc];

      script = let
        wayvncConfig = pkgs.writeText "wayvnc-config" (lib.generators.toINI {} {
          #username = builtins.readFile config.sops.secrets."vnc/username".path;
          #password = builtins.readFile config.sops.secrets."vnc/password".path;
        });
      in ''
        export PATH="''${XDG_BIN_HOME}:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"

        WAYLAND_DISPLAY=wayland-1 wayvnc -f 60 -p --gpu --log-level=debug -v
        #WAYLAND_DISPLAY=wayland-1 wayvnc -f 60 -C ${wayvncConfig} -p -v
      '';
    };

    security.polkit.enable = true;

    hardware.uinput.enable = true;

    boot.kernelModules = ["v4l2loopback" "uinput"];
    boot.extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];

    systemd.user.services."xwfb" = {
      enable = false;
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
      enable = false;

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
