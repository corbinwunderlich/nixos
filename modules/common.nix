{
  pkgs,
  inputs,
  ...
}: {
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.shells = with pkgs; [zsh];
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    inputs.nixvim.packages.x86_64-linux.default
    git
    forgejo-cli
    gh
    lazygit
    htop
    btop
    unzip
    python3
    pciutils
    usbutils
    mesa-demos
    libva-utils
  ];

  networking.firewall.allowedTCPPorts = [8080];

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  nixpkgs.overlays = [
    (_: prev: {
      ulauncher = prev.ulauncher.overrideAttrs {
        propagatedBuildInputs = prev.ulauncher.propagatedBuildInputs ++ [pkgs.python3Packages.pytz];
      };
    })

    inputs.xwayland-satellite.overlays.default

    inputs.nix-cachyos-kernel.overlays.pinned
  ];
}
