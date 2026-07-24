{
  config,
  lib,
  pkgs,
  ...
}: {
  options.distrobox.enable = lib.mkEnableOption "Enables Distrobox";

  config = lib.mkIf config.distrobox.enable {
    podman.enable = true;

    environment.systemPackages = with pkgs; [distrobox];
  };
}
