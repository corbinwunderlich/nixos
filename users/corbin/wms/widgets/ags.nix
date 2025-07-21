{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [inputs.ags.homeManagerModules.default];

  options.ags.enable = lib.mkEnableOption "Enables AGS";

  config = lib.mkIf config.ags.enable {
    programs.ags = {
      enable = true;

      configDir = ./ags;

      extraPackages = with pkgs; [gtksourceview accountsservice];
    };

    home.packages = with pkgs; [brightnessctl inotify-tools];
  };
}
