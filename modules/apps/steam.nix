{
  config,
  lib,
  pkgs,
  ...
}: {
  options.steam.enable = lib.mkEnableOption "Enables Steam and Gamescope";

  config = lib.mkIf config.steam.enable {
    nixpkgs.config.allowUnfree = true;

    programs.steam.enable = true;
    programs.steam.gamescopeSession.enable = true;

    environment.systemPackages = with pkgs; [
      heroic
      lutris
      mangohud
      protonup
    ];

    environment.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/corbin/.steam/root/compatibilitytools.d";

    programs.gamemode.enable = true;
  };
}
