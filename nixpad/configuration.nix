{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./hardware-configuration.nix ./../modules/modules.nix];

  i3.enable = false;
  sway.enable = true;
  kde.enable = false;
  hyprland.enable = false;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixpad";
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

  security.sudo.extraConfig = "Defaults env_reset,pwfeedback";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-zen4;

  users.users.corbin = import ./../users/corbin/corbin.nix {inherit pkgs;};
  users.defaultUserShell = pkgs.zsh;

  services.btrfs.autoScrub.enable = true;
  services.fstrim.enable = true;

  services.openssh = {
    enable = true;

    settings.PasswordAuthentication = false;
  };

  services.libinput = {
    enable = true;
    touchpad.tapping = true;
    touchpad.clickMethod = "clickfinger";
    touchpad.tappingButtonMap = "lrm";
  };

  services.fprintd = {
    enable = true;
  };

  security.pam.services.login.fprintAuth = true;
  security.pam.services.gtklock.fprintAuth = true;
  security.pam.services.sudo.fprintAuth = true;

  services.logind.settings.Login = {
    lidSwitch = "suspend";
    lidSwitchDocked = "suspend";
    lidSwitchExternalPower = "suspend";
  };

  system.stateVersion = "24.11";
}
