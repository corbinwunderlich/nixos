{
  config,
  lib,
  pkgs,
  ...
}: {
  options.localsend.enable = lib.mkEnableOption "Enables LocalSend";

  config = lib.mkIf config.localsend.enable {
    services.flatpak.enable = true;

    services.flatpak.packages = [
      "org.localsend.localsend_app"
    ];

    environment.systemPackages = with pkgs; [opendrop];
  };
}
