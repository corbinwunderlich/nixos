{
  config,
  lib,
  pkgs,
  ...
}: {
  options.distrobox.enable = lib.mkEnableOption "Enables Distrobox and Docker";

  config = lib.mkIf config.distrobox.enable {
    virtualisation.docker.enable = true;
    virtualisation.docker.package = pkgs.docker_25;

    environment.systemPackages = with pkgs; [distrobox];
  };
}
