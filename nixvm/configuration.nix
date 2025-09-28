{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: {
  imports = [./hardware-configuration.nix ./../modules/modules.nix];

  hyprland.enable = false;

  sway.enable = true;
  i3.enable = false;

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

    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965
    ];
  };

  services.xserver.videoDrivers = ["nvidia"];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_12;

  hardware.nvidia = {
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.grid_18_0.override {
      stdenv = pkgs.overrideCC pkgs.stdenv pkgs.gcc14;
    };
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

  boot.kernelParams = ["i915-sriov.enable_guc=3" "module_blacklist=xe" "module_blacklist=i915"];

  boot.kernelModules = ["i915-sriov"];
  boot.initrd.kernelModules = ["i915-sriov"];

  boot.extraModulePackages = [
    (pkgs.i915-sriov.overrideAttrs {
      installPhase = ''
        mkdir -p $out/lib/modules/${pkgs.linux_6_12.modDirVersion}/extra

        ${pkgs.xz}/bin/xz -z -f i915.ko

        cp i915.ko.xz $out/lib/modules/${pkgs.linux_6_12.modDirVersion}/extra/i915-sriov.ko.xz
      '';
    })
  ];

  boot.postBootCommands = ''
    /run/current-system/sw/bin/depmod -a ${pkgs.linux_6_12.modDirVersion}
  '';

  users.users.corbin = import ./../users/corbin/corbin.nix;
  users.defaultUserShell = pkgs.zsh;

  services.openssh = {
    enable = true;

    settings.PasswordAuthentication = false;
  };

  services.qemuGuest.enable = true;

  services.fstrim.enable = true;

  networking.firewall.enable = false;

  environment.systemPackages = with pkgs; [
    westonLite
    cage
    xwayland

    nvidia-container-toolkit
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
