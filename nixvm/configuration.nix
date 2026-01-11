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

    package = pkgs.unstable.mesa;
    package32 = pkgs.unstable.pkgsi686Linux.mesa;
  };

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_18;

  services.xserver.videoDrivers = ["modesetting"];

  users.users.corbin = import ./../users/corbin/corbin.nix {inherit pkgs inputs;};
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
