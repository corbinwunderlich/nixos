{
  pkgs,
  inputs,
  ...
}: {
  imports = [./hardware-configuration.nix ./lact.nix ./../modules/modules.nix];

  boot.loader = {
    # Use the systemd-boot EFI boot loader.
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;

    timeout = 1;
  };

  services.logind.settings.Login = {
    HandlePowerKey = "sleep";
    HandlePowerKeyLongPress = "shutdown";
  };

  security.sudo.extraConfig = "Defaults env_reset,pwfeedback";

  services.udev.extraRules = ''
    ACTION=="add" SUBSYSTEM=="pci" ATTR{vendor}=="0x1022" ATTR{device}=="0x15b8" ATTR{power/wakeup}="disabled"
  '';

  services.btrfs.autoScrub.enable = true;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 64 * 1024; # 64 GB for hibernation
    }
  ];

  boot.initrd.availableKernelModules = ["nvme" "btrfs"];

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

  users.users.corbin = import ./../users/corbin/corbin.nix {inherit pkgs inputs;};
  users.defaultUserShell = pkgs.zsh;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  boot.kernelParams = ["video=DP-1:3840x2160@120" "video=DP-2:3840x2160@150"];

  hardware.amdgpu.initrd.enable = true;

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-zen4;

  programs.coolercontrol.enable = true;

  services.openssh = {
    enable = true;

    settings.PasswordAuthentication = false;
  };

  services.fstrim.enable = true;

  system.stateVersion = "24.11";
}
