{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [./hardware-configuration.nix ./lact.nix ./../modules/modules.nix];

  samba.enable = false;

  hyprland.enable = false;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  services.logind.extraConfig = ''
    HandlePowerKey=suspend
    HandlePowerKeyLongPress=shutdown
  '';

  security.sudo.extraConfig = "Defaults env_reset,pwfeedback";

  services.udev.extraRules = ''
    ACTION=="add" SUBSYSTEM=="pci" ATTR{vendor}=="0x1022" ATTR{device}=="0x15b8" ATTR{power/wakeup}="disabled"
  '';

  services.btrfs.autoScrub.enable = true;

  networking = {
    hostName = "desktop";
    networkmanager.enable = true;
  };

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

  users.users.corbin = import ./../users/corbin/corbin.nix;
  users.defaultUserShell = pkgs.zsh;

  environment.systemPackages = [
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
    pkgs.rose-pine-cursor
    pkgs.gh

    pkgs.winetricks
    pkgs.p7zip
    pkgs.cabextract
    pkgs.ppp
    pkgs.wine
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  boot.initrd.kernelModules = ["amdgpu"];

  services.xserver.videoDrivers = ["modesetting"];

  boot.kernelParams = ["video=DP-1:1920x1200@60" "video=DP-2:3840x2160@150"];

  programs.coolercontrol.enable = true;

  services.openssh = {
    enable = true;

    settings.PasswordAuthentication = false;
  };

  services.fstrim.enable = true;

  system.stateVersion = "24.11";
}
