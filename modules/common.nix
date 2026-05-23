{
  pkgs,
  inputs,
  ...
}: {
  environment.shells = with pkgs; [zsh];
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [wget inputs.nixvim.packages.x86_64-linux.default git forgejo-cli gh lazygit htop btop unzip python3 pciutils usbutils mesa-demos libva-utils];

  networking.firewall.allowedTCPPorts = [8080];

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  nixpkgs.overlays = [
    (final: prev: {
      ulauncher = prev.ulauncher.overrideAttrs {
        propagatedBuildInputs = prev.ulauncher.propagatedBuildInputs ++ [pkgs.python3Packages.pytz];
      };
    })

    (final: prev: {
      xwayland-satellite = inputs.xwayland-satellite.packages.x86_64-linux.default;
    })

    inputs.nix-cachyos-kernel.overlays.pinned
  ];
}
