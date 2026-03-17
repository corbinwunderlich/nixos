{
  config,
  lib,
  pkgs,
  ...
}: {
  options.ventoy.enable = lib.mkEnableOption "Enables ventoy";

  config = lib.mkIf config.ventoy.enable {
    nixpkgs.config.permittedInsecurePackages = [
      "ventoy-1.1.07"
      "ventoy-1.1.10"
      "ventoy-gtk3-1.1.07"
      "ventoy-gtk3-1.1.10"
    ];

    environment.systemPackages = with pkgs; [ventoy ventoy-full-gtk caligula];
  };
}
