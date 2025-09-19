{
  config,
  lib,
  pkgs,
  ...
}: {
  options.ventoy.enable = lib.mkEnableOption "Enables ventoy";

  config = lib.mkIf config.ventoy.enable {
    nixpkgs.config.permittedInsecurePackages = [
      "ventoy-1.1.05"
      "ventoy-gtk3-1.1.05"
    ];

    environment.systemPackages = with pkgs; [ventoy ventoy-full-gtk caligula];
  };
}
