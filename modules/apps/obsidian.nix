{
  config,
  pkgs,
  lib,
  ...
}: {
  options.obsidian.enable = lib.mkEnableOption "Enables Obsidian.md";

  config = lib.mkIf config.obsidian.enable {
    services.flatpak.enable = true;

    services.flatpak.packages = [
      "md.obsidian.Obsidian"
    ];
  };
}
