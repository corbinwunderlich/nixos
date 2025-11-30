{
  config,
  pkgs,
  lib,
  machine,
  inputs,
  ...
}: {
  options.hyprland.enable = lib.mkEnableOption "Enables Hyprland";

  config = lib.mkIf config.hyprland.enable {
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    environment.sessionVariables.ELECTRON_OZONE_PLATFORM_HINT = "auto";

    nix.settings = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };

    security.pam.services.hyprlock = {};
    security.polkit.enable = true;

    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };

    services.xserver.enable = true;

    services.displayManager = {
      defaultSession = "hyprland";

      sddm = {
        enable = true;
        wayland.enable = true;
        wayland.compositor = "kwin";
      };
    };

    services.desktopManager.plasma6.enable = lib.mkForce false;
  };
}
