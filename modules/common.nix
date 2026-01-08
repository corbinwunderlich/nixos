{
  pkgs,
  inputs,
  ...
}: {
  environment.shells = with pkgs; [zsh];
  programs.zsh.enable = true;
  environment.systemPackages = with pkgs; [wget inputs.nixvim.packages.x86_64-linux.default git lazygit htop btop unzip python3 pciutils usbutils mesa-demos libva-utils];
  programs.nix-ld.enable = true;

  nix.settings.substituters = ["https://cache.garnix.io" "https://attic.xuyh0120.win/lantian"];
  nix.settings.trusted-public-keys = ["cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="];

  nix.settings.trusted-users = ["@wheel root"];

  environment.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";

  networking.firewall.allowedTCPPorts = [8080];

  nixpkgs.overlays = [
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = final.system;
        config.allowUnfree = true;
      };
    })

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
