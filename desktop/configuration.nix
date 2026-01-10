{
  pkgs,
  inputs,
  ...
}: {
  imports = [./hardware-configuration.nix ./lact.nix ./../modules/modules.nix];

  hyprland.enable = false;

  bluetooth.enable = false;

  boot.loader = {
    # Use the systemd-boot EFI boot loader.
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;

    timeout = 1;
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];

  services.logind.settings.Login = {
    HandlePowerKey = "hibernate";
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

  systemd.tmpfiles.rules = ["w /sys/power/image_size - - - - 1073741824"];

  boot.resumeDevice = "/dev/disk/by-uuid/2721e962-d3ce-4f8e-a6eb-f6d2b4081dbf";

  powerManagement.enable = true;

  boot.initrd.availableKernelModules = ["nvme" "btrfs"];

  systemd.services.systemd-logind.environment = {
    SYSTEMD_BYPASS_HIBERNATION_MEMORY_CHECK = "1";
  };

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

  environment.systemPackages = [
    inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.rose-pine-cursor
    pkgs.gh

    pkgs.winetricks
    pkgs.p7zip
    pkgs.cabextract
    pkgs.ppp
    pkgs.wine
  ];

  services.flatpak.packages = ["io.github.peazip.PeaZip"];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  boot.kernelParams = ["video=DP-1:3840x2160@120" "video=DP-2:3840x2160@150" "resume_offset=318583227" "hibernate.compressor=lzo"];

  hardware.amdgpu.initrd.enable = true;

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_18;

  programs.coolercontrol.enable = true;

  services.openssh = {
    enable = true;

    settings.PasswordAuthentication = false;
  };

  services.fstrim.enable = true;

  system.stateVersion = "24.11";
}
