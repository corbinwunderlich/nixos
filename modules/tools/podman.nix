{
  config,
  lib,
  pkgs,
  ...
}: {
  options.podman.enable = lib.mkEnableOption "Enables Podman";

  config = lib.mkIf config.podman.enable {
    environment.systemPackages = with pkgs; [docker-compose];

    virtualisation.podman = {
      enable = true;

      dockerCompat = true;
      dockerSocket.enable = true;

      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };
}
