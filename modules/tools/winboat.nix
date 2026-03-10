{
  config,
  lib,
  pkgs,
  ...
}: {
  options.winboat.enable = lib.mkEnableOption "Enables Winboat";

  config = lib.mkIf config.winboat.enable {
    virtualisation.docker.enable = true;

    environment.systemPackages = with pkgs; [winboat freerdp];
  };
}
