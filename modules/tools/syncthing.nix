{
  config,
  lib,
  ...
}: {
  options.syncthing.enable = lib.mkEnableOption "Enables syncthing";

  config = lib.mkIf config.syncthing.enable {
    services.syncthing = {
      enable = true;
      user = "corbin";
      dataDir = "/home/corbin/.local/share/syncthing";
      configDir = "/home/corbin/.config/syncthing";
      openDefaultPorts = true;
    };
  };
}
