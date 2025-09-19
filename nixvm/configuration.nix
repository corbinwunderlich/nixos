{
  pkgs,
  config,
  ...
}: {
  imports = [./hardware-configuration.nix ./../modules/modules.nix];

  hyprland.enable = false;

  sway.enable = false;
  i3.enable = true;

  kde.enable = false;

  xrdp.enable = true;

  pulseaudio.enable = true;
  pipewire.enable = false;

  remmina.enable = false;

  printing.enable = false;

  btrfs-assistant.enable = false;

  bluetooth.enable = false;

  arduino.enable = false;

  ventoy.enable = false;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixvm";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.libinput.enable = true;

  security.sudo.extraConfig = "Defaults env_reset,pwfeedback";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = ["nvidia"];

  boot.kernelPackages = pkgs.linuxPackages_6_6;

  hardware.nvidia = {
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.grid_18_0;
    gsp.enable = false;
    vgpu.griddUnlock = {
      enable = true;
      rootCaFile =
        (pkgs.fetchurl {
          url = "https://siarnaq.ridgewood:7070/-/config/root-certificate";
          hash = "sha256-SfCKzvwNSYva17j+lD9E0aTRfbgaj73GegUH0GCu8Cw=";
          curlOpts = "--insecure";
        }).outPath;
    };
  };

  hardware.nvidia-container-toolkit.enable = true;

  users.users.corbin = import ./../users/corbin/corbin.nix;
  users.defaultUserShell = pkgs.zsh;

  services.openssh = {
    enable = true;

    settings.PasswordAuthentication = false;
  };

  services.qemuGuest.enable = true;

  services.fstrim.enable = true;

  networking.firewall.enable = false;

  environment.systemPackages = let
    selkies-gstreamer = pkgs.stdenv.mkDerivation rec {
      pname = "selkies-gstreamer";
      version = "1.6.2";

      src = pkgs.fetchurl {
        url = "https://github.com/selkies-project/selkies/releases/download/v${version}/gstreamer-selkies_gpl_v${version}_ubuntu24.04_amd64.tar.gz";
        hash = "sha256-M5yjqzXrjCrX3pqKPcWSkqnP/hHr9Lxrxqk5feI/m5A=";
      };

      nativeBuildInputs = [pkgs.makeWrapper];

      buildInputs = with pkgs;
        [
          libpulseaudio
          wayland-protocols
          wayland
          egl-wayland
          libxkbcommon
          libgcrypt
          gobject-introspection
          glib-networking
          libglibutil
          libgudev
          alsa-utils
          jack2
          libjack2
          libpulseaudio
          libopus
          libvpx
          x264
          x265
          libdrm
          libGL
          egl-wayland
          libglvnd
          wmctrl
          xsel
          xdotool
          libxcvt
          openh264
          svt-av1
          libavif
        ]
        ++ (with pkgs.xorg; [
          xkbutils
          libXdamage
          libXfixes
          libXv
          libXtst
          xvfb
          libxcb
          libX11
          libXext
        ])
        ++ (with pkgs.python312Packages; [
          setuptools
          wheel
        ]);

      postInstall = ''
        mkdir -p $out
        cp -r * $out

        chmod +x $out/gst-env
        mv $out/gst-env $out/bin/gst-env
      '';
    };
  in
    with pkgs; [
      westonLite
      cage
      xwayland

      nvidia-container-toolkit

      (let
        version = "1.6.2";

        selkies-web = pkgs.stdenvNoCC.mkDerivation {
          pname = "selkies-gstreamer-web";
          inherit version;

          src = pkgs.fetchurl {
            url = "https://github.com/selkies-project/selkies/releases/download/v${version}/selkies-gstreamer-web_v${version}.tar.gz";
            hash = "sha256-cfzDXVn42KbGtyRywgpFryB6tWoNBVOvNLcxoulm0MY=";
          };

          postInstall = ''
            mkdir -p $out
            cp -r * $out
          '';
        };
      in
        pkgs.python312Packages.buildPythonPackage rec {
          pname = "selkies_gstreamer-py3";
          inherit version;
          format = "wheel";
          src = pkgs.fetchurl {
            url = "https://github.com/selkies-project/selkies/releases/download/v${version}/selkies_gstreamer-${version}-py3-none-any.whl";
            hash = "sha256-9CauCThTSS7PhXYJ79TJvSFBskxhkRhWHkIiCSdVTu4=";
          };

          nativeBuildInputs = with pkgs; [makeWrapper];

          propagatedBuildInputs = with pkgs.python312Packages; [watchdog xlib pynput msgpack pillow websockets pygobject3 gst-python];

          postFixup = ''
            wrapProgram $out/bin/selkies-gstreamer \
              --set SELKIES_WEB_ROOT ${selkies-web.outPath} \
              --set GSTREAMER_PATH ${pkgs.python312Packages.gst-python.outPath}
          '';
        })
    ];

  environment.etc."weston.ini".source = (pkgs.formats.ini {}).generate "weston.ini" {
    shell = {locking = false;};

    core = {
      idle-time = 0;
      require-input = false;
      xwayland = false;
    };

    autolaunch = {path = "/home/corbin/xwayland";};
  };

  system.stateVersion = "24.05";
}
